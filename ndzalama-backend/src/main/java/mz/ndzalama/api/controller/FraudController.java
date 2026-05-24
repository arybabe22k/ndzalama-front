package mz.ndzalama.api.controller;

import jakarta.validation.Valid;
import mz.ndzalama.api.dto.fraud.FraudHistoryResponse;
import mz.ndzalama.api.dto.fraud.FraudRequest;
import mz.ndzalama.api.dto.fraud.FraudResult;
import mz.ndzalama.api.service.FraudService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

// Handles fraud detection endpoints.
@RestController
@RequestMapping("/api/v1/fraud")
public class FraudController {

    private final FraudService fraudService;

    public FraudController(FraudService fraudService) {
        this.fraudService = fraudService;
    }

    // Analyzes suspicious text and saves the result in user's history.
    @PostMapping("/analyze-text")
    public ResponseEntity<FraudResult> analyzeText(
            @Valid @RequestBody FraudRequest request,
            Authentication authentication
    ) {
        return ResponseEntity.ok(
                fraudService.analyzeAndSave(request, authentication)
        );
    }

    // Returns authenticated user's fraud analysis history.
    @GetMapping("/history")
    public ResponseEntity<List<FraudHistoryResponse>> getHistory(
            Authentication authentication
    ) {
        return ResponseEntity.ok(
                fraudService.getHistory(authentication)
        );
    }
}
