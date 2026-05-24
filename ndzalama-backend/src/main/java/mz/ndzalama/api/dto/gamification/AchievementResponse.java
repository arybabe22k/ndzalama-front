package mz.ndzalama.api.dto.gamification;

import java.time.LocalDateTime;

// Response used to show achievements earned by the user.
public class AchievementResponse {

    private Long id;
    private String code;
    private String title;
    private String description;
    private LocalDateTime earnedAt;

    public AchievementResponse() {
    }

    public AchievementResponse(
            Long id,
            String code,
            String title,
            String description,
            LocalDateTime earnedAt
    ) {
        this.id = id;
        this.code = code;
        this.title = title;
        this.description = description;
        this.earnedAt = earnedAt;
    }

    public Long getId() {
        return id;
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
