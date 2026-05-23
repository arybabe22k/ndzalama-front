package mz.ndzalama.api.controller;

import jakarta.validation.Valid;

import mz.ndzalama.api.dto.auth.LoginRequest;
import mz.ndzalama.api.dto.auth.RegisterRequest;
import mz.ndzalama.api.dto.auth.TokenResponse;
import mz.ndzalama.api.service.AuthService;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

// Handles authentication endpoints.
@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    // Registers a new user.
    @PostMapping("/register")
    public ResponseEntity<TokenResponse> register(
            @Valid @RequestBody RegisterRequest request
    ) {
        return ResponseEntity.ok(authService.register(request));
    }

    // Logs in an existing user.
    @PostMapping("/login")
    public ResponseEntity<TokenResponse> login(
            @Valid @RequestBody LoginRequest request
    ) {
        return ResponseEntity.ok(authService.login(request));
    }
}
