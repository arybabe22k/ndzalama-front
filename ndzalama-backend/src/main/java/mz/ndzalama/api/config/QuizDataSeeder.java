package mz.ndzalama.api.config;

import mz.ndzalama.api.model.QuizOption;
import mz.ndzalama.api.model.QuizQuestion;
import mz.ndzalama.api.repository.QuizQuestionRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.List;

// Seeds initial quiz questions when the database is empty.
@Component
public class QuizDataSeeder implements CommandLineRunner {

    private final QuizQuestionRepository quizQuestionRepository;

    public QuizDataSeeder(QuizQuestionRepository quizQuestionRepository) {
        this.quizQuestionRepository = quizQuestionRepository;
    }

    @Override
    public void run(String... args) {

        if (quizQuestionRepository.count() > 0) {
            return;
        }

        seedFraudPrevention();
        seedMobileMoney();
        seedDigitalSecurity();
        seedSavings();
        seedBudgeting();
        seedDebt();
    }

    private void seedFraudPrevention() {

        createQuestion(
                "Deves partilhar o teu PIN ou OTP com alguém que diz ser agente M-Pesa?",
                "PREVENCAO_FRAUDE",
                "Nunca partilhes PIN, OTP ou palavras-passe. Nenhum agente oficial deve pedir esses dados.",
                List.of(
                        option("Sim, se parecer confiável.", false),
                        option("Não, nunca devo partilhar.", true),
                        option("Sim, se for urgente.", false)
                )
        );

        createQuestion(
                "Recebeste uma mensagem: 'Ganhaste um bónus, envia 100MT para activar'. O que deves fazer?",
                "PREVENCAO_FRAUDE",
                "Bónus verdadeiros não exigem pagamento antecipado para serem recebidos.",
                List.of(
                        option("Enviar o dinheiro rapidamente.", false),
                        option("Ignorar e confirmar com a empresa oficial.", true),
                        option("Enviar o PIN para acelerar.", false)
                )
        );

        createQuestion(
                "Uma pessoa desconhecida pede para enviares dinheiro para 'este número' prometendo devolver mais tarde. Qual é a melhor atitude?",
                "PREVENCAO_FRAUDE",
                "Pedidos para enviar dinheiro a números desconhecidos são sinais fortes de burla.",
                List.of(
                        option("Enviar e confiar.", false),
                        option("Confirmar a identidade por canais oficiais antes de agir.", true),
                        option("Enviar só metade do valor.", false)
                )
        );

        createQuestion(
                "Uma mensagem diz que a tua conta será bloqueada se não clicares num link. O que isso pode indicar?",
                "PREVENCAO_FRAUDE",
                "Mensagens com ameaça de bloqueio e links costumam usar pressão emocional para enganar.",
                List.of(
                        option("Pode ser tentativa de fraude.", true),
                        option("É sempre uma mensagem oficial.", false),
                        option("Devo clicar imediatamente.", false)
                )
        );

        createQuestion(
                "Alguém diz ser suporte técnico e pede o teu código de verificação. O que deves fazer?",
                "PREVENCAO_FRAUDE",
                "Códigos de verificação servem para proteger a tua conta e nunca devem ser partilhados.",
                List.of(
                        option("Partilhar o código.", false),
                        option("Não partilhar e terminar a conversa.", true),
                        option("Enviar apenas os últimos dígitos.", false)
                )
        );
    }

    private void seedMobileMoney() {

        createQuestion(
                "Antes de confirmar uma transferência no M-Pesa ou e-Mola, o que deves verificar?",
                "DINHEIRO_MOVEL",
                "Verificar nome, número e valor evita envio para destinatários errados ou burladores.",
                List.of(
                        option("Nome, número e valor da transacção.", true),
                        option("Apenas a cor do menu.", false),
                        option("Nada, confirmar rapidamente.", false)
                )
        );

        createQuestion(
                "Se receberes uma chamada a dizer que uma transferência falhou e pedirem o teu PIN, o que deves fazer?",
                "DINHEIRO_MOVEL",
                "O PIN é pessoal e não deve ser dito por chamada, SMS ou WhatsApp.",
                List.of(
                        option("Dizer o PIN para resolver.", false),
                        option("Desligar e contactar o suporte oficial.", true),
                        option("Enviar o PIN por mensagem.", false)
                )
        );

        createQuestion(
                "Um suposto agente pede uma taxa para desbloquear um prémio em dinheiro móvel. Isto é:",
                "DINHEIRO_MOVEL",
                "Prémios legítimos não exigem taxas enviadas para números pessoais.",
                List.of(
                        option("Sinal provável de fraude.", true),
                        option("Procedimento normal.", false),
                        option("Obrigatório para todos os prémios.", false)
                )
        );

        createQuestion(
                "Qual é uma prática segura ao usar dinheiro móvel?",
                "DINHEIRO_MOVEL",
                "Manter o PIN secreto e confirmar os dados antes de transaccionar reduz riscos.",
                List.of(
                        option("Usar o mesmo PIN que todos conhecem.", false),
                        option("Manter o PIN secreto e verificar transacções.", true),
                        option("Partilhar o PIN com familiares e agentes.", false)
                )
        );
    }

