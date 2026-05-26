package mz.ndzalama.api.model;

import jakarta.persistence.*;

import java.time.LocalDateTime;

// Stores reusable fraud patterns for future learning and AI improvement.
@Entity
@Table(name = "fraud_patterns")
public class FraudPattern {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Example: BONUS_SCAM, ROMANCE_SCAM, FAKE_LOAN, CRYPTO_SCAM
    @Column(nullable = false)
    private String patternType;

    // Example phrase or suspicious content pattern
    @Column(columnDefinition = "TEXT", nullable = false)
    private String patternText;

    // Human-readable explanation
    @Column(columnDefinition = "TEXT")
    private String description;

    // Risk weight from 1 to 100
    private Integer riskWeight;

    private Boolean active = true;

    private LocalDateTime createdAt = LocalDateTime.now();

    public FraudPattern() {
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
