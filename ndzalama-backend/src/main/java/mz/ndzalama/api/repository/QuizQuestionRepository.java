package mz.ndzalama.api.repository;

import mz.ndzalama.api.model.QuizQuestion;
import org.springframework.data.jpa.repository.JpaRepository;

// Handles quiz question persistence.
public interface QuizQuestionRepository
        extends JpaRepository<QuizQuestion, Long> {
}
