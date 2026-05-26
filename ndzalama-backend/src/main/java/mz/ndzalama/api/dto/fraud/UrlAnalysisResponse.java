package mz.ndzalama.api.dto.fraud;

import java.util.List;

// Response returned after URL fraud analysis.
public class UrlAnalysisResponse {

    private String classification;
    private Integer riskScore;
    private List<String> detectedSignals;
    private String advice;

    public UrlAnalysisResponse() {
    }

    public UrlAnalysisResponse(
            String classification,
            Integer riskScore,
            List<String> detectedSignals,
            String advice
    ) {
        this.classification = classification;
        this.riskScore = riskScore;
        this.detectedSignals = detectedSignals;
        this.advice = advice;
    }

    public String getClassification() {
        return classification;
    }

    public Integer getRiskScore() {
        return riskScore;
    }

    public List<String> getDetectedSignals() {
        return detectedSignals;
    }

    public String getAdvice() {
        return advice;
    }

    public void setClassification(String classification) {
        this.classification = classification;
    }

    public void setRiskScore(Integer riskScore) {
        this.riskScore = riskScore;
    }

    public void setDetectedSignals(List<String> detectedSignals) {
        this.detectedSignals = detectedSignals;
    }

    public void setAdvice(String advice) {
        this.advice = advice;
    }
}
