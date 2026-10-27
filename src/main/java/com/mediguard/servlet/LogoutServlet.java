package com.mediguard.servlet;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {
    @Override protected void doGet(HttpServletRequest req,HttpServletResponse resp)throws IOException{
        HttpSession s=req.getSession(false);if(s!=null)s.invalidate();
        resp.sendRedirect(req.getContextPath()+"/login?logout=1");
    }
    @Override protected void doPost(HttpServletRequest req,HttpServletResponse resp)throws IOException{doGet(req,resp);}
}
