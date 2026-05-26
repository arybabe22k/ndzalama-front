package mz.ndzalama.api.controller;

import jakarta.validation.Valid;
import mz.ndzalama.api.dto.quiz.QuizQuestionResponse;
import mz.ndzalama.api.dto.quiz.QuizSubmitRequest;
import mz.ndzalama.api.dto.quiz.QuizSubmitResponse;
import mz.ndzalama.api.service.QuizService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

// Handles quiz endpoints.
@RestController
@RequestMapping("/api/v1/quizzes")
public class QuizController {

    private final QuizService quizService;

    public QuizController(QuizService quizService) {
        this.quizService = quizService;
    }

    // Returns all available quiz questions.
    @GetMapping
    public ResponseEntity<List<QuizQuestionResponse>> getQuestions() {
        return ResponseEntity.ok(
                quizService.getQuestions()
        );
    }

    // Submits an answer and returns feedback.
    @PostMapping("/submit")
    public ResponseEntity<QuizSubmitResponse> submitAnswer(
            @Valid @RequestBody QuizSubmitRequest request,
            Authentication authentication
    ) {
        return ResponseEntity.ok(
                quizService.submitAnswer(request, authentication)
        );
    }
}