    private void seedDigitalSecurity() {

        createQuestion(
                "Um link curto como bit.ly enviado por desconhecido deve ser tratado como:",
                "SEGURANCA_DIGITAL",
                "Links curtos podem esconder páginas falsas usadas para roubar dados.",
                List.of(
                        option("Sempre seguro.", false),
                        option("Suspeito até ser verificado.", true),
                        option("Obrigatório clicar.", false)
                )
        );

        createQuestion(
                "Qual é a melhor palavra-passe?",
                "SEGURANCA_DIGITAL",
                "Palavras-passe fortes combinam letras, números e símbolos, e não devem ser óbvias.",
                List.of(
                        option("123456.", false),
                        option("O teu nome e ano de nascimento.", false),
                        option("Uma combinação forte e difícil de adivinhar.", true)
                )
        );

        createQuestion(
                "Recebeste um SMS com erros estranhos, urgência e link. O que deves fazer?",
                "SEGURANCA_DIGITAL",
                "Erros, urgência e links suspeitos são sinais comuns de phishing.",
                List.of(
                        option("Clicar para confirmar.", false),
                        option("Ignorar, não clicar e verificar a fonte.", true),
                        option("Enviar para todos os contactos.", false)
                )
        );

        createQuestion(
                "Usar a mesma palavra-passe em todas as contas é:",
                "SEGURANCA_DIGITAL",
                "Se uma conta for comprometida, outras também podem ficar em risco.",
                List.of(
                        option("Arriscado.", true),
                        option("Mais seguro.", false),
                        option("Obrigatório.", false)
                )
        );
    }

    private void seedSavings() {

        createQuestion(
                "Qual é uma boa prática financeira ao receber dinheiro?",
                "POUPANCA",
                "Poupar uma pequena parte antes de gastar ajuda a criar estabilidade financeira.",
                List.of(
                        option("Gastar tudo no mesmo dia.", false),
                        option("Poupar uma parte primeiro.", true),
                        option("Pedir empréstimo imediatamente.", false)
                )
        );

        createQuestion(
                "Porque é importante ter uma reserva de emergência?",
                "POUPANCA",
                "Uma reserva ajuda a lidar com imprevistos sem depender imediatamente de dívidas.",
                List.of(
                        option("Para cobrir imprevistos.", true),
                        option("Para gastar por impulso.", false),
                        option("Para emprestar sempre aos outros.", false)
                )
        );

        createQuestion(
                "Poupar 5% de cada valor recebido pode ajudar porque:",
                "POUPANCA",
                "Pequenos hábitos constantes criam segurança financeira ao longo do tempo.",
                List.of(
                        option("Cria disciplina e segurança financeira.", true),
                        option("Não faz diferença nenhuma.", false),
                        option("Serve apenas para pessoas ricas.", false)
                )
        );
    }

    private void seedBudgeting() {

        createQuestion(
                "O que é um orçamento pessoal?",
                "ORCAMENTO",
                "Um orçamento ajuda a organizar entradas, despesas e poupança.",
                List.of(
                        option("Um plano para controlar dinheiro.", true),
                        option("Uma lista de dívidas apenas.", false),
                        option("Um recibo de pagamento.", false)
                )
        );

        createQuestion(
                "Antes de comprar algo por impulso, é melhor perguntar:",
                "ORCAMENTO",
                "Separar necessidades de desejos ajuda a evitar gastos desnecessários.",
                List.of(
                        option("Preciso mesmo disto agora?", true),
                        option("Posso comprar só porque vi?", false),
                        option("Como gasto todo o dinheiro hoje?", false)
                )
        );

        createQuestion(
                "Qual destas opções é uma necessidade básica?",
                "ORCAMENTO",
                "Necessidades básicas são despesas essenciais para viver.",
                List.of(
                        option("Alimentação.", true),
                        option("Apostas.", false),
                        option("Compras por impulso.", false)
                )
        );
    }

    private void seedDebt() {

        createQuestion(
                "Antes de aceitar um empréstimo, o que deves avaliar?",
                "DIVIDAS",
                "É importante saber se conseguirás pagar sem prejudicar despesas essenciais.",
                List.of(
                        option("A capacidade de pagar.", true),
                        option("Apenas a rapidez do dinheiro.", false),
                        option("Só o conselho de amigos.", false)
                )
        );

        createQuestion(
                "Pedir dinheiro emprestado para pagar outro empréstimo pode ser:",
                "DIVIDAS",
                "Isso pode criar um ciclo de dívida difícil de controlar.",
                List.of(
                        option("Um sinal de risco financeiro.", true),
                        option("Sempre uma solução perfeita.", false),
                        option("Uma forma garantida de enriquecer.", false)
                )
        );

        createQuestion(
                "Uma dívida saudável deve:",
                "DIVIDAS",
                "Uma dívida deve ter objectivo claro, prazo e capacidade real de pagamento.",
                List.of(
                        option("Ter plano claro de pagamento.", true),
                        option("Ser feita sem pensar.", false),
                        option("Nunca ser registada.", false)
                )
        );
    }

    private void createQuestion(
            String questionText,
            String category,
            String explanation,
            List<QuizOption> options
    ) {
        QuizQuestion question = new QuizQuestion();
        question.setQuestion(questionText);
        question.setCategory(category);
        question.setExplanation(explanation);

        for (QuizOption option : options) {
            option.setQuestion(question);
        }

        question.setOptions(options);

        quizQuestionRepository.save(question);
    }

    private QuizOption option(String text, boolean correct) {
        QuizOption option = new QuizOption();
        option.setText(text);
        option.setCorrect(correct);
        return option;
    }
}
