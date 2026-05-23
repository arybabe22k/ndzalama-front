package mz.ndzalama.api.service;

import mz.ndzalama.api.dto.auth.LoginRequest;
import mz.ndzalama.api.dto.auth.RegisterRequest;
import mz.ndzalama.api.dto.auth.TokenResponse;
import mz.ndzalama.api.model.User;
import mz.ndzalama.api.repository.UserRepository;
import mz.ndzalama.api.security.JwtUtil;

import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

// Handles authentication business logic.
@Service
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    public AuthService(
            UserRepository userRepository,
            PasswordEncoder passwordEncoder,
            JwtUtil jwtUtil
    ) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
    }

    // Registers a new user.
    public TokenResponse register(RegisterRequest request) {

        if (userRepository.existsByPhone(request.getPhone())) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "Phone number already registered."
            );
        }

        User user = new User();
        user.setName(request.getName());
        user.setPhone(request.getPhone());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setMonthlyGoal(0);
        user.setPoints(0);
        user.setLevel(1);
        user.setStreakDays(0);

        userRepository.save(user);

        return buildTokens(user);
    }

    // Authenticates an existing user.
    public TokenResponse login(LoginRequest request) {

        User user = userRepository.findByPhone(request.getPhone())
                .orElseThrow(() ->
                        new ResponseStatusException(
                                HttpStatus.UNAUTHORIZED,
                                "Invalid credentials."
                        )
                );

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new ResponseStatusException(
                    HttpStatus.UNAUTHORIZED,
                    "Invalid credentials."
            );
        }

        return buildTokens(user);
    }

    // Builds JWT token response.
    private TokenResponse buildTokens(User user) {

        TokenResponse response = new TokenResponse();

        response.setAccessToken(jwtUtil.generateAccessToken(user.getId()));
        response.setRefreshToken(jwtUtil.generateRefreshToken(user.getId()));
        response.setUserId(user.getId());
        response.setName(user.getName());
        response.setLevel(user.getLevel());
        response.setPoints(user.getPoints());

        return response;
    }
}