import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_client.dart';
import '../services/token_storage.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _merchantController = TextEditingController();
  final _locationController = TextEditingController();

  String _selectedCategory = 'FOOD';
  String _selectedType = 'EXPENSE';
  String _selectedPayment = 'CASH';
  bool _isLoading = false;
  Map<String, dynamic>? _analysisResult;

  static const Color bg = Color(0xFF071A12);
  static const Color card = Color(0xFF10291D);
  static const Color green = Color(0xFF19A85B);
  static const Color red = Color(0xFFEF4444);
  static const Color orange = Color(0xFFF59E0B);

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Alimentação', 'value': 'FOOD', 'icon': Icons.restaurant},
    {'name': 'Compras', 'value': 'SHOPPING', 'icon': Icons.shopping_bag},
    {'name': 'Transporte', 'value': 'TRANSPORT', 'icon': Icons.directions_car},
    {'name': 'Lazer', 'value': 'ENTERTAINMENT', 'icon': Icons.movie},
    {'name': 'Saúde', 'value': 'HEALTH', 'icon': Icons.health_and_safety},
    {'name': 'Salário', 'value': 'SALARY', 'icon': Icons.work},
    {'name': 'Outros', 'value': 'OTHER', 'icon': Icons.category},
  ];

  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'Dinheiro', 'value': 'CASH', 'icon': Icons.money},
    {'name': 'Cartão', 'value': 'CARD', 'icon': Icons.credit_card},
    {'name': 'Mobile Money', 'value': 'MOBILE_MONEY', 'icon': Icons.phone_android},
    {'name': 'Transferência', 'value': 'BANK_TRANSFER', 'icon': Icons.account_balance},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _merchantController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // Converter string para enum do backend
  String _getTransactionTypeValue() {
    switch (_selectedType) {
      case 'INCOME':
        return 'INCOME';
      case 'EXPENSE':
        return 'EXPENSE';
      default:
        return 'EXPENSE';
    }
  }

  String _getPaymentMethodValue() {
    switch (_selectedPayment) {
      case 'CASH':
        return 'CASH';
      case 'CARD':
        return 'CARD';
      case 'MOBILE_MONEY':
        return 'MOBILE_MONEY';
      case 'BANK_TRANSFER':
        return 'BANK_TRANSFER';
      default:
        return 'CASH';
    }
  }

  Future<void> _submitTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _analysisResult = null;
    });

    try {
      final token = await TokenStorage.getToken();
      final amount = double.parse(_amountController.text);
      final transactionDate = DateTime.now();
      
      // Criar o request body exatamente como o DTO espera
      final requestBody = {
        'amount': amount,
        'category': _selectedCategory,
        'description': _descriptionController.text.isNotEmpty 
            ? _descriptionController.text 
            : '${_selectedType == 'EXPENSE' ? 'Compra' : 'Recebimento'} em ${_getCategoryName()}',
        'location': _locationController.text.isNotEmpty ? _locationController.text : 'Não especificado',
        'merchant': _merchantController.text.isNotEmpty ? _merchantController.text : _getDefaultMerchant(),
        'transactionDate': transactionDate.toIso8601String(),
        'transactionType': _getTransactionTypeValue(),
        'paymentMethod': _getPaymentMethodValue(),
      };
      
      // Log para debug
      print('📤 Enviando requisição: ${jsonEncode(requestBody)}');
      print('🔗 URL: ${ApiClient.baseUrl}/financial/transactions/analyze');
      
     final response = await http.post(
  Uri.parse('${ApiClient.baseUrl}/financial/transactions/analyze'), // Adicionar /api/v1
  headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  },
  body: jsonEncode(requestBody),
);

      // Log para debug
      print('📥 Status code: ${response.statusCode}');
      print('📥 Resposta: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = jsonDecode(response.body);
          print('✅ Resposta decodificada: $responseData');
          
          // Mapear a resposta do backend
          _analysisResult = {
            'impulseScore': responseData['impulseScore'] ?? 
                           responseData['score'] ?? 
                           _calculateLocalScore(amount, _selectedType, _selectedCategory),
            'riskLevel': responseData['riskLevel'] ?? 
                        responseData['level'] ?? 
                        _getRiskLevelFromScore(_calculateLocalScore(amount, _selectedType, _selectedCategory)),
            'recommendation': responseData['recommendation'] ?? 
                            responseData['message'] ?? 
                            _getLocalRecommendation(amount, _selectedType, _selectedCategory),
          };
          
          _showAnalysisDialog();
        } catch (e) {
          print('❌ Erro ao processar resposta: $e');
          _createLocalAnalysis(amount);
          _showAnalysisDialog();
        }
      } else {
        // Se a API falhar, mostrar erro mas também criar análise local
        print('❌ API retornou erro ${response.statusCode}: ${response.body}');
        _createLocalAnalysis(amount);
        _showAnalysisDialog();
      }
    } catch (e) {
      print('❌ Erro de conexão: $e');
      // Criar análise local em caso de erro
      final amount = double.tryParse(_amountController.text) ?? 0;
      _createLocalAnalysis(amount);
      _showAnalysisDialog();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getCategoryName() {
    final category = _categories.firstWhere(
      (cat) => cat['value'] == _selectedCategory,
      orElse: () => {'name': 'Outros'},
    );
    return category['name'] as String;
  }

  String _getDefaultMerchant() {
    if (_selectedType == 'INCOME') {
      return 'Cliente/Pagador';
    }
    
    switch (_selectedCategory) {
      case 'FOOD':
        return 'Supermercado/Restaurante';
      case 'SHOPPING':
        return 'Loja/Comércio';
      case 'TRANSPORT':
        return 'Transporte/Combustível';
      case 'ENTERTAINMENT':
        return 'Entretenimento';
      case 'HEALTH':
        return 'Farmácia/Hospital';
      default:
        return 'Estabelecimento';
    }
  }

  // Método para criar análise local quando a API falha
  void _createLocalAnalysis(double amount) {
    final localScore = _calculateLocalScore(amount, _selectedType, _selectedCategory);
    _analysisResult = {
      'impulseScore': localScore,
      'riskLevel': _getRiskLevelFromScore(localScore),
      'recommendation': _getLocalRecommendation(amount, _selectedType, _selectedCategory),
    };
  }

  // Calcular score local baseado na lógica de negócio
  int _calculateLocalScore(double amount, String type, String category) {
    int score = 0;
    
    if (type == 'EXPENSE') {
      // Despesas altas aumentam o score
      if (amount > 10000) score += 40;
      else if (amount > 5000) score += 30;
      else if (amount > 1000) score += 20;
      else if (amount > 500) score += 10;
      else score += 5;
      
      // Categorias de alto risco
      if (category == 'SHOPPING' || category == 'ENTERTAINMENT') {
        score += 25;
      } else if (category == 'FOOD') {
        score += 15;
      } else if (category == 'TRANSPORT') {
        score += 10;
      }
    } else {
      // Receitas não são consideradas impulso
      score = 0;
    }
    
    return score.clamp(0, 100);
  }
  
  String _getRiskLevelFromScore(int score) {
    if (score >= 70) return 'CRÍTICO';
    if (score >= 55) return 'ALTO';
    if (score >= 30) return 'MÉDIO';
    return 'BAIXO';
  }
  
  String _getLocalRecommendation(double amount, String type, String category) {
    if (type == 'INCOME') {
      return '✅ Ótimo! Esta receita ajuda a melhorar sua saúde financeira. Continue registrando todas as suas entradas.';
    }
    
    final score = _calculateLocalScore(amount, type, category);
    
    if (score >= 70) {
      return '⚠️ ATENÇÃO! Este é um gasto de alto risco. Recomendamos repensar esta compra e avaliar se é realmente necessária. Considere esperar 24 horas antes de efetuar o pagamento.';
    } else if (score >= 55) {
      return '🤔 Cuidado! Este gasto tem potencial impulsivo. Sugerimos verificar seu orçamento mensal e avaliar se este valor compromete suas finanças.';
    } else if (score >= 30) {
      return '📊 Gasto moderado. Ainda assim, recomendamos planejar melhor suas compras nesta categoria para evitar excessos.';
    } else {
      return '👍 Gasto dentro do esperado. Continue mantendo o controle financeiro e evite compras por impulso.';
    }
  }

  void _showAnalysisDialog() {
    // Garantir que _analysisResult não é null
    if (_analysisResult == null) {
      final amount = double.tryParse(_amountController.text) ?? 0;
      _createLocalAnalysis(amount);
    }
    
    final impulseScore = _analysisResult?['impulseScore'] ?? 0;
    final riskLevel = _analysisResult?['riskLevel'] ?? 'BAIXO';
    final recommendation = _analysisResult?['recommendation'] ?? 'Transação registrada com sucesso!';
    
    Color getRiskColor() {
      switch (riskLevel.toUpperCase()) {
        case 'CRÍTICO':
          return Colors.red;
        case 'ALTO':
          return orange;
        case 'MÉDIO':
          return Colors.yellow.shade700;
        default:
          return green;
      }
    }
    
    String getRiskIcon() {
      switch (riskLevel.toUpperCase()) {
        case 'CRÍTICO':
          return '⚠️';
        case 'ALTO':
          return '🤔';
        case 'MÉDIO':
          return '📊';
        default:
          return '✅';
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Text(
              getRiskIcon(),
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                impulseScore >= 55 ? 'Alerta de Impulso!' : 'Análise da Transação',
                style: const TextStyle(
                  color: Colors.white, 
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: getRiskColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: getRiskColor().withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Score de Impulso',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$impulseScore/100',
                          style: TextStyle(
                            color: getRiskColor(),
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Nível de Risco',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          riskLevel,
                          style: TextStyle(
                            color: getRiskColor(),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: impulseScore / 100,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(getRiskColor()),
              borderRadius: BorderRadius.circular(10),
              minHeight: 8,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                recommendation,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true); // Retorna para a tela anterior
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'ENTENDI',
              style: TextStyle(
                color: green, 
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text(
          'Nova Transação',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: green),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Tipo de transação
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedType = 'EXPENSE'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _selectedType == 'EXPENSE'
                                      ? red.withOpacity(0.2)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedType == 'EXPENSE'
                                        ? red
                                        : Colors.white10,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.arrow_downward,
                                      color: _selectedType == 'EXPENSE' ? red : Colors.white54,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Despesa',
                                      style: TextStyle(
                                        color: _selectedType == 'EXPENSE'
                                            ? red
                                            : Colors.white54,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedType = 'INCOME'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _selectedType == 'INCOME'
                                      ? green.withOpacity(0.2)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedType == 'INCOME'
                                        ? green
                                        : Colors.white10,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.arrow_upward,
                                      color: _selectedType == 'INCOME' ? green : Colors.white54,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Receita',
                                      style: TextStyle(
                                        color: _selectedType == 'INCOME'
                                            ? green
                                            : Colors.white54,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Valor
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: InputDecoration(
                          prefixText: 'MT ',
                          prefixStyle: const TextStyle(color: green),
                          hintText: '0,00',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Digite o valor';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Valor inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Categoria
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Categoria',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _categories.map((cat) {
                              final isSelected = _selectedCategory == cat['value'];
                              return GestureDetector(
                                onTap: () => setState(() => _selectedCategory = cat['value']),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? green.withOpacity(0.2)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? green : Colors.white10,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        cat['icon'],
                                        color: isSelected ? green : Colors.white54,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        cat['name'],
                                        style: TextStyle(
                                          color: isSelected ? green : Colors.white54,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Método de Pagamento
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Método de Pagamento',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: _paymentMethods.map((method) {
                              final isSelected = _selectedPayment == method['value'];
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedPayment = method['value']),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? green.withOpacity(0.2)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected ? green : Colors.white10,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          method['icon'],
                                          color: isSelected ? green : Colors.white54,
                                          size: 20,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          method['name'],
                                          style: TextStyle(
                                            color: isSelected ? green : Colors.white54,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Estabelecimento/Merchant (Novo campo)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: TextFormField(
                        controller: _merchantController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Estabelecimento (opcional)',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.store, color: Colors.white.withOpacity(0.5)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Localização (Novo campo)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: TextFormField(
                        controller: _locationController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Localização (opcional)',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.location_on, color: Colors.white.withOpacity(0.5)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Descrição
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: TextFormField(
                        controller: _descriptionController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Descrição (opcional)',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Botão Registrar
                    GestureDetector(
                      onTap: _submitTransaction,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [green, green.withOpacity(0.7)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text(
                            'Registrar Transação',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}