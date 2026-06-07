import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
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
bool _isScanning = false;
Map<String, dynamic>? _analysisResult;

static const Color bg = Color(0xFF071A12);
static const Color card = Color(0xFF10291D);
static const Color green = Color(0xFF19A85B);
static const Color red = Color(0xFFEF4444);
static const Color orange = Color(0xFFF59E0B);
static const Color blue = Color(0xFF3B82F6);

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

String _getTransactionTypeValue() {
return _selectedType == 'INCOME' ? 'INCOME' : 'EXPENSE';
}

String _getPaymentMethodValue() {
return _selectedPayment;
}

Future<void> _scanReceipt() async {
showModalBottomSheet(
  context: context,
  backgroundColor: Colors.transparent,
  builder: (context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: card,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildImageSourceOption(
                icon: Icons.camera_alt,
                label: 'Câmera',
                color: blue,
                onTap: () => _pickImage(ImageSource.camera),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildImageSourceOption(
                icon: Icons.photo_library,
                label: 'Galeria',
                color: green,
                onTap: () => _pickImage(ImageSource.gallery),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    ),
  ),
);
}

Widget _buildImageSourceOption({
required IconData icon,
required String label,
required Color color,
required VoidCallback onTap,
}) {
return GestureDetector(
  onTap: onTap,
  child: Container(
    padding: const EdgeInsets.symmetric(vertical: 16),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  ),
);
}

Future<void> _pickImage(ImageSource source) async {
Navigator.pop(context);

final ImagePicker picker = ImagePicker();
final XFile? image = await picker.pickImage(
  source: source,
  maxWidth: 1024,
  maxHeight: 1024,
  imageQuality: 85,
);

if (image != null) {
  await _processImage(image);
}
}

Future<void> _processImage(XFile image) async {
setState(() {
  _isScanning = true;
});

try {
  final token = await TokenStorage.getToken();
  final bytes = await image.readAsBytes();
  
  final extension = image.path.split('.').last.toLowerCase();
  String contentType;
  switch (extension) {
    case 'jpg':
    case 'jpeg':
      contentType = 'image/jpeg';
      break;
    case 'png':
      contentType = 'image/png';
      break;
    case 'bmp':
      contentType = 'image/bmp';
      break;
    default:
      contentType = 'image/jpeg';
  }
  
  final request = http.MultipartRequest(
    'POST',
    Uri.parse('${ApiClient.baseUrl}/scan-receipt/scan-enhanced'),
  );
  
  request.headers['Authorization'] = 'Bearer $token';
  request.headers['Accept'] = 'application/json';
  
  final multipartFile = http.MultipartFile.fromBytes(
    'image',
    bytes,
    filename: image.name,
    contentType: MediaType.parse(contentType),
  );
  
  request.files.add(multipartFile);
  
  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200) {
    final result = jsonDecode(response.body);
    final preFilledForm = result['preFilledForm'] ?? {};
    final impulseAnalysis = result['impulseAnalysis'] ?? {};
    
    // Preencher o formulário com os dados escaneados
    _fillFormWithScanResult(preFilledForm);
    
    // Mostrar o diálogo de análise com os dados do scan
    _showAnalysisDialog({
      'impulseScore': impulseAnalysis['impulseScore'] ?? 0,
      'riskLevel': impulseAnalysis['riskLevel'] ?? 'BAIXO',
      'recommendation': impulseAnalysis['recommendation'] ?? 'Transação processada com sucesso!',
      'reason': 'Compra escaneada do recibo',
      'insights': result['suggestions'] ?? [],
    });
    
    _showMessage('Recibo processado com sucesso!', green);
  } else {
    _showMessage('Erro ao processar recibo: ${response.statusCode}', red);
  }
} catch (e) {
  print(' Erro ao escanear: $e');
  _showMessage('Erro ao conectar ao servidor: $e', red);
} finally {
  setState(() {
    _isScanning = false;
  });
}
}

