package mz.ndzalama.api.model;

import jakarta.persistence.*;

import java.time.LocalDate;
import java.time.LocalDateTime;

// Represents a system user.
// This entity will be mapped to the "users" table.
@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(unique = true, nullable = false, length = 20)
    private String phone;

    @Column(unique = true, length = 120)
    private String email;

    @Column(nullable = false)
    private String password;

    @Column(name = "monthly_goal")
    private Integer monthlyGoal = 0;

    private Integer points = 0;

    private Integer level = 1;

    @Column(name = "streak_days")
    private Integer streakDays = 0;

    // Last day the user performed an activity.
    @Column(name = "last_active_date")
    private LocalDate lastActiveDate;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    public User() {
    }

    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getPhone() {
        return phone;
    }

    public String getEmail() {
        return email;
    }

    public String getPassword() {
        return password;
    }

    public Integer getMonthlyGoal() {
        return monthlyGoal;
    }

    public Integer getPoints() {
        return points;
    }

    public Integer getLevel() {
        return level;
    }

    public Integer getStreakDays() {
        return streakDays;
    }

    public LocalDate getLastActiveDate() {
        return lastActiveDate;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public void setMonthlyGoal(Integer monthlyGoal) {
        this.monthlyGoal = monthlyGoal;
    }

    public void setPoints(Integer points) {
        this.points = points;
    }

    public void setLevel(Integer level) {
        this.level = level;
    }

    public void setStreakDays(Integer streakDays) {
        this.streakDays = streakDays;
    }

    public void setLastActiveDate(LocalDate lastActiveDate) {
        this.lastActiveDate = lastActiveDate;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}