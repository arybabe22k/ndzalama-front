package mz.ndzalama.api.config;

import mz.ndzalama.api.model.LearningPath;
import mz.ndzalama.api.repository.LearningPathRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

// Seeds initial financial education learning paths.
@Component
public class LearningPathDataSeeder implements CommandLineRunner {

    private final LearningPathRepository learningPathRepository;

    public LearningPathDataSeeder(LearningPathRepository learningPathRepository) {
        this.learningPathRepository = learningPathRepository;
    }

    @Override
    public void run(String... args) {

        if (learningPathRepository.count() > 0) {
            return;
        }

        createPath(
                "Iniciante Financeiro",
                "Aprende os conceitos básicos sobre dinheiro, segurança digital e hábitos financeiros.",
                1,
                0,
                "BEGINNER"
        );

        createPath(
                "Protecção Contra Fraudes",
                "Aprende a identificar burlas, links suspeitos, falsos bónus e pedidos de PIN ou OTP.",
                2,
                50,
                "SECURITY"
        );

        createPath(
                "Poupador Inteligente",
                "Desenvolve hábitos de poupança, orçamento e controlo de gastos.",
                3,
                100,
                "SAVINGS"
        );

        createPath(
                "Gestor de Dívidas",
                "Aprende a avaliar empréstimos, evitar dívidas perigosas e organizar pagamentos.",
                4,
                250,
                "DEBT"
        );

        createPath(
                "Especialista Anti-Fraude",
                "Aprofunda conhecimentos sobre engenharia social, esquemas de investimento e fraudes digitais.",
                5,
                500,
                "EXPERT"
        );
    }

    private void createPath(
            String title,
            String description,
            Integer level,
            Integer requiredPoints,
            String icon
    ) {
        LearningPath path = new LearningPath();
        path.setTitle(title);
        path.setDescription(description);
        path.setLevel(level);
        path.setRequiredPoints(requiredPoints);
        path.setIcon(icon);

        learningPathRepository.save(path);
    }
}
