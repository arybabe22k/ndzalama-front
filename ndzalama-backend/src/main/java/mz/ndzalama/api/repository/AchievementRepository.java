package mz.ndzalama.api.repository;

import mz.ndzalama.api.model.Achievement;
import mz.ndzalama.api.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

// Handles database operations for user achievements.
public interface AchievementRepository extends JpaRepository<Achievement, Long> {

    boolean existsByUserAndCode(User user, String code);

    List<Achievement> findByUserOrderByEarnedAtDesc(User user);
}
