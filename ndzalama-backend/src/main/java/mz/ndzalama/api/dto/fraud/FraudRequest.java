package mz.ndzalama.api.dto.fraud;

import jakarta.validation.constraints.NotBlank;

// Request body used to analyze suspicious fraud content.
public class FraudRequest {

    @NotBlank
    private String content;

    // Example: TEXT, LINK, IMAGE_OCR, SMS, WHATSAPP
    private String sourceType;

    public FraudRequest() {
    }

    public String getContent() {
        return content;
    }

    public String getSourceType() {
        return sourceType;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public void setSourceType(String sourceType) {
        this.sourceType = sourceType;
    }
}