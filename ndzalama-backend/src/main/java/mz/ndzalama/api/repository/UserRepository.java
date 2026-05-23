package mz.ndzalama.api.repository;

import mz.ndzalama.api.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

// Handles database operations related to users.
public interface UserRepository extends JpaRepository<User, Long> {

    // Find user by phone number
    Optional<User> findByPhone(String phone);

    // Check if phone already exists
    boolean existsByPhone(String phone);
}