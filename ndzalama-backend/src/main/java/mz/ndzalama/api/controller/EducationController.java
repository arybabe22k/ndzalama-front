package mz.ndzalama.api.controller;

import mz.ndzalama.api.dto.education.FinancialTipResponse;
import mz.ndzalama.api.service.EducationService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

// Handles financial education endpoints.
@RestController
@RequestMapping("/api/v1/education")
public class EducationController {

    private final EducationService educationService;

    public EducationController(EducationService educationService) {
        this.educationService = educationService;
    }

    // Returns one financial tip for the current day.
    @GetMapping("/daily-tip")
    public ResponseEntity<FinancialTipResponse> getDailyTip() {
        return ResponseEntity.ok(educationService.getDailyTip());
    }

    // Returns all financial education tips.
    @GetMapping("/tips")
    public ResponseEntity<List<FinancialTipResponse>> getAllTips() {
        return ResponseEntity.ok(educationService.getAllTips());
    }
}
