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

    private final GamificationService gamificationService;
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
            UserRepository userRepository,
            GamificationService gamificationService
    ) {
        this.fraudReportRepository = fraudReportRepository;
        this.userRepository = userRepository;
        this.gamificationService = gamificationService;
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

        gamificationService.addPoints(user, 10);

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

        // External links
        if (ANY_LINK_PATTERN.matcher(content).find()) {
            score += 20;
            signals.add("Link externo detectado.");
        }

        // Shortened links
        if (SHORT_LINK_PATTERN.matcher(content).find()) {
            score += 30;
            signals.add("Link encurtado ou mascarado detectado.");
        }

        // Requests to send money
        if (
                containsAny(content,
                        "manda para este numero",
                        "envia para este numero",
                        "transfere para este numero",
                        "deposita neste numero",
                        "manda dinheiro",
                        "envia dinheiro",
                        "transferir para")
                        && PHONE_NUMBER_PATTERN.matcher(content).find()
        ) {

            score += 35;

            signals.add("Pedido suspeito para envio de dinheiro detectado.");
        }

        // Suspicious bonuses and promotions
        if (
                containsAny(content,
                        "bonus",
                        "bónus",
                        "premio",
                        "prémio",
                        "ganhaste",
                        "ganhou",
                        "parabens",
                        "parabéns",
                        "oferta exclusiva",
                        "promocao",
                        "promoção",
                        "cashback",
                        "recompensa")
        ) {

            score += 25;

            signals.add("Bónus, prémio ou promoção suspeita detectada.");
        }

        // Financial services
        if (
                containsAny(content,
                        "m-pesa",
                        "mpesa",
                        "emola",
                        "mkesh",
                        "bim",
                        "bci",
                        "standard bank",
                        "moza banco",
                        "letshego",
                        "vodacom",
                        "movitel",
                        "tmcel")
        ) {

            score += 25;

            signals.add("Referência a serviço financeiro ou dinheiro móvel detectada.");
        }

        // PIN / OTP / password requests
        if (
                containsAny(content,
                        "pin",
                        "otp",
                        "codigo",
                        "código",
                        "senha",
                        "palavra passe",
                        "palavra-passe",
                        "confirme o seu pin",
                        "envie o codigo",
                        "partilhe o codigo",
                        "verificar conta")
        ) {

            score += 40;

            signals.add("Pedido de PIN, OTP ou código de verificação detectado.");
        }

        // Urgency manipulation
        if (
                containsAny(content,
                        "urgente",
                        "agora",
                        "imediatamente",
                        "ultima chance",
                        "última chance",
                        "hoje apenas",
                        "a sua conta sera bloqueada",
                        "conta bloqueada",
                        "reactivar",
                        "reativar",
                        "evitar bloqueio")
        ) {

            score += 25;

            signals.add("Linguagem de urgência ou pressão detectada.");
        }

        // Account suspension scam
        if (
                containsAny(content,
                        "conta bloqueada",
                        "foi bloqueada",
                        "sera suspensa",
                        "será suspensa",
                        "reactivar conta",
                        "reativar conta",
                        "validar conta")
        ) {

            score += 30;

            signals.add("Tentativa suspeita de bloqueio ou reactivação de conta detectada.");
        }

        // Fake support or impersonation
        if (
                containsAny(content,
                        "sou agente",
                        "suporte mpesa",
                        "assistencia mpesa",
                        "assistência mpesa",
                        "central de atendimento",
                        "operador oficial",
                        "equipa tecnica",
                        "equipa técnica")
        ) {

            score += 20;

            signals.add("Falso agente ou suporte técnico detectado.");
        }

        // Prize scam requiring payment
        if (
                containsAny(content,
                        "bonus",
                        "bónus",
                        "premio",
                        "prémio",
                        "ganhou",
                        "ganhaste")
                        &&
                        containsAny(content,
                                "taxa",
                                "levantamento",
                                "processamento",
                                "manda",
                                "envia",
                                "deposita",
                                "transferir")
        ) {

            score += 35;

            signals.add("Prémio ou bónus combinado com pedido de pagamento detectado.");
        }

        // Mobile money credential theft
        if (
                containsAny(content,
                        "mpesa",
                        "m-pesa",
                        "emola",
                        "mkesh")
                        &&
                        containsAny(content,
                                "pin",
                                "otp",
                                "codigo",
                                "código",
                                "senha")
        ) {

            score += 35;

            signals.add("Mensagem de dinheiro móvel a pedir credenciais detectada.");
        }

        // Romance scam
        if (
                containsAny(content,
                        "amo-te",
                        "amor da minha vida",
                        "apaixonei-me",
                        "quero casar contigo",
                        "minha rainha",
                        "meu rei",
                        "preciso de dinheiro urgente",
                        "envia dinheiro para me ajudar",
                        "estou preso",
                        "estou no hospital",
                        "bilhete de viagem")
        ) {

            score += 30;

            signals.add("Possível fraude afectiva ou romance scam detectada.");
        }

        // Crypto scam
        if (
                containsAny(content,
                        "bitcoin",
                        "btc",
                        "crypto",
                        "criptomoeda",
                        "binance",
                        "wallet",
                        "carteira digital",
                        "minerar",
                        "mineração",
                        "trading automático")
        ) {

            score += 25;

            signals.add("Referência suspeita a criptomoedas ou trading detectada.");
        }

        // Fake investment scam
        if (
                containsAny(content,
                        "investe",
                        "investimento garantido",
                        "lucro garantido",
                        "retorno garantido",
                        "ganha por semana",
                        "ganhe por semana",
                        "multiplica o teu dinheiro",
                        "sem risco",
                        "rendimento diario",
                        "rendimento diário")
        ) {

            score += 35;

            signals.add("Promessa suspeita de investimento ou lucro garantido detectada.");
        }

        // Fake job scam
        if (
                containsAny(content,
                        "vaga disponivel",
                        "vaga disponível",
                        "emprego garantido",
                        "trabalho em casa",
                        "sem experiencia",
                        "sem experiência",
                        "paga taxa de inscrição",
                        "taxa de candidatura",
                        "envia documentos pelo whatsapp")
        ) {

            score += 30;

            signals.add("Possível falso emprego detectado.");
        }

        // Fake loan scam
        if (
                containsAny(content,
                        "emprestimo rapido",
                        "empréstimo rápido",
                        "credito facil",
                        "crédito fácil",
                        "sem consulta",
                        "sem garantias",
                        "aprovacao imediata",
                        "aprovação imediata",
                        "paga taxa para liberar",
                        "taxa de processamento")
        ) {

            score += 35;

            signals.add("Possível empréstimo falso detectado.");
        }

        if (score > 100) {
            score = 100;
        }

        String classification;
        String advice;

        if (score >= 70) {

            classification = "FRAUDE";

            advice =
                    "Não envie dinheiro, não clique em links e nunca partilhe PIN, OTP ou palavras-passe. Contacte directamente o fornecedor oficial.";

        } else if (score >= 40) {

            classification = "SUSPEITO";

            advice =
                    "Esta mensagem apresenta sinais suspeitos. Verifique o remetente antes de tomar qualquer acção.";

        } else {

            classification = "LEGÍTIMO";

            advice =
                    "Nenhum sinal forte de fraude foi detectado, mas continue atento a mensagens financeiras.";
        }

        return new FraudResult(
                classification,
                score,
                signals,
                advice
        );
    }

    // Gets the authenticated user from the JWT subject.
    private User getAuthenticatedUser(Authentication authentication) {

        String userId = authentication.getName();

        return userRepository.findById(Long.parseLong(userId))
                .orElseThrow(() ->
                        new RuntimeException("Authenticated user not found."));
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