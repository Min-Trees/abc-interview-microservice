package com.auth.service.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class EmailService {
    
    private final JavaMailSender mailSender;
    
    @Value("${app.verification-url}")
    private String verificationUrl;
    
    public void sendVerificationEmail(String toEmail, String verifyToken) {
        try {
            // Mock email sending for testing
            log.info("=== MOCK EMAIL SENT ===");
            log.info("To: {}", toEmail);
            log.info("Subject: Xác thực tài khoản - Interview System");
            log.info("Verification URL: {}?token={}", verificationUrl, verifyToken);
            log.info("Message: Xin chào, cảm ơn bạn đã đăng ký tài khoản. Vui lòng click vào link trên để xác thực email.");
            log.info("=======================");
            
            // Uncomment below for real email sending
            /*
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo(toEmail);
            message.setSubject("Xác thực tài khoản - Interview System");
            message.setText("Xin chào,\n\n" +
                    "Cảm ơn bạn đã đăng ký tài khoản.\n" +
                    "Vui lòng click vào link sau để xác thực email:\n\n" +
                    verificationUrl + "?token=" + verifyToken + "\n\n" +
                    "Link này sẽ hết hạn sau 24 giờ.\n\n" +
                    "Trân trọng,\n" +
                    "Interview System Team");
            
            mailSender.send(message);
            log.info("Verification email sent to: {}", toEmail);
            */
        } catch (Exception e) {
            log.error("Failed to send verification email to: {}", toEmail, e);
            // Don't throw exception - email failure shouldn't stop registration
        }
    }
}

