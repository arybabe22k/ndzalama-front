package mz.ndzalama.api.repository;

import mz.ndzalama.api.model.FraudReport;
import mz.ndzalama.api.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

// Handles database operations for fraud reports.
public interface FraudReportRepository extends JpaRepository<FraudReport, Long> {

    List<FraudReport> findByUserOrderByCreatedAtDesc(User user);
}
