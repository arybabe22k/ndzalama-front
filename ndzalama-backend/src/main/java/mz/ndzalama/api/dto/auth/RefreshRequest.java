package mz.ndzalama.api.dto.auth;

// Used to request a new access token.
public class RefreshRequest {

    private String refreshToken;

    public RefreshRequest() {
    }

    public String getRefreshToken() {
        return refreshToken;
    }

    public void setRefreshToken(String refreshToken) {
        this.refreshToken = refreshToken;
    }
}

