package mz.ndzalama.api.dto.education;

// Response used to show a financial education learning path.
public class LearningPathResponse {

    private Long id;
    private String title;
    private String description;
    private Integer level;
    private Integer requiredPoints;
    private String icon;
    private Boolean unlocked;

    public LearningPathResponse() {
    }

    public LearningPathResponse(
            Long id,
            String title,
            String description,
            Integer level,
            Integer requiredPoints,
            String icon,
            Boolean unlocked
    ) {
        this.id = id;
        this.title = title;
        this.description = description;
        this.level = level;
        this.requiredPoints = requiredPoints;
        this.icon = icon;
        this.unlocked = unlocked;
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

    public Boolean getUnlocked() {
        return unlocked;
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

    public void setUnlocked(Boolean unlocked) {
        this.unlocked = unlocked;
    }
}
