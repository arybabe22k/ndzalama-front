package mz.ndzalama.api.dto.fraud;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

// Request used to create a fraud learning pattern.
public class FraudPatternRequest {

    @NotBlank
    private String patternType;

    @NotBlank
    private String patternText;

    private String description;

    @NotNull
    private Integer riskWeight;

    public FraudPatternRequest() {
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
}
