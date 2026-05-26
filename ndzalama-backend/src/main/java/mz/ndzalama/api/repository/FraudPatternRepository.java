package mz.ndzalama.api.repository;

import mz.ndzalama.api.model.FraudPattern;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

// Handles database operations for fraud learning patterns.
public interface FraudPatternRepository extends JpaRepository<FraudPattern, Long> {

    List<FraudPattern> findByActiveTrueOrderByCreatedAtDesc();

    List<FraudPattern> findByPatternTypeAndActiveTrue(String patternType);
}
