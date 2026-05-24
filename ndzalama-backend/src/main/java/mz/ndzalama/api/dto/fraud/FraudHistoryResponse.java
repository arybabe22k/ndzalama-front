package mz.ndzalama.api.dto.fraud;

import java.time.LocalDateTime;

// Response used to return fraud analysis history.
public class FraudHistoryResponse {

    private Long id;
    private String content;
    private String sourceType;
    private String classification;
    private int riskScore;
    private String detectedSignals;
    private String advice;
    private LocalDateTime createdAt;

    public FraudHistoryResponse() {
    }

    public FraudHistoryResponse(
            Long id,
            String content,
            String sourceType,
            String classification,
            int riskScore,
            String detectedSignals,
            String advice,
            LocalDateTime createdAt
    ) {
        this.id = id;
        this.content = content;
        this.sourceType = sourceType;
        this.classification = classification;
        this.riskScore = riskScore;
        this.detectedSignals = detectedSignals;
        this.advice = advice;
        this.createdAt = createdAt;
    }

    public Long getId() {
        return id;
    }

    public String getContent() {
        return content;
    }

    public String getSourceType() {
        return sourceType;
    }

    public String getClassification() {
        return classification;
    }

    public int getRiskScore() {
        return riskScore;
    }

    public String getDetectedSignals() {
        return detectedSignals;
    }

    public String getAdvice() {
        return advice;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
}
