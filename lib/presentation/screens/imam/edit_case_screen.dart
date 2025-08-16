import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../data/models/case_model.dart';
import '../../providers/case_provider.dart';

class EditCaseScreen extends StatefulWidget {
  final String caseId;

  const EditCaseScreen({
    super.key,
    required this.caseId,
  });

  @override
  State<EditCaseScreen> createState() => _EditCaseScreenState();
}

class _EditCaseScreenState extends State<EditCaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _locationController = TextEditingController();
  
  CaseModel? _caseDetails;
  CaseType _selectedType = CaseType.medical;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCaseDetails();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadCaseDetails() async {
    final caseProvider = Provider.of<CaseProvider>(context, listen: false);
    final details = await caseProvider.getCaseById(widget.caseId);
    
    if (mounted && details != null) {
      setState(() {
        _caseDetails = details;
        _titleController.text = details.title;
        _descriptionController.text = details.description;
        _targetAmountController.text = details.targetAmount.toStringAsFixed(0);
        _locationController.text = details.location;
        _selectedType = details.type;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateCase() async {
    if (!_formKey.currentState!.validate()) return;
    if (_caseDetails == null) return;

    setState(() {
      _isSubmitting = true;
    });

    final caseProvider = Provider.of<CaseProvider>(context, listen: false);
    
    final updatedCase = _caseDetails!.copyWith(
      title: _titleController.text,
      description: _descriptionController.text,
      type: _selectedType,
      targetAmount: double.parse(_targetAmountController.text),
      location: _locationController.text,
      updatedAt: DateTime.now(),
    );

    final success = await caseProvider.updateCase(updatedCase);

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Case updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update case'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Case'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: AppTheme.whiteColor,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_caseDetails == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Case'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: AppTheme.whiteColor,
        ),
        body: const Center(
          child: Text('Case not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Case'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.whiteColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Case Status Banner
              if (_caseDetails!.status != CaseStatus.pending)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Only pending cases can be edited. This case is ${_caseDetails!.status.toString().split('.').last}.',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              const Text(
                'Case Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // Case Title
              TextFormField(
                controller: _titleController,
                enabled: _caseDetails!.status == CaseStatus.pending,
                decoration: InputDecoration(
                  labelText: 'Case Title',
                  hintText: 'Enter a descriptive title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Case Type
              DropdownButtonFormField<CaseType>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Case Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.category),
                  enabled: _caseDetails!.status == CaseStatus.pending,
                ),
                items: CaseType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last.toUpperCase()),
                  );
                }).toList(),
                onChanged: _caseDetails!.status == CaseStatus.pending
                    ? (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      }
                    : null,
              ),
              const SizedBox(height: 16),
              
              // Target Amount
              TextFormField(
                controller: _targetAmountController,
                keyboardType: TextInputType.number,
                enabled: _caseDetails!.status == CaseStatus.pending,
                decoration: InputDecoration(
                  labelText: 'Target Amount (PKR)',
                  hintText: 'Enter target amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter target amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                enabled: _caseDetails!.status == CaseStatus.pending,
                decoration: InputDecoration(
                  labelText: 'Case Description',
                  hintText: 'Provide detailed information about the case',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  if (value.length < 50) {
                    return 'Description must be at least 50 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Location
              TextFormField(
                controller: _locationController,
                enabled: _caseDetails!.status == CaseStatus.pending,
                decoration: InputDecoration(
                  labelText: 'Location',
                  hintText: 'Enter location/address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Beneficiary Information (Read-only)
              const Text(
                'Beneficiary Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person, size: 20, color: AppTheme.greyColor),
                        const SizedBox(width: 8),
                        Text(
                          'Name: ${_caseDetails!.beneficiaryName}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.badge, size: 20, color: AppTheme.greyColor),
                        const SizedBox(width: 8),
                        Text(
                          'CNIC: ${_caseDetails!.beneficiaryId}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Update Button
              if (_caseDetails!.status == CaseStatus.pending)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _updateCase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(
                            color: AppTheme.whiteColor,
                          )
                        : const Text(
                            'Update Case',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}