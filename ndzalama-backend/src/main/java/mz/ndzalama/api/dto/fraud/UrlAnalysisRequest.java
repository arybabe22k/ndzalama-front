package mz.ndzalama.api.dto.fraud;

import jakarta.validation.constraints.NotBlank;

// Request used for URL fraud analysis.
public class UrlAnalysisRequest {

    @NotBlank
    private String url;

    public UrlAnalysisRequest() {
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }
}
