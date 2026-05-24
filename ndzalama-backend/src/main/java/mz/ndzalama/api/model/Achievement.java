package mz.ndzalama.api.model;

import jakarta.persistence.*;

import java.time.LocalDateTime;

// Represents a badge or achievement earned by a user.
@Entity
@Table(name = "achievements")
public class Achievement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // User who earned the achievement
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    // Example: FRAUD_HUNTER, SMART_SAVER, SECURITY_BEGINNER
    private String code;

    private String title;

    private String description;

    private LocalDateTime earnedAt = LocalDateTime.now();

    public Achievement() {
    }

    public Long getId() {
        return id;
    }

    public User getUser() {
        return user;
    }

    public String getCode() {
        return code;
    }

    public String getTitle() {
        return title;
    }

    public String getDescription() {
        return description;
    }

    public LocalDateTime getEarnedAt() {
        return earnedAt;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public void setEarnedAt(LocalDateTime earnedAt) {
        this.earnedAt = earnedAt;
    }
}
