package mz.ndzalama.api.security;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;

// Utility class responsible for:
// - generating JWT tokens
// - validating JWT tokens
// - extracting user information from tokens
@Component
public class JwtUtil {

    // Secret key defined in application.yml
    @Value("${jwt.secret}")
    private String secret;

    // Access token expiration time
    @Value("${jwt.access-expiration}")
    private long accessExpiration;

    // Refresh token expiration time
    @Value("${jwt.refresh-expiration}")
    private long refreshExpiration;

    // Generates the signing key used by JWT
    private SecretKey getKey() {
        return Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    }

    // Generates short-lived access token
    public String generateAccessToken(Long userId) {

        return Jwts.builder()
                .subject(userId.toString())
                .claim("type", "access")
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + accessExpiration))
                .signWith(getKey())
                .compact();
    }

    // Generates long-lived refresh token
    public String generateRefreshToken(Long userId) {

        return Jwts.builder()
                .subject(userId.toString())
                .claim("type", "refresh")
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + refreshExpiration))
                .signWith(getKey())
                .compact();
    }

    // Extracts the user ID from token
    public Long extractUserId(String token) {

        return Long.parseLong(
                Jwts.parser()
                        .verifyWith(getKey())
                        .build()
                        .parseSignedClaims(token)
                        .getPayload()
                        .getSubject()
        );
    }

    // Checks if token is valid
    public boolean isValid(String token) {

        try {
            extractUserId(token);
            return true;

        } catch (Exception e) {
            return false;
        }
    }
}