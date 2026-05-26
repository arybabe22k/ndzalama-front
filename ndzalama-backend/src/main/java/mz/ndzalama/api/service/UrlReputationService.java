package mz.ndzalama.api.service;

import mz.ndzalama.api.dto.fraud.UrlAnalysisRequest;
import mz.ndzalama.api.dto.fraud.UrlAnalysisResponse;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.util.ArrayList;
import java.util.List;

// Handles URL reputation and phishing pattern analysis.
@Service
public class UrlReputationService {

    // Analyzes a URL and returns fraud risk information.
    public UrlAnalysisResponse analyze(UrlAnalysisRequest request) {

        String url = normalize(request.getUrl());
        List<String> signals = new ArrayList<>();
        int score = 0;

        String host = extractHost(url);

        if (!url.startsWith("https://")) {
            score += 20;
            signals.add("Ligação não segura detectada.");
        }

        if (containsAny(host, "bit.ly", "tinyurl", "t.co", "goo.gl", "shorturl", "wa.me")) {
            score += 30;
            signals.add("Link encurtado ou mascarado detectado.");
        }

        if (containsAny(host, ".xyz", ".top", ".click", ".info", ".online", ".site")) {
            score += 20;
            signals.add("Domínio com extensão suspeita detectado.");
        }

        if (containsAny(url, "login", "verify", "verification", "account", "bonus", "free", "gift", "claim")) {
            score += 20;
            signals.add("URL contém palavras comuns em páginas falsas.");
        }

        if (containsAny(url, "mpesa", "m-pesa", "emola", "bim", "bci", "standardbank", "vodacom")) {
            score += 25;
            signals.add("URL usa nome de serviço financeiro ou dinheiro móvel.");
        }

        if (containsAny(url, "pin", "otp", "password", "senha", "codigo", "código")) {
            score += 30;
            signals.add("URL sugere pedido de credenciais ou códigos.");
        }

        if (hostContainsBrandButIsNotOfficial(host)) {
            score += 35;
            signals.add("Possível imitação de marca financeira detectada.");
        }

        if (score > 100) {
            score = 100;
        }

        String classification;
        String advice;

        if (score >= 70) {
            classification = "FRAUDE";
            advice = "Não abra este link nem introduza PIN, OTP, palavra-passe ou dados pessoais.";
        } else if (score >= 40) {
            classification = "SUSPEITO";
            advice = "Este link apresenta sinais suspeitos. Confirme a origem antes de abrir.";
        } else {
            classification = "LEGÍTIMO";
            advice = "Nenhum sinal forte de fraude foi detectado, mas confirme sempre a origem do link.";
        }

        return new UrlAnalysisResponse(
                classification,
                score,
                signals,
                advice
        );
    }

    private String normalize(String value) {
        if (value == null) {
            return "";
        }

        return value.trim().toLowerCase();
    }

    private String extractHost(String url) {
        try {
            URI uri = URI.create(url);

            if (uri.getHost() == null) {
                URI fallback = URI.create("https://" + url);
                return fallback.getHost() == null ? "" : fallback.getHost();
            }

            return uri.getHost();

        } catch (Exception e) {
            return "";
        }
    }

    private boolean containsAny(String content, String... values) {
        for (String value : values) {
            if (content.contains(value)) {
                return true;
            }
        }

        return false;
    }

    private boolean hostContainsBrandButIsNotOfficial(String host) {

        boolean containsFinancialBrand =
                containsAny(host, "mpesa", "m-pesa", "emola", "bim", "bci", "standardbank");

        boolean official =
                host.endsWith("vm.co.mz") ||
                        host.endsWith("vodacom.co.mz") ||
                        host.endsWith("bci.co.mz") ||
                        host.endsWith("bim.co.mz");

        return containsFinancialBrand && !official;
    }
}
