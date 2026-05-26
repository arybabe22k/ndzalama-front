package mz.ndzalama.api.service;

import mz.ndzalama.api.dto.gamification.AchievementResponse;
import mz.ndzalama.api.dto.gamification.GamificationProfileResponse;
import mz.ndzalama.api.model.Achievement;
import mz.ndzalama.api.model.User;
import mz.ndzalama.api.repository.UserRepository;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import java.time.LocalDate;

import java.util.ArrayList;
import java.util.List;

// Handles user points, levels, achievements and gamification progress.
@Service
public class GamificationService {

    private final UserRepository userRepository;
    private final AchievementService achievementService;

    public GamificationService(
            UserRepository userRepository,
            AchievementService achievementService
    ) {
        this.userRepository = userRepository;
        this.achievementService = achievementService;
    }

    // Adds points to a user and recalculates level.
    public void addPoints(User user, int pointsToAdd) {

        int currentPoints = safe(user.getPoints());
        int newPoints = currentPoints + pointsToAdd;

        user.setPoints(newPoints);
        user.setLevel(calculateLevel(newPoints));

        updateStreak(user);
        userRepository.save(user);

        // Awards badges after updating points and level.
        awardAchievements(user);
    }

    // Returns authenticated user's gamification profile.
    public GamificationProfileResponse getProfile(Authentication authentication) {

        User user = getAuthenticatedUser(authentication);

        int points = safe(user.getPoints());
        int level = safe(user.getLevel());
        int nextLevelPoints = calculateNextLevelPoints(points);
        int progress = calculateProgress(points);
        int streakDays = safe(user.getStreakDays());

        return new GamificationProfileResponse(
                level,
                points,
                nextLevelPoints,
                progress,
                streakDays
        );
    }

    // Returns authenticated user's achievements.
    public List<AchievementResponse> getAchievements(Authentication authentication) {

        User user = getAuthenticatedUser(authentication);

        List<Achievement> achievements =
                achievementService.getUserAchievements(user);

        List<AchievementResponse> response = new ArrayList<>();

        for (Achievement achievement : achievements) {
            response.add(new AchievementResponse(
                    achievement.getId(),
                    achievement.getCode(),
                    achievement.getTitle(),
                    achievement.getDescription(),
                    achievement.getEarnedAt()
            ));
        }

        return response;
    }

    // Awards automatic achievements based on points and level.
    private void awardAchievements(User user) {

        if (safe(user.getPoints()) >= 10) {
            achievementService.awardIfNotExists(
                    user,
                    "FRAUD_BEGINNER",
                    "Primeiro Alerta",
                    "Analisou a sua primeira mensagem suspeita."
            );
        }

        if (safe(user.getPoints()) >= 50) {
            achievementService.awardIfNotExists(
                    user,
                    "FRAUD_HUNTER",
                    "Caçador de Fraudes",
                    "Acumulou 50 pontos a proteger-se de fraudes."
            );
        }

        if (safe(user.getPoints()) >= 100) {
            achievementService.awardIfNotExists(
                    user,
                    "SECURITY_GUARDIAN",
                    "Guardião Financeiro",
                    "Alcançou 100 pontos em segurança financeira."
            );
        }

        if (safe(user.getLevel()) >= 3) {
            achievementService.awardIfNotExists(
                    user,
                    "LEVEL_3",
                    "Utilizador Experiente",
                    "Chegou ao nível 3 no Ndzalama IA."
            );
        }

        if (safe(user.getStreakDays()) >= 3) {
            achievementService.awardIfNotExists(
                    user,
                    "STREAK_3",
                    "Consistência Inicial",
                    "Usou o Ndzalama IA durante 3 dias seguidos."
            );
        }

        if (safe(user.getStreakDays()) >= 7) {
            achievementService.awardIfNotExists(
                    user,
                    "STREAK_7",
                    "Semana Segura",
                    "Manteve uma sequência de 7 dias de actividade."
            );
        }
    }

    private User getAuthenticatedUser(Authentication authentication) {

        String userId = authentication.getName();

        return userRepository.findById(Long.parseLong(userId))
                .orElseThrow(() -> new RuntimeException("Authenticated user not found."));
    }

    private int calculateLevel(int points) {

        if (points >= 500) {
            return 5;
        }

        if (points >= 250) {
            return 4;
        }

        if (points >= 100) {
            return 3;
        }

        if (points >= 50) {
            return 2;
        }

        return 1;
    }

    private int calculateNextLevelPoints(int points) {

        if (points < 50) {
            return 50;
        }

        if (points < 100) {
            return 100;
        }

        if (points < 250) {
            return 250;
        }

        if (points < 500) {
            return 500;
        }

        return points;
    }

    private int calculateProgress(int points) {

        int currentLevelStart;
        int nextLevel;

        if (points < 50) {
            currentLevelStart = 0;
            nextLevel = 50;
        } else if (points < 100) {
            currentLevelStart = 50;
            nextLevel = 100;
        } else if (points < 250) {
            currentLevelStart = 100;
            nextLevel = 250;
        } else if (points < 500) {
            currentLevelStart = 250;
            nextLevel = 500;
        } else {
            return 100;
        }

        int earnedInLevel = points - currentLevelStart;
        int levelRange = nextLevel - currentLevelStart;

        return (earnedInLevel * 100) / levelRange;
    }

    private int safe(Integer value) {
        return value == null ? 0 : value;
    }

    // Updates user's daily activity streak.
    private void updateStreak(User user) {

        LocalDate today = LocalDate.now();
        LocalDate lastActiveDate = user.getLastActiveDate();

        if (lastActiveDate == null) {
            user.setStreakDays(1);
            user.setLastActiveDate(today);
            return;
        }

        if (lastActiveDate.isEqual(today)) {
            return;
        }

        if (lastActiveDate.plusDays(1).isEqual(today)) {
            user.setStreakDays(safe(user.getStreakDays()) + 1);
        } else {
            user.setStreakDays(1);
        }

        user.setLastActiveDate(today);
    }

}
