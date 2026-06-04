import 'package:flutter/foundation.dart';
import 'package:ndzalama_mobile/models/FinancialHealth.dart';

import '../services/financial_service.dart';

class FinancialProvider extends ChangeNotifier {
  final FinancialService _service = FinancialService();
  
  FinancialHealth? _healthReport;
  List<Insight> _insights = [];
  Map<String, dynamic>? _dashboard;
  Map<String, dynamic>? _profile;
  bool _isLoading = false;
  String? _error;

  FinancialHealth? get healthReport => _healthReport;
  List<Insight> get insights => _insights;
  Map<String, dynamic>? get dashboard => _dashboard;
  Map<String, dynamic>? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadHealthReport() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _healthReport = await _service.getHealthReport();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadInsights() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _insights = await _service.getInsights();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> dismissInsight(int insightId) async {
    try {
      await _service.dismissInsight(insightId);
      _insights.removeWhere((i) => i.id == insightId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dashboard = await _service.getDashboard();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _service.getProfile();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void refresh() {
    loadHealthReport();
    loadInsights();
    loadDashboard();
    loadProfile();
  }
}