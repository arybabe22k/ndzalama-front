package mz.ndzalama.api.controller;

import jakarta.validation.Valid;
import mz.ndzalama.api.dto.fraud.FraudPatternRequest;
import mz.ndzalama.api.dto.fraud.FraudPatternResponse;
import mz.ndzalama.api.service.FraudPatternService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

// Handles fraud learning pattern endpoints.
@RestController
@RequestMapping("/api/v1/fraud-patterns")
public class FraudPatternController {

    private final FraudPatternService fraudPatternService;

    public FraudPatternController(FraudPatternService fraudPatternService) {
        this.fraudPatternService = fraudPatternService;
    }

    // Creates a new fraud learning pattern.
    @PostMapping
    public ResponseEntity<FraudPatternResponse> create(
            @Valid @RequestBody FraudPatternRequest request
    ) {
        return ResponseEntity.ok(
                fraudPatternService.create(request)
        );
    }

    // Lists all active fraud learning patterns.
    @GetMapping
    public ResponseEntity<List<FraudPatternResponse>> getActivePatterns() {
        return ResponseEntity.ok(
                fraudPatternService.getActivePatterns()
        );
    }

    // Deactivates a fraud learning pattern.
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deactivate(
            @PathVariable Long id
    ) {
        fraudPatternService.deactivate(id);
        return ResponseEntity.noContent().build();
    }
}