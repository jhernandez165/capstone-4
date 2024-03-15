package com.aline.core.security.config;

import com.aline.core.config.DisableSecurityConfig;
import io.jsonwebtoken.security.Keys;
import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import javax.annotation.PostConstruct;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;

/**
 * JWT Configuration class is used to inject
 * variable fields such as secret key into a
 * requesting bean.
 */
@Getter
@Setter
@ConfigurationProperties(prefix = "app.security.jwt")
@ConditionalOnMissingBean(DisableSecurityConfig.class)
public class JwtConfig {
    

    @PostConstruct
    public void logSecretKey() {
        System.out.println("JWT Secret Key: " + secretKey); // For debugging purposes only
    }
    
    /**
     * JWT Secret Key
     */
    private String secretKey ;
    /**
     * Token prefix
     */
    private String tokenPrefix = "Bearer";
    /**
     * The number of days the token will expire after
     */
    private int tokenExpirationAfterDays = 14;

    // JWT Secret Key bean
    @Bean(name = "jwtSecretKey")
    public SecretKey jwtSecretKey() {
        String hardcodedSecretKey = "8RbnJKvEnaBqUtKP/oBZfSkxMni7O/R65EhPJCGDEVI="; // For debugging only
        return Keys.hmacShaKeyFor(hardcodedSecretKey.getBytes(StandardCharsets.UTF_8));
}


}
