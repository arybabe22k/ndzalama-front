package mz.ndzalama.api.repository;

import mz.ndzalama.api.model.QuizResult;
import org.springframework.data.jpa.repository.JpaRepository;

// Handles quiz result persistence.
public interface QuizResultRepository
        extends JpaRepository<QuizResult, Long> {
}
