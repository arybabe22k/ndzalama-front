package mz.ndzalama.api.model;

import jakarta.persistence.*;

import java.time.LocalDateTime;

// Stores each fraud analysis made by a user.
@Entity
@Table(name = "fraud_reports")
public class FraudReport {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // User who made the analysis
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    // Original analyzed content
    @Column(columnDefinition = "TEXT")
    private String content;

    // TEXT, LINK, IMAGE_OCR, SMS, WHATSAPP
    private String sourceType;

    // FRAUD, SUSPICIOUS, LEGITIMATE
    private String classification;

    private int riskScore;

    @Column(columnDefinition = "TEXT")
    private String detectedSignals;

    @Column(columnDefinition = "TEXT")
    private String advice;

    private LocalDateTime createdAt = LocalDateTime.now();

    public FraudReport() {
    }

    public Long getId() {
        return id;
    }

    public User getUser() {
        return user;
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

    public void setId(Long id) {
        this.id = id;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public void setSourceType(String sourceType) {
        this.sourceType = sourceType;
    }

    public void setClassification(String classification) {
        this.classification = classification;
    }

    public void setRiskScore(int riskScore) {
        this.riskScore = riskScore;
    }

    public void setDetectedSignals(String detectedSignals) {
        this.detectedSignals = detectedSignals;
    }

    public void setAdvice(String advice) {
        this.advice = advice;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
