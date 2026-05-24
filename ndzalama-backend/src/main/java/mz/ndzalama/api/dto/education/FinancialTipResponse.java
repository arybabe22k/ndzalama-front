package mz.ndzalama.api.dto.education;

// Response used to return financial education tips.
public class FinancialTipResponse {

    private String category;
    private String title;
    private String message;
    private String action;

    public FinancialTipResponse() {
    }

    public FinancialTipResponse(
            String category,
            String title,
            String message,
            String action
    ) {
        this.category = category;
        this.title = title;
        this.message = message;
        this.action = action;
    }

    public String getCategory() {
        return category;
    }

    public String getTitle() {
        return title;
    }

    public String getMessage() {
        return message;
    }

    public String getAction() {
        return action;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public void setAction(String action) {
        this.action = action;
    }
}
