package com.mediguard.servlet;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Set;
@WebFilter("/*")
public class AuthFilter implements Filter {
    private static final Set<String> PUBLIC=Set.of("/login","/login.jsp","/setup-admin","/setup-admin.jsp","/index.html","/favicon.ico");
    private static final Set<String> ADMIN_ONLY=Set.of("/suppliers","/add-batch","/stock-valuation");
    @Override public void doFilter(ServletRequest sr,ServletResponse ss,FilterChain chain)throws IOException,ServletException{
        HttpServletRequest req=(HttpServletRequest)sr;HttpServletResponse resp=(HttpServletResponse)ss;
        resp.setHeader("Cache-Control","no-cache, no-store, must-revalidate");resp.setHeader("Pragma","no-cache");resp.setDateHeader("Expires",0);
        String path=req.getRequestURI().substring(req.getContextPath().length());
        if(path.startsWith("/css/")||path.startsWith("/js/")||path.startsWith("/images/")||path.startsWith("/assets/")||PUBLIC.contains(path)||path.startsWith("/WEB-INF/")){
            chain.doFilter(req,resp);return;
        }
        HttpSession session=req.getSession(false);
        if(session==null||session.getAttribute("userId")==null){resp.sendRedirect(req.getContextPath()+"/login");return;}
        Object role=session.getAttribute("userRole");
        if(ADMIN_ONLY.contains(path)&&(role==null||!"ADMIN".equals(role.toString()))){resp.sendError(403,"Administrator access required.");return;}
        chain.doFilter(req,resp);
    }
}
