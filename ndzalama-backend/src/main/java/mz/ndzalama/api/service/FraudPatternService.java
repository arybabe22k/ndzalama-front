package mz.ndzalama.api.service;

import mz.ndzalama.api.dto.fraud.FraudPatternRequest;
import mz.ndzalama.api.dto.fraud.FraudPatternResponse;
import mz.ndzalama.api.model.FraudPattern;
import mz.ndzalama.api.repository.FraudPatternRepository;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

// Handles fraud learning patterns.
@Service
public class FraudPatternService {

    private final FraudPatternRepository fraudPatternRepository;

    public FraudPatternService(FraudPatternRepository fraudPatternRepository) {
        this.fraudPatternRepository = fraudPatternRepository;
    }

    // Creates a new fraud pattern.
    public FraudPatternResponse create(FraudPatternRequest request) {

        FraudPattern pattern = new FraudPattern();
        pattern.setPatternType(request.getPatternType());
        pattern.setPatternText(request.getPatternText());
        pattern.setDescription(request.getDescription());
        pattern.setRiskWeight(request.getRiskWeight());
        pattern.setActive(true);

        fraudPatternRepository.save(pattern);

        return toResponse(pattern);
    }

    // Returns all active fraud patterns.
    public List<FraudPatternResponse> getActivePatterns() {

        List<FraudPattern> patterns =
                fraudPatternRepository.findByActiveTrueOrderByCreatedAtDesc();

        List<FraudPatternResponse> response = new ArrayList<>();

        for (FraudPattern pattern : patterns) {
            response.add(toResponse(pattern));
        }

        return response;
    }

    // Deactivates a fraud pattern.
    public void deactivate(Long id) {

        FraudPattern pattern = fraudPatternRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Fraud pattern not found."));

        pattern.setActive(false);

        fraudPatternRepository.save(pattern);
    }

    private FraudPatternResponse toResponse(FraudPattern pattern) {

        return new FraudPatternResponse(
                pattern.getId(),
                pattern.getPatternType(),
                pattern.getPatternText(),
                pattern.getDescription(),
                pattern.getRiskWeight(),
                pattern.getActive(),
                pattern.getCreatedAt()
        );
    }
}
