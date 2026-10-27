package com.mediguard.servlet;
import com.mediguard.util.DBConnection;
import com.mediguard.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.security.GeneralSecurityException;
import java.sql.*;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    @Override protected void doGet(HttpServletRequest req,HttpServletResponse resp)throws ServletException,IOException{
        HttpSession s=req.getSession(false);
        if(s!=null&&s.getAttribute("userId")!=null){resp.sendRedirect(req.getContextPath()+"/dashboard");return;}
        req.getRequestDispatcher("/login.jsp").forward(req,resp);
    }
    @Override protected void doPost(HttpServletRequest req,HttpServletResponse resp)throws ServletException,IOException{
        req.setCharacterEncoding("UTF-8");
        String email=req.getParameter("email"), password=req.getParameter("password");
        if(email==null||password==null||email.isBlank()||password.isEmpty()){
            req.setAttribute("error","Enter both email and password."); req.getRequestDispatcher("/login.jsp").forward(req,resp); return;
        }
        String sql="SELECT USER_ID,FULL_NAME,EMAIL,PASSWORD_HASH,USER_ROLE FROM MGX26_USERS WHERE LOWER(EMAIL)=LOWER(?)";
        try(Connection c=DBConnection.getConnection();PreparedStatement ps=c.prepareStatement(sql)){
            ps.setString(1,email.trim());
            try(ResultSet rs=ps.executeQuery()){
                if(!rs.next()){fail(req,resp);return;}
                boolean valid;
                try{valid=PasswordUtil.verifyPassword(password.toCharArray(),rs.getString("PASSWORD_HASH"));}
                catch(GeneralSecurityException e){throw new ServletException("Password verification failed.",e);}
                if(!valid){fail(req,resp);return;}
                String role=rs.getString("USER_ROLE");
                if(role==null||(!role.equalsIgnoreCase("ADMIN")&&!role.equalsIgnoreCase("STAFF"))){
                    req.setAttribute("error","This account has an unsupported role.");req.getRequestDispatcher("/login.jsp").forward(req,resp);return;
                }
                HttpSession old=req.getSession(false);if(old!=null)old.invalidate();
                HttpSession s=req.getSession(true);s.setMaxInactiveInterval(1800);
                s.setAttribute("userId",rs.getLong("USER_ID"));s.setAttribute("fullName",rs.getString("FULL_NAME"));
                s.setAttribute("userEmail",rs.getString("EMAIL"));s.setAttribute("userRole",role.toUpperCase(java.util.Locale.ROOT));
                resp.sendRedirect(req.getContextPath()+"/dashboard");
            }
        }catch(SQLException e){throw new ServletException("Unable to authenticate against Oracle.",e);}
    }
    private void fail(HttpServletRequest req,HttpServletResponse resp)throws ServletException,IOException{
        req.setAttribute("error","Invalid email or password.");req.getRequestDispatcher("/login.jsp").forward(req,resp);
    }
}
