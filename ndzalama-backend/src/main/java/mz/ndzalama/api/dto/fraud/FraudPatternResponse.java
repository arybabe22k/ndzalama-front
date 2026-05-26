package mz.ndzalama.api.dto.fraud;

import java.time.LocalDateTime;

// Response used to expose fraud learning patterns.
public class FraudPatternResponse {

    private Long id;
    private String patternType;
    private String patternText;
    private String description;
    private Integer riskWeight;
    private Boolean active;
    private LocalDateTime createdAt;

    public FraudPatternResponse() {
    }

    public FraudPatternResponse(
            Long id,
            String patternType,
            String patternText,
            String description,
            Integer riskWeight,
            Boolean active,
            LocalDateTime createdAt
    ) {
        this.id = id;
        this.patternType = patternType;
        this.patternText = patternText;
        this.description = description;
        this.riskWeight = riskWeight;
        this.active = active;
        this.createdAt = createdAt;
    }

    public Long getId() {
        return id;
    }

    public String getPatternType() {
        return patternType;
    }

    public String getPatternText() {
        return patternText;
    }

    public String getDescription() {
        return description;
    }

    public Integer getRiskWeight() {
        return riskWeight;
    }

    public Boolean getActive() {
        return active;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public void setPatternType(String patternType) {
        this.patternType = patternType;
    }

    public void setPatternText(String patternText) {
        this.patternText = patternText;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public void setRiskWeight(Integer riskWeight) {
        this.riskWeight = riskWeight;
    }

    public void setActive(Boolean active) {
        this.active = active;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
