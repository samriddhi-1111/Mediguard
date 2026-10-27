package com.mediguard.util;
import java.security.GeneralSecurityException;
import java.security.SecureRandom;
import java.util.Base64;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

public final class PasswordUtil {
    private static final int ITERATIONS=210000, SALT_BYTES=16, KEY_BITS=256;
    private PasswordUtil(){}
    public static String hashPassword(char[] password) throws GeneralSecurityException {
        byte[] salt=new byte[SALT_BYTES]; new SecureRandom().nextBytes(salt);
        byte[] hash=derive(password,salt,ITERATIONS,KEY_BITS);
        return "pbkdf2-sha256$"+ITERATIONS+"$"+Base64.getEncoder().encodeToString(salt)+"$"+Base64.getEncoder().encodeToString(hash);
    }
    public static boolean verifyPassword(char[] password,String stored) throws GeneralSecurityException {
        if(password==null||stored==null)return false;
        String[] p=stored.split("\\$",-1);
        if(p.length!=4||!"pbkdf2-sha256".equals(p[0]))return false;
        try {
            int iterations=Integer.parseInt(p[1]);
            if(iterations<100000||iterations>2000000)return false;
            byte[] salt=Base64.getDecoder().decode(p[2]), expected=Base64.getDecoder().decode(p[3]);
            byte[] actual=derive(password,salt,iterations,expected.length*8);
            if(actual.length!=expected.length)return false;
            int diff=0; for(int i=0;i<actual.length;i++)diff|=actual[i]^expected[i];
            java.util.Arrays.fill(actual,(byte)0); return diff==0;
        } catch(IllegalArgumentException ex){return false;}
    }
    private static byte[] derive(char[] password,byte[] salt,int iterations,int bits)throws GeneralSecurityException{
        PBEKeySpec spec=new PBEKeySpec(password,salt,iterations,bits);
        try{return SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256").generateSecret(spec).getEncoded();}
        finally{spec.clearPassword();}
    }
}
