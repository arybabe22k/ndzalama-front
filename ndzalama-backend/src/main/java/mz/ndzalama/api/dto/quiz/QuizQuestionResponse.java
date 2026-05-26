package mz.ndzalama.api.dto.quiz;

import java.util.List;

// Response used to show quiz questions without exposing the correct answer.
public class QuizQuestionResponse {

    private Long id;
    private String question;
    private String category;
    private List<QuizOptionResponse> options;

    public QuizQuestionResponse() {
    }

    public QuizQuestionResponse(Long id, String question, String category, List<QuizOptionResponse> options) {
        this.id = id;
        this.question = question;
        this.category = category;
        this.options = options;
    }

    public Long getId() {
        return id;
    }

    public String getQuestion() {
        return question;
    }

    public String getCategory() {
        return category;
    }

    public List<QuizOptionResponse> getOptions() {
        return options;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public void setQuestion(String question) {
        this.question = question;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public void setOptions(List<QuizOptionResponse> options) {
        this.options = options;
    }
}
