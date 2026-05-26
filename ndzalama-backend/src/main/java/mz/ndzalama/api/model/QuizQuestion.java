package mz.ndzalama.api.model;

import jakarta.persistence.*;

import java.util.ArrayList;
import java.util.List;

// Represents a quiz question.
@Entity
@Table(name = "quiz_questions")
public class QuizQuestion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Quiz question text
    @Column(nullable = false, length = 500)
    private String question;

    // Educational explanation
    @Column(length = 1000)
    private String explanation;

    // Quiz category
    private String category;

    // Available options
    @OneToMany(
            mappedBy = "question",
            cascade = CascadeType.ALL,
            orphanRemoval = true,
            fetch = FetchType.EAGER
    )
    private List<QuizOption> options = new ArrayList<>();

    public QuizQuestion() {
    }

    public Long getId() {
        return id;
    }

    public String getQuestion() {
        return question;
    }

    public String getExplanation() {
        return explanation;
    }

    public String getCategory() {
        return category;
    }

    public List<QuizOption> getOptions() {
        return options;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public void setQuestion(String question) {
        this.question = question;
    }

    public void setExplanation(String explanation) {
        this.explanation = explanation;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public void setOptions(List<QuizOption> options) {
        this.options = options;
    }
}
