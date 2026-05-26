package mz.ndzalama.api.dto.quiz;

// Response returned after submitting a quiz answer.
public class QuizSubmitResponse {

    private Boolean correct;
    private String explanation;
    private Integer pointsEarned;

    public QuizSubmitResponse() {
    }

    public QuizSubmitResponse(Boolean correct, String explanation, Integer pointsEarned) {
        this.correct = correct;
        this.explanation = explanation;
        this.pointsEarned = pointsEarned;
    }

    public Boolean getCorrect() {
        return correct;
    }

    public String getExplanation() {
        return explanation;
    }

    public Integer getPointsEarned() {
        return pointsEarned;
    }

    public void setCorrect(Boolean correct) {
        this.correct = correct;
    }

    public void setExplanation(String explanation) {
        this.explanation = explanation;
    }

    public void setPointsEarned(Integer pointsEarned) {
        this.pointsEarned = pointsEarned;
    }
}
