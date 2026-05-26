package mz.ndzalama.api.model;

import jakarta.persistence.*;

// Represents a possible answer option.
@Entity
@Table(name = "quiz_options")
public class QuizOption {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Option text
    @Column(nullable = false)
    private String text;

    // Indicates if option is correct
    @Column(name = "is_correct")
    private Boolean correct = false;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "question_id")
    private QuizQuestion question;

    public QuizOption() {
    }

    public Long getId() {
        return id;
    }

    public String getText() {
        return text;
    }

    public Boolean getCorrect() {
        return correct;
    }

    public QuizQuestion getQuestion() {
        return question;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public void setText(String text) {
        this.text = text;
    }

    public void setCorrect(Boolean correct) {
        this.correct = correct;
    }

    public void setQuestion(QuizQuestion question) {
        this.question = question;
    }
}
