package mz.ndzalama.api.service;

import mz.ndzalama.api.dto.education.LearningPathResponse;
import mz.ndzalama.api.model.LearningPath;
import mz.ndzalama.api.model.User;
import mz.ndzalama.api.repository.LearningPathRepository;
import mz.ndzalama.api.repository.UserRepository;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

// Handles learning path business logic.
@Service
public class LearningPathService {

    private final LearningPathRepository learningPathRepository;
    private final UserRepository userRepository;

    public LearningPathService(
            LearningPathRepository learningPathRepository,
            UserRepository userRepository
    ) {
        this.learningPathRepository = learningPathRepository;
        this.userRepository = userRepository;
    }

    // Returns all learning paths with unlock status.
    public List<LearningPathResponse> getLearningPaths(Authentication authentication) {

        User user = getAuthenticatedUser(authentication);

        int userPoints = user.getPoints() == null ? 0 : user.getPoints();

        List<LearningPath> paths =
                learningPathRepository.findAllByOrderByLevelAsc();

        List<LearningPathResponse> response = new ArrayList<>();

        for (LearningPath path : paths) {
            boolean unlocked = userPoints >= path.getRequiredPoints();

            response.add(new LearningPathResponse(
                    path.getId(),
                    path.getTitle(),
                    path.getDescription(),
                    path.getLevel(),
                    path.getRequiredPoints(),
                    path.getIcon(),
                    unlocked
            ));
        }

        return response;
    }

    private User getAuthenticatedUser(Authentication authentication) {

        String userId = authentication.getName();

        return userRepository.findById(Long.parseLong(userId))
                .orElseThrow(() ->
                        new RuntimeException("Authenticated user not found.")
                );
    }
}
