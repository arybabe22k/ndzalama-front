package mz.ndzalama.api.service;

import mz.ndzalama.api.dto.quiz.*;
import mz.ndzalama.api.model.*;
import mz.ndzalama.api.repository.QuizQuestionRepository;
import mz.ndzalama.api.repository.QuizResultRepository;
import mz.ndzalama.api.repository.UserRepository;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

// Handles quiz logic, scoring and educational feedback.
@Service
public class QuizService {

    private final QuizQuestionRepository quizQuestionRepository;
    private final QuizResultRepository quizResultRepository;
    private final UserRepository userRepository;
    private final GamificationService gamificationService;

    public QuizService(
            QuizQuestionRepository quizQuestionRepository,
            QuizResultRepository quizResultRepository,
            UserRepository userRepository,
            GamificationService gamificationService
    ) {
        this.quizQuestionRepository = quizQuestionRepository;
        this.quizResultRepository = quizResultRepository;
        this.userRepository = userRepository;
        this.gamificationService = gamificationService;
    }

    // Returns all quiz questions.
    public List<QuizQuestionResponse> getQuestions() {

        List<QuizQuestion> questions = quizQuestionRepository.findAll();

        List<QuizQuestionResponse> response = new ArrayList<>();

        for (QuizQuestion question : questions) {

            List<QuizOptionResponse> options = new ArrayList<>();

            for (QuizOption option : question.getOptions()) {
                options.add(
                        new QuizOptionResponse(
                                option.getId(),
                                option.getText()
                        )
                );
            }

            response.add(
                    new QuizQuestionResponse(
                            question.getId(),
                            question.getQuestion(),
                            question.getCategory(),
                            options
                    )
            );
        }

        return response;
    }

    // Evaluates submitted answer and rewards user.
    public QuizSubmitResponse submitAnswer(
            QuizSubmitRequest request,
            Authentication authentication
    ) {

        User user = getAuthenticatedUser(authentication);

        QuizQuestion question =
                quizQuestionRepository.findById(request.getQuestionId())
                        .orElseThrow(() ->
                                new RuntimeException("Question not found.")
                        );

        QuizOption selectedOption = null;

        for (QuizOption option : question.getOptions()) {
            if (option.getId().equals(request.getSelectedOptionId())) {
                selectedOption = option;
                break;
            }
        }

        if (selectedOption == null) {
            throw new RuntimeException("Selected option not found.");
        }

        boolean correct = Boolean.TRUE.equals(selectedOption.getCorrect());

        QuizResult result = new QuizResult();
        result.setUser(user);
        result.setQuestion(question);
        result.setSelectedOption(selectedOption);
        result.setCorrect(correct);

        quizResultRepository.save(result);

        int pointsEarned = correct ? 5 : 0;

        if (pointsEarned > 0) {
            gamificationService.addPoints(user, pointsEarned);
        }

        return new QuizSubmitResponse(
                correct,
                question.getExplanation(),
                pointsEarned
        );
    }

    private User getAuthenticatedUser(Authentication authentication) {

        String userId = authentication.getName();

        return userRepository.findById(Long.parseLong(userId))
                .orElseThrow(() ->
                        new RuntimeException("Authenticated user not found.")
                );
    }
}
