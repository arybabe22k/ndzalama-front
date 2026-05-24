package mz.ndzalama.api.dto.fraud;

import java.util.List;

// Response returned after fraud analysis.
public class FraudResult {

    private String classification;
    private int riskScore;
    private List<String> detectedSignals;
    private String advice;

    public FraudResult() {
    }

    public FraudResult(
            String classification,
            int riskScore,
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

    public int getRiskScore() {
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

    public void setRiskScore(int riskScore) {
        this.riskScore = riskScore;
    }

    public void setDetectedSignals(List<String> detectedSignals) {
        this.detectedSignals = detectedSignals;
    }

    public void setAdvice(String advice) {
        this.advice = advice;
    }
}
