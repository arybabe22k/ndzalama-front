package mz.ndzalama.api.service;

import mz.ndzalama.api.model.Achievement;
import mz.ndzalama.api.model.User;
import mz.ndzalama.api.repository.AchievementRepository;
import org.springframework.stereotype.Service;

import java.util.List;

// Handles badges and achievements earned by users.
@Service
public class AchievementService {

    private final AchievementRepository achievementRepository;

    public AchievementService(AchievementRepository achievementRepository) {
        this.achievementRepository = achievementRepository;
    }

    // Awards an achievement only if the user does not already have it.
    public void awardIfNotExists(
            User user,
            String code,
            String title,
            String description
    ) {
        if (achievementRepository.existsByUserAndCode(user, code)) {
            return;
        }

        Achievement achievement = new Achievement();
        achievement.setUser(user);
        achievement.setCode(code);
        achievement.setTitle(title);
        achievement.setDescription(description);

        achievementRepository.save(achievement);
    }

    // Returns all achievements earned by a user.
    public List<Achievement> getUserAchievements(User user) {
        return achievementRepository.findByUserOrderByEarnedAtDesc(user);
    }
}
