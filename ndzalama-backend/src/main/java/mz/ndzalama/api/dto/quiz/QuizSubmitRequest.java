package mz.ndzalama.api.dto.quiz;

import jakarta.validation.constraints.NotNull;

// Request used when user submits a quiz answer.
public class QuizSubmitRequest {

    @NotNull
    private Long questionId;

    @NotNull
    private Long selectedOptionId;

    public QuizSubmitRequest() {
    }

    public Long getQuestionId() {
        return questionId;
    }

    public Long getSelectedOptionId() {
        return selectedOptionId;
    }

    public void setQuestionId(Long questionId) {
        this.questionId = questionId;
    }

    public void setSelectedOptionId(Long selectedOptionId) {
        this.selectedOptionId = selectedOptionId;
    }
}
