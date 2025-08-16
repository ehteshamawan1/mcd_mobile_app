import 'package:flutter/material.dart';
import '../../data/models/case_model.dart';
import '../../data/services/mock_case_service.dart';

class CaseProvider extends ChangeNotifier {
  final MockCaseService _caseService = MockCaseService();
  
  List<CaseModel> _cases = [];
  List<CaseModel> _filteredCases = [];
  List<CaseModel> _userCases = [];
  String? _currentUserId;
  bool _isLoading = false;
  String _errorMessage = '';
  
  // Filters
  CaseType? _selectedType;
  CaseStatus? _selectedStatus;
  String _searchQuery = '';
  String _selectedCity = '';

  List<CaseModel> get cases => _filteredCases.isEmpty ? _cases : _filteredCases;
  List<CaseModel> get allCases => _cases;
  List<CaseModel> get userCases => _userCases;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  CaseType? get selectedType => _selectedType;
  CaseStatus? get selectedStatus => _selectedStatus;
  String get searchQuery => _searchQuery;
  String get selectedCity => _selectedCity;

  CaseProvider() {
    loadCases();
  }

  Future<void> loadCases() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _cases = await _caseService.getAllCases();
      _applyFilters();
    } catch (e) {
      _errorMessage = 'Failed to load cases: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<CaseModel?> getCaseById(String id) async {
    try {
      return _cases.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  List<CaseModel> getCasesByUserId(String userId) {
    return _cases.where((c) => c.beneficiaryId == userId).toList();
  }

  Future<void> loadUserCases(String userId) async {
    _isLoading = true;
    _currentUserId = userId;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _userCases = _cases.where((c) => c.beneficiaryId == userId).toList();
    } catch (e) {
      _errorMessage = 'Failed to load user cases: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<CaseModel> getCasesByMosqueId(String mosqueId) {
    return _cases.where((c) => c.mosqueId == mosqueId).toList();
  }

  List<CaseModel> getActiveCases() {
    return _cases.where((c) => c.status == CaseStatus.active).toList();
  }

  List<CaseModel> getPendingCases() {
    return _cases.where((c) => c.status == CaseStatus.pending).toList();
  }

  Future<bool> createCase(CaseModel newCase) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));
      _cases.add(newCase);
      // Update user cases if this case belongs to the current user being tracked
      if (_currentUserId != null && _currentUserId == newCase.beneficiaryId) {
        _userCases.add(newCase);
      }
      _applyFilters();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create case: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addCase(CaseModel newCase) {
    _cases.add(newCase);
    _applyFilters();
    notifyListeners();
  }

  Future<bool> updateCase(CaseModel updatedCase) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      final index = _cases.indexWhere((c) => c.id == updatedCase.id);
      if (index != -1) {
        _cases[index] = updatedCase;
        _applyFilters();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update case: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCase(String caseId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _cases.removeWhere((c) => c.id == caseId);
      _applyFilters();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete case: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setTypeFilter(CaseType? type) {
    _selectedType = type;
    _applyFilters();
    notifyListeners();
  }

  void setStatusFilter(CaseStatus? status) {
    _selectedStatus = status;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setCityFilter(String city) {
    _selectedCity = city;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _selectedType = null;
    _selectedStatus = null;
    _searchQuery = '';
    _selectedCity = '';
    _filteredCases = [];
    notifyListeners();
  }

  void _applyFilters() {
    _filteredCases = _cases.where((caseModel) {
      bool matchesType = _selectedType == null || caseModel.type == _selectedType;
      bool matchesStatus = _selectedStatus == null || caseModel.status == _selectedStatus;
      bool matchesSearch = _searchQuery.isEmpty ||
          caseModel.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          caseModel.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          caseModel.beneficiaryName.toLowerCase().contains(_searchQuery.toLowerCase());
      bool matchesCity = _selectedCity.isEmpty ||
          caseModel.location.toLowerCase().contains(_selectedCity.toLowerCase());
      
      return matchesType && matchesStatus && matchesSearch && matchesCity;
    }).toList();
  }

  void updateCaseProgress(String caseId, double newAmount) {
    final index = _cases.indexWhere((c) => c.id == caseId);
    if (index != -1) {
      final updatedCase = _cases[index].copyWith(
        raisedAmount: _cases[index].raisedAmount + newAmount,
        status: (_cases[index].raisedAmount + newAmount >= _cases[index].targetAmount)
            ? CaseStatus.completed
            : _cases[index].status,
      );
      _cases[index] = updatedCase;
      _applyFilters();
      notifyListeners();
    }
  }
  
  // Alias for updateCaseProgress for clarity
  void updateCaseRaisedAmount(String caseId, double amount) {
    updateCaseProgress(caseId, amount);
  }
}