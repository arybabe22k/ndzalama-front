package mz.ndzalama.api.model;

import jakarta.persistence.*;

import java.time.LocalDateTime;

// Stores quiz results from users.
@Entity
@Table(name = "quiz_results")
public class QuizResult {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // User who answered
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    // Question answered
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "question_id")
    private QuizQuestion question;

    // Selected option
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "selected_option_id")
    private QuizOption selectedOption;

    // Whether answer was correct
    private Boolean correct;

    private LocalDateTime answeredAt = LocalDateTime.now();

    public QuizResult() {
    }

    public Long getId() {
        return id;
    }

    public User getUser() {
        return user;
    }

    public QuizQuestion getQuestion() {
        return question;
    }

    public QuizOption getSelectedOption() {
        return selectedOption;
    }

    public Boolean getCorrect() {
        return correct;
    }

    public LocalDateTime getAnsweredAt() {
        return answeredAt;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public void setQuestion(QuizQuestion question) {
        this.question = question;
    }

    public void setSelectedOption(QuizOption selectedOption) {
        this.selectedOption = selectedOption;
    }

    public void setCorrect(Boolean correct) {
        this.correct = correct;
    }

    public void setAnsweredAt(LocalDateTime answeredAt) {
        this.answeredAt = answeredAt;
    }
}
