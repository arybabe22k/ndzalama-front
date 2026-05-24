package mz.ndzalama.api.dto.gamification;

// Response used to show user's gamification profile.
public class GamificationProfileResponse {

    private Integer level;
    private Integer points;
    private Integer nextLevelPoints;
    private Integer progress;
    private Integer streakDays;

    public GamificationProfileResponse() {
    }

    public GamificationProfileResponse(
            Integer level,
            Integer points,
            Integer nextLevelPoints,
            Integer progress,
            Integer streakDays
    ) {
        this.level = level;
        this.points = points;
        this.nextLevelPoints = nextLevelPoints;
        this.progress = progress;
        this.streakDays = streakDays;
    }

    public Integer getLevel() {
        return level;
    }

    public Integer getPoints() {
        return points;
    }

    public Integer getNextLevelPoints() {
        return nextLevelPoints;
    }

    public Integer getProgress() {
        return progress;
    }

    public Integer getStreakDays() {
        return streakDays;
    }

    public void setLevel(Integer level) {
        this.level = level;
    }

    public void setPoints(Integer points) {
        this.points = points;
    }

    public void setNextLevelPoints(Integer nextLevelPoints) {
        this.nextLevelPoints = nextLevelPoints;
    }

    public void setProgress(Integer progress) {
        this.progress = progress;
    }

    public void setStreakDays(Integer streakDays) {
        this.streakDays = streakDays;
    }
}