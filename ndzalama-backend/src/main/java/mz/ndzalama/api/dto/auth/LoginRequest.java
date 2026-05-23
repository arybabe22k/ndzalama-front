package mz.ndzalama.api.dto.auth;

import jakarta.validation.constraints.NotBlank;

// Request body used during login.
public class LoginRequest {

    @NotBlank
    private String phone;

    @NotBlank
    private String password;

    public LoginRequest() {
    }

    public String getPhone() {
        return phone;
    }

    public String getPassword() {
        return password;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}