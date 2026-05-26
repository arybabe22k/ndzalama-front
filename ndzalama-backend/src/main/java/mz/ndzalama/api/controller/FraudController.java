package mz.ndzalama.api.controller;

import jakarta.validation.Valid;
import mz.ndzalama.api.dto.fraud.FraudHistoryResponse;
import mz.ndzalama.api.dto.fraud.FraudRequest;
import mz.ndzalama.api.dto.fraud.FraudResult;
import mz.ndzalama.api.dto.fraud.UrlAnalysisRequest;
import mz.ndzalama.api.dto.fraud.UrlAnalysisResponse;
import mz.ndzalama.api.service.FraudService;
import mz.ndzalama.api.service.OcrService;
import mz.ndzalama.api.service.UrlReputationService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

// Handles fraud detection endpoints.
@RestController
@RequestMapping("/api/v1/fraud")
public class FraudController {

    private final FraudService fraudService;
    private final OcrService ocrService;
    private final UrlReputationService urlReputationService;

    public FraudController(
            FraudService fraudService,
            OcrService ocrService,
            UrlReputationService urlReputationService
    ) {
        this.fraudService = fraudService;
        this.ocrService = ocrService;
        this.urlReputationService = urlReputationService;
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

    // Extracts text from an image and analyzes it for fraud.
    @PostMapping("/analyze-image")
    public ResponseEntity<FraudResult> analyzeImage(
            @RequestParam("image") MultipartFile image,
            Authentication authentication
    ) {
        String extractedText = ocrService.extractText(image);

        FraudRequest request = new FraudRequest();
        request.setSourceType("IMAGE_OCR");
        request.setContent(extractedText);

        return ResponseEntity.ok(
                fraudService.analyzeAndSave(request, authentication)
        );
    }

    // Analyzes a suspicious URL.
    @PostMapping("/analyze-url")
    public ResponseEntity<UrlAnalysisResponse> analyzeUrl(
            @Valid @RequestBody UrlAnalysisRequest request
    ) {
        return ResponseEntity.ok(
                urlReputationService.analyze(request)
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
