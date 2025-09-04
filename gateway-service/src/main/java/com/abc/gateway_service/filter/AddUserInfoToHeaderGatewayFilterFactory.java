package com.abc.gateway_service.filter;

import org.springframework.cloud.gateway.filter.GatewayFilter;
import org.springframework.cloud.gateway.filter.factory.AbstractGatewayFilterFactory;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Mono;

@Component
public class AddUserInfoToHeaderGatewayFilterFactory extends AbstractGatewayFilterFactory<Object> {

    @Override
    public GatewayFilter apply(Object config) {
        return (exchange, chain) ->
                exchange.getPrincipal()
                        .cast(Authentication.class)
                        .flatMap(auth -> {
                            if (auth instanceof JwtAuthenticationToken jwt) {
                                String userId = jwt.getName(); // "sub"
                                ServerHttpRequest req = exchange.getRequest()
                                        .mutate()
                                        .header("X-User-Id", userId)
                                        .build();
                                return chain.filter(exchange.mutate().request(req).build());
                            }
                            return chain.filter(exchange);
                        })
                        .switchIfEmpty(chain.filter(exchange));
    }
}