void _fillFormWithScanResult(Map<String, dynamic> preFilledForm) {
setState(() {
  if (preFilledForm['amount'] != null) {
    _amountController.text = preFilledForm['amount'].toString();
  }
  
  if (preFilledForm['merchant'] != null && preFilledForm['merchant'].toString().isNotEmpty) {
    _merchantController.text = preFilledForm['merchant'];
  }
  
  if (preFilledForm['location'] != null && preFilledForm['location'].toString().isNotEmpty) {
    _locationController.text = preFilledForm['location'];
  }
  
  if (preFilledForm['category'] != null) {
    final category = preFilledForm['category'].toString().toUpperCase();
    if (_categories.any((c) => c['value'] == category)) {
      _selectedCategory = category;
    }
  }
  
  if (preFilledForm['transactionType'] != null) {
    final type = preFilledForm['transactionType'].toString().toUpperCase();
    if (type == 'INCOME' || type == 'EXPENSE') {
      _selectedType = type;
    }
  }
  
  if (preFilledForm['paymentMethod'] != null) {
    final payment = preFilledForm['paymentMethod'].toString().toUpperCase();
    if (_paymentMethods.any((p) => p['value'] == payment)) {
      _selectedPayment = payment;
    }
  }
  
  if (preFilledForm['description'] != null && preFilledForm['description'].toString().isNotEmpty) {
    _descriptionController.text = preFilledForm['description'];
  }
});
}

Future<void> _submitTransaction() async {
if (!_formKey.currentState!.validate()) return;

setState(() {
  _isLoading = true;
});

try {
  final token = await TokenStorage.getToken();
  final amount = double.parse(_amountController.text);
  final transactionDate = DateTime.now();
  
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
  
  final response = await http.post(
    Uri.parse('${ApiClient.baseUrl}/financial/transactions/analyze'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(requestBody),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final responseData = jsonDecode(response.body);
    
    // Mostrar o diálogo de análise com os dados da API
    _showAnalysisDialog({
      'impulseScore': responseData['impulseScore'] ?? 0,
      'riskLevel': responseData['riskLevel'] ?? 'BAIXO',
      'recommendation': responseData['recommendation'] ?? 'Transação registrada com sucesso!',
      'reason': responseData['reason'] ?? 'Transação analisada',
      'insights': responseData['insights'] ?? [],
    });
  } else {
    _showMessage('Erro ao registrar transação', red);
    setState(() {
      _isLoading = false;
    });
  }
} catch (e) {
  _showMessage('Erro ao registrar transação: $e', red);
  setState(() {
    _isLoading = false;
  });
}
}

void _showAnalysisDialog(Map<String, dynamic> analysis) {
setState(() {
  _isLoading = false;
  _isScanning = false;
});

final impulseScore = analysis['impulseScore'] ?? 0;
final riskLevel = analysis['riskLevel'] ?? 'BAIXO';
final recommendation = analysis['recommendation'] ?? 'Transação processada com sucesso!';
final reason = analysis['reason'] ?? '';
final insights = analysis['insights'] ?? [];

Color getRiskColor() {
  switch (riskLevel.toUpperCase()) {
    case 'ALTO':
    case 'CRÍTICO':
      return red;
    case 'MÉDIO':
      return orange;
    case 'BAIXO':
      return green;
    default:
      return blue;
  }
}

String getRiskIcon() {
  switch (riskLevel.toUpperCase()) {
    case 'ALTO':
    case 'CRÍTICO':
      return '⚠️';
    case 'MÉDIO':
      return '📊';
    case 'BAIXO':
      return '✅';
    default:
      return 'ℹ️';
  }
}

String getRiskMessage() {
  switch (riskLevel.toUpperCase()) {
    case 'ALTO':
    case 'CRÍTICO':
      return 'Alto Risco de Impulso!';
    case 'MÉDIO':
      return 'Risco Moderado';
    case 'BAIXO':
      return 'Compra Segura';
    default:
      return 'Análise da Transação';
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
          style: const TextStyle(fontSize: 32),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            getRiskMessage(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ],
    ),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Score Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  getRiskColor().withOpacity(0.15),
                  getRiskColor().withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: getRiskColor().withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Score de Impulso',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$impulseScore/100',
                          style: TextStyle(
                            color: getRiskColor(),
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Nível de Risco',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: getRiskColor().withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            riskLevel,
                            style: TextStyle(
                              color: getRiskColor(),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: impulseScore / 100,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(getRiskColor()),
                  borderRadius: BorderRadius.circular(10),
                  minHeight: 8,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Reason
          if (reason.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: blue, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reason,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Recommendation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: getRiskColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: getRiskColor().withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: getRiskColor(), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Recomendação',
                      style: TextStyle(
                        color: getRiskColor(),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  recommendation,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          
          // Insights
          if (insights.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: blue.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.trending_up, color: blue, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Insights',
                        style: TextStyle(
                          color: blue,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...insights.map((insight) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ', style: TextStyle(color: blue, fontSize: 12)),
                        Expanded(
                          child: Text(
                            insight.toString(),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.pop(context);
          Navigator.pop(context, true); // Retorna para a tela anterior
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

void _showMessage(String message, Color color) {
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(message),
    backgroundColor: color,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    actions: [
      IconButton(
        onPressed: _isScanning ? null : _scanReceipt,
        icon: _isScanning
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: green),
              )
            : const Icon(Icons.receipt_long, color: green),
        tooltip: 'Escanear Recibo',
      ),
    ],
  ),
  body: _isLoading
      ? const Center(child: CircularProgressIndicator(color: green))
      : SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Botão de scan rápido
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: GestureDetector(
                    onTap: _isScanning ? null : _scanReceipt,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [blue.withOpacity(0.2), blue.withOpacity(0.05)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _isScanning
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: blue),
                                )
                              : Icon(Icons.receipt_long, color: blue),
                          const SizedBox(width: 12),
                          Text(
                            _isScanning ? 'Processando imagem...' : 'Escanear Recibo com IA',
                            style: TextStyle(color: blue, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

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
                            color: _selectedType == 'EXPENSE' ? red : Colors.white10,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_downward,
                                color: _selectedType == 'EXPENSE' ? red : Colors.white54,
                                size: 18),
                            const SizedBox(width: 8),
                            Text('Despesa',
                                style: TextStyle(
                                    color: _selectedType == 'EXPENSE'
                                        ? red
                                        : Colors.white54,
                                    fontWeight: FontWeight.w500)),
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
                            color: _selectedType == 'INCOME' ? green : Colors.white10,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_upward,
                                color: _selectedType == 'INCOME' ? green : Colors.white54,
                                size: 18),
                            const SizedBox(width: 8),
                            Text('Receita',
                                style: TextStyle(
                                color: _selectedType == 'INCOME'
                                    ? green
                                    : Colors.white54,
                                fontWeight: FontWeight.w500)),
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
                  if (value == null || value.isEmpty) return 'Digite o valor';
                  if (double.tryParse(value) == null) return 'Valor inválido';
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
                  Text('Categoria',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.6), fontSize: 12)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat['value'];
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat['value']),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? green.withOpacity(0.2) : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: isSelected ? green : Colors.white10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(cat['icon'],
                                  color: isSelected ? green : Colors.white54, size: 16),
                              const SizedBox(width: 8),
                              Text(cat['name'],
                                  style: TextStyle(
                                      color: isSelected ? green : Colors.white54,
                                      fontSize: 13)),
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
                      Text('Método de Pagamento',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.6), fontSize: 12)),
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
                                  color: isSelected ? green.withOpacity(0.2) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: isSelected ? green : Colors.white10),
                            ),
                            child: Column(
                              children: [
                                Icon(method['icon'],
                                    color: isSelected ? green : Colors.white54, size: 20),
                                const SizedBox(height: 4),
                                Text(method['name'],
                                    style: TextStyle(
                                        color: isSelected ? green : Colors.white54,
                                        fontSize: 10)),
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

            // Estabelecimento
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
                  hintText: 'Estabelecimento',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.store, color: Colors.white.withOpacity(0.5)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Localização
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
                  hintText: 'Localização',
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
                  hintText: 'Descrição',
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
                  gradient: LinearGradient(colors: [green, green.withOpacity(0.7)]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'Registrar Transação',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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