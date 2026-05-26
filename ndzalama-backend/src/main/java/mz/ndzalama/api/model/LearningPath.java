package mz.ndzalama.api.model;

import jakarta.persistence.*;

import java.time.LocalDateTime;

// Represents a financial education learning path.
@Entity
@Table(name = "learning_paths")
public class LearningPath {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Example: Beginner, Saver, Investor
    @Column(nullable = false, unique = true)
    private String title;

    // Path explanation
    @Column(columnDefinition = "TEXT")
    private String description;

    // Difficulty level
    @Column(nullable = false)
    private Integer level;

    // Required points to unlock
    @Column(nullable = false)
    private Integer requiredPoints;

    // Category icon
    private String icon;

    private LocalDateTime createdAt = LocalDateTime.now();

    public LearningPath() {
    }

    public Long getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public String getDescription() {
        return description;
    }

    public Integer getLevel() {
        return level;
    }

    public Integer getRequiredPoints() {
        return requiredPoints;
    }

    public String getIcon() {
        return icon;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public void setLevel(Integer level) {
        this.level = level;
    }

    public void setRequiredPoints(Integer requiredPoints) {
        this.requiredPoints = requiredPoints;
    }

    public void setIcon(String icon) {
        this.icon = icon;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
