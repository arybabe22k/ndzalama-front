package mz.ndzalama.api.service;

import mz.ndzalama.api.dto.education.FinancialTipResponse;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

// Provides financial education content for users.
@Service
public class EducationService {

    // Returns one daily tip based on the current day.
    public FinancialTipResponse getDailyTip() {

        List<FinancialTipResponse> tips = getAllTips();

        int index = LocalDate.now().getDayOfYear() % tips.size();

        return tips.get(index);
    }
    
    // Returns all available financial education tips.
    public List<FinancialTipResponse> getAllTips() {

        return List.of(
                new FinancialTipResponse(
                        "PREVENCAO_FRAUDE",
                        "Nunca partilhe o seu PIN",
                        "Nenhum banco, M-Pesa, e-Mola ou operadora deve pedir o seu PIN ou OTP.",
                        "Se alguém pedir o seu PIN, termine a conversa imediatamente."
                ),
                new FinancialTipResponse(
                        "PREVENCAO_FRAUDE",
                        "Cuidado com mensagens de bónus",
                        "Bónus falsos e prémios são tácticas comuns usadas por burladores.",
                        "Nunca envie dinheiro para receber prémios."
                ),
                new FinancialTipResponse(
                        "DINHEIRO_MOVEL",
                        "Confirme antes de enviar dinheiro",
                        "Burladores usam frases como 'manda para este número' para enganar utilizadores.",
                        "Confirme sempre directamente com a empresa oficial."
                ),
                new FinancialTipResponse(
                        "POUPANCA",
                        "Poupe antes de gastar",
                        "Guardar uma pequena parte do dinheiro recebido ajuda a criar estabilidade financeira.",
                        "Tente poupar pelo menos 5% de qualquer valor recebido."
                ),
                new FinancialTipResponse(
                        "ORCAMENTO",
                        "Separe necessidades de desejos",
                        "Necessidades são essenciais. Desejos podem esperar.",
                        "Antes de comprar, pergunte-se se realmente precisa disso hoje."
                ),
                new FinancialTipResponse(
                        "DIVIDAS",
                        "Evite empréstimos emocionais",
                        "Pedir dinheiro por impulso pode causar problemas financeiros no futuro.",
                        "Calcule sempre a capacidade de pagamento antes de aceitar empréstimos."
                ),
                new FinancialTipResponse(
                        "SEGURANCA",
                        "Desconfie de links suspeitos",
                        "Links curtos podem esconder páginas falsas usadas para roubar dados.",
                        "Evite clicar em links enviados por desconhecidos."
                )
        );
    }
}
