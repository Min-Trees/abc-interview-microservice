package com.abc.gateway_service.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.cloud.gateway.filter.ratelimit.KeyResolver;
import reactor.core.publisher.Mono;

@Configuration
public class GatewayConfig {

    @Bean
    public KeyResolver remoteAddrKeyResolver() {
        return exchange -> {
            var addr = exchange.getRequest().getRemoteAddress();
            String ip = (addr != null && addr.getAddress() != null) ? addr.getAddress().getHostAddress() : "unknown";
            return Mono.just(ip);
        };
    }
}
