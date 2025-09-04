package com.abc.gateway_service.config;

import io.jsonwebtoken.io.Decoders;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.oauth2.jwt.NimbusReactiveJwtDecoder;
import org.springframework.security.oauth2.jwt.ReactiveJwtDecoder;

import javax.crypto.spec.SecretKeySpec;

@Configuration
public class JwtDecoderConfig {

    @Bean
    public ReactiveJwtDecoder reactiveJwtDecoder(
            @Value("${jwt.secret:}") String base64Secret
    ) {
        if (base64Secret == null || base64Secret.isBlank()) {
            throw new IllegalStateException("Missing jwt.secret for gateway (HS256).");
        }
        byte[] keyBytes = Decoders.BASE64.decode(base64Secret);
        var key = new SecretKeySpec(keyBytes, "HmacSHA256");
        return NimbusReactiveJwtDecoder.withSecretKey(key).build();
    }
}
