package mz.ndzalama.api.controller;

import mz.ndzalama.api.dto.education.LearningPathResponse;
import mz.ndzalama.api.service.LearningPathService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

// Handles learning path endpoints.
@RestController
@RequestMapping("/api/v1/education/learning-paths")
public class LearningPathController {

    private final LearningPathService learningPathService;

    public LearningPathController(LearningPathService learningPathService) {
        this.learningPathService = learningPathService;
    }

    // Returns all learning paths and whether they are unlocked for the user.
    @GetMapping
    public ResponseEntity<List<LearningPathResponse>> getLearningPaths(
            Authentication authentication
    ) {
        return ResponseEntity.ok(
                learningPathService.getLearningPaths(authentication)
        );
    }
}
