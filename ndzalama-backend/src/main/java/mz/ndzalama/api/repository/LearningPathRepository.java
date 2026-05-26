package mz.ndzalama.api.repository;

import mz.ndzalama.api.model.LearningPath;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

// Handles learning path persistence.
public interface LearningPathRepository
        extends JpaRepository<LearningPath, Long> {

    List<LearningPath> findAllByOrderByLevelAsc();
}
