package mz.ndzalama.api.dto.quiz;

// Response used to show quiz answer options.
public class QuizOptionResponse {

    private Long id;
    private String text;

    public QuizOptionResponse() {
    }

    public QuizOptionResponse(Long id, String text) {
        this.id = id;
        this.text = text;
    }

    public Long getId() {
        return id;
    }

    public String getText() {
        return text;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public void setText(String text) {
        this.text = text;
    }
}
