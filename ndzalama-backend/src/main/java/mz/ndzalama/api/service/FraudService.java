package mz.ndzalama.api.service;

import mz.ndzalama.api.dto.fraud.FraudHistoryResponse;
import mz.ndzalama.api.dto.fraud.FraudRequest;
import mz.ndzalama.api.dto.fraud.FraudResult;
import mz.ndzalama.api.model.FraudReport;
import mz.ndzalama.api.model.User;
import mz.ndzalama.api.repository.FraudReportRepository;
import mz.ndzalama.api.repository.UserRepository;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

// Service responsible for detecting fraud patterns and saving the analysis history.
@Service
public class FraudService {

    private final FraudReportRepository fraudReportRepository;
    private final UserRepository userRepository;

    private static final Pattern PHONE_NUMBER_PATTERN =
            Pattern.compile("(\\+258\\s?)?(8[2-7]\\d{7})");

    private static final Pattern SHORT_LINK_PATTERN =
            Pattern.compile("(bit\\.ly|tinyurl\\.com|t\\.co|wa\\.me|goo\\.gl|shorturl)");

    private static final Pattern ANY_LINK_PATTERN =
            Pattern.compile("(http://|https://|www\\.)");

    public FraudService(
            FraudReportRepository fraudReportRepository,
            UserRepository userRepository
    ) {
        this.fraudReportRepository = fraudReportRepository;
        this.userRepository = userRepository;
    }

    // Analyzes suspicious content and saves the report for the authenticated user.
    public FraudResult analyzeAndSave(FraudRequest request, Authentication authentication) {

        User user = getAuthenticatedUser(authentication);

        FraudResult result = analyze(request);

        FraudReport report = new FraudReport();
        report.setUser(user);
        report.setContent(request.getContent());
        report.setSourceType(request.getSourceType());
        report.setClassification(result.getClassification());
        report.setRiskScore(result.getRiskScore());
        report.setDetectedSignals(String.join(", ", result.getDetectedSignals()));
        report.setAdvice(result.getAdvice());

        fraudReportRepository.save(report);

        return result;
    }

    // Returns fraud analysis history for the authenticated user.
    public List<FraudHistoryResponse> getHistory(Authentication authentication) {

        User user = getAuthenticatedUser(authentication);

        List<FraudReport> reports =
                fraudReportRepository.findByUserOrderByCreatedAtDesc(user);

        List<FraudHistoryResponse> response = new ArrayList<>();

        for (FraudReport report : reports) {
            response.add(new FraudHistoryResponse(
                    report.getId(),
                    report.getContent(),
                    report.getSourceType(),
                    report.getClassification(),
                    report.getRiskScore(),
                    report.getDetectedSignals(),
                    report.getAdvice(),
                    report.getCreatedAt()
            ));
        }

        return response;
    }

    // Core fraud detection engine.
    private FraudResult analyze(FraudRequest request) {

        String content = normalize(request.getContent());
        List<String> signals = new ArrayList<>();
        int score = 0;

        if (ANY_LINK_PATTERN.matcher(content).find()) {
            score += 20;
            signals.add("External link detected.");
        }

        if (SHORT_LINK_PATTERN.matcher(content).find()) {
            score += 30;
            signals.add("Shortened or masked link detected.");
        }

        if (
                containsAny(content, "manda para este numero", "envia para este numero",
                        "transfere para este numero", "deposita neste numero",
                        "manda dinheiro", "envia dinheiro", "transferir para")
                        && PHONE_NUMBER_PATTERN.matcher(content).find()
        ) {
            score += 35;
            signals.add("Request to send money to a phone number detected.");
        }

        if (containsAny(content, "bonus", "bónus", "premio", "prémio",
                "ganhaste", "ganhou", "parabens", "parabéns",
                "oferta exclusiva", "promocao", "promoção",
                "cashback", "recompensa")) {

            score += 25;
            signals.add("Suspicious bonus, prize or promotion detected.");
        }

        if (containsAny(content, "m-pesa", "mpesa", "emola", "mkesh",
                "bim", "bci", "standard bank", "moza banco",
                "letshego", "vodacom", "movitel", "tmcel")) {

            score += 25;
            signals.add("Financial or mobile money service reference detected.");
        }

        if (containsAny(content, "pin", "otp", "codigo", "código",
                "senha", "palavra passe", "palavra-passe",
                "confirme o seu pin", "envie o codigo",
                "partilhe o codigo", "verificar conta")) {

            score += 40;
            signals.add("PIN, OTP, password or verification code request detected.");
        }

        if (containsAny(content, "urgente", "agora", "imediatamente",
                "ultima chance", "última chance", "hoje apenas",
                "a sua conta sera bloqueada", "conta bloqueada",
                "reactivar", "reativar", "evitar bloqueio")) {

            score += 25;
            signals.add("Urgency or pressure language detected.");
        }

        if (containsAny(content, "conta bloqueada", "foi bloqueada",
                "sera suspensa", "será suspensa", "reactivar conta",
                "reativar conta", "validar conta")) {

            score += 30;
            signals.add("Account blocking or reactivation scam pattern detected.");
        }

        if (containsAny(content, "sou agente", "suporte mpesa",
                "assistencia mpesa", "assistência mpesa",
                "central de atendimento", "operador oficial",
                "equipa tecnica", "equipa técnica")) {

            score += 20;
            signals.add("Fake support or agent impersonation detected.");
        }

        if (
                containsAny(content, "bonus", "bónus", "premio", "prémio", "ganhou", "ganhaste")
                        && containsAny(content, "taxa", "levantamento", "processamento",
                        "manda", "envia", "deposita", "transferir")
        ) {
            score += 35;
            signals.add("Prize or bonus combined with payment request detected.");
        }

        if (
                containsAny(content, "mpesa", "m-pesa", "emola", "mkesh")
                        && containsAny(content, "pin", "otp", "codigo", "código", "senha")
        ) {
            score += 35;
            signals.add("Mobile money message asking for credentials detected.");
        }

        if (score > 100) {
            score = 100;
        }

        String classification;
        String advice;

        if (score >= 70) {
            classification = "FRAUD";
            advice = "Do not send money, do not click links and never share PIN, OTP or passwords. Contact the official provider directly.";
        } else if (score >= 40) {
            classification = "SUSPICIOUS";
            advice = "This message has suspicious signs. Verify the sender before taking any action.";
        } else {
            classification = "LEGITIMATE";
            advice = "No strong fraud signs detected, but always verify financial messages carefully.";
        }

        return new FraudResult(classification, score, signals, advice);
    }

    // Gets the authenticated user from the JWT subject.
    private User getAuthenticatedUser(Authentication authentication) {

        String userId = authentication.getName();

        return userRepository.findById(Long.parseLong(userId))
                .orElseThrow(() -> new RuntimeException("Authenticated user not found."));
    }

    private String normalize(String value) {
        if (value == null) {
            return "";
        }

        return value
                .toLowerCase()
                .replace("á", "a")
                .replace("à", "a")
                .replace("ã", "a")
                .replace("â", "a")
                .replace("é", "e")
                .replace("ê", "e")
                .replace("í", "i")
                .replace("ó", "o")
                .replace("ô", "o")
                .replace("õ", "o")
                .replace("ú", "u")
                .replace("ç", "c");
    }

    private boolean containsAny(String content, String... keywords) {
        for (String keyword : keywords) {
            if (content.contains(normalize(keyword))) {
                return true;
            }
        }

        return false;
    }
}
