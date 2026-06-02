import 'dart:convert';
import 'dart:typed_data';
 
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
 
import '../services/api_client.dart';
import '../services/token_storage.dart';
import 'app_ui.dart';

import '../utils/auth_error_handler.dart';
 
class AnalyzeImageScreen extends StatefulWidget {
  const AnalyzeImageScreen({super.key});
 
  @override
  State<AnalyzeImageScreen> createState() => _AnalyzeImageScreenState();
}
 
class _AnalyzeImageScreenState extends State<AnalyzeImageScreen> {
  bool isLoading = false;
  Map<String, dynamic>? result;
  XFile? selectedImage;
  Uint8List? imageBytes;
 
  Future<void> pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
 
    final bytes = await image.readAsBytes();
 
    setState(() {
      selectedImage = image;
      imageBytes = bytes;
      result = null;
    });
  }
 
  Future<void> analyzeImage() async {
    if (selectedImage == null) {
      _showMessage('Seleccione uma imagem primeiro.');
      return;
    }
 
    setState(() {
      isLoading = true;
      result = null;
    });
 
    try {
      final token = await TokenStorage.getToken();
 
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiClient.baseUrl}/fraud/analyze-image'),
      );
 
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes!,
          filename: selectedImage!.name,
        ),
      );
 
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      
 
      if (response.statusCode == 200) {
        setState(() => result = jsonDecode(response.body));
      } else {
        _showMessage('Erro ao analisar imagem.');
      }
    } catch (e) {
      _showMessage('Erro de ligação ao servidor.');
    } finally {
      setState(() => isLoading = false);
    }
  }
 
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        backgroundColor: AppColors.surface,
      ),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    final riskScore = (result?['riskScore'] ?? 0) as int;
 
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppBar('Analisar Imagem'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image picker zone
            GestureDetector(
              onTap: isLoading ? null : pickImage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selectedImage != null
                        ? const Color(0xFFFF9100).withOpacity(0.4)
                        : Colors.white.withOpacity(0.08),
                    width: selectedImage != null ? 1.5 : 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: imageBytes != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.memory(imageBytes!, fit: BoxFit.cover),
                            Container(
                              color: Colors.black.withOpacity(0.4),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.edit_rounded, color: Colors.white70, size: 24),
                                  const SizedBox(height: 6),
                                  Text(
                                    selectedImage!.name,
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF9100).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.image_search_rounded,
                                color: Color(0xFFFF9100),
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Toque para escolher uma imagem',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'JPG, PNG, WEBP',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.25),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
 
            const SizedBox(height: 12),
 
            if (selectedImage == null)
              SecondaryButton(
                label: 'Escolher da galeria',
                onPressed: isLoading ? null : pickImage,
                icon: Icons.photo_library_outlined,
              )
            else
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Alterar',
                      onPressed: isLoading ? null : pickImage,
                      icon: Icons.swap_horiz_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Analisar',
                      onPressed: analyzeImage,
                      isLoading: isLoading,
                      icon: Icons.search_rounded,
                      color: const Color(0xFFFF9100),
                    ),
                  ),
                ],
              ),
 
            if (selectedImage != null && !isLoading && result == null) ...[
              const SizedBox(height: 12),
            ],
 
            if (result != null) ...[
              const SizedBox(height: 28),
 
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.white.withOpacity(0.08))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'RESULTADO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.3),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.white.withOpacity(0.08))),
                ],
              ),
 
              const SizedBox(height: 20),
 
              RiskBadge(
                score: riskScore,
                classification: result!['classification'],
              ),
 
              const SizedBox(height: 16),
 
              DetectedSignalsList(signals: result!['detectedSignals']),
 
              const SizedBox(height: 16),
 
              AdviceCard(advice: result!['advice']),
 
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}