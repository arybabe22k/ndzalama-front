package mz.ndzalama.api.controller;

import mz.ndzalama.api.dto.gamification.AchievementResponse;
import mz.ndzalama.api.dto.gamification.GamificationProfileResponse;
import mz.ndzalama.api.service.GamificationService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

// Handles gamification endpoints.
@RestController
@RequestMapping("/api/v1/gamification")
public class GamificationController {

    private final GamificationService gamificationService;

    public GamificationController(GamificationService gamificationService) {
        this.gamificationService = gamificationService;
    }

    // Returns authenticated user's level, points and progress.
    @GetMapping("/profile")
    public ResponseEntity<GamificationProfileResponse> getProfile(
            Authentication authentication
    ) {
        return ResponseEntity.ok(
                gamificationService.getProfile(authentication)
        );
    }

    // Returns authenticated user's achievements.
    @GetMapping("/achievements")
    public ResponseEntity<List<AchievementResponse>> getAchievements(
            Authentication authentication
    ) {
        return ResponseEntity.ok(
                gamificationService.getAchievements(authentication)
        );
    }
}
