import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/themes/app_theme.dart';
import '../../../data/models/case_model.dart';
import '../../providers/case_provider.dart';
import '../../providers/auth_provider.dart';

class CreateCaseScreen extends StatefulWidget {
  const CreateCaseScreen({super.key});

  @override
  State<CreateCaseScreen> createState() => _CreateCaseScreenState();
}

class _CreateCaseScreenState extends State<CreateCaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _beneficiaryNameController = TextEditingController();
  final _beneficiaryIdController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _locationController = TextEditingController();
  
  CaseType _selectedType = CaseType.medical;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _beneficiaryNameController.dispose();
    _beneficiaryIdController.dispose();
    _targetAmountController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submitCase() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final caseProvider = Provider.of<CaseProvider>(context, listen: false);
    
    final newCase = CaseModel(
      id: const Uuid().v4(),
      beneficiaryName: _beneficiaryNameController.text,
      beneficiaryId: _beneficiaryIdController.text,
      title: _titleController.text,
      description: _descriptionController.text,
      type: _selectedType,
      targetAmount: double.parse(_targetAmountController.text),
      raisedAmount: 0,
      location: _locationController.text,
      mosqueId: authProvider.user?.id ?? 'mosque_001',
      mosqueName: authProvider.user?.additionalInfo?['mosqueName'] ?? 'Masjid Al-Noor',
      isImamVerified: true, // Auto-verified since created by Imam
      isAdminApproved: false,
      status: CaseStatus.pending,
      createdAt: DateTime.now(),
      documentUrls: [],
      imageUrls: [],
    );

    final success = await caseProvider.createCase(newCase);

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Case created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create case'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Case'),
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
                ),
                items: CaseType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Target Amount
              TextFormField(
                controller: _targetAmountController,
                keyboardType: TextInputType.number,
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
              const SizedBox(height: 24),
              
              const Text(
                'Beneficiary Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // Beneficiary Name
              TextFormField(
                controller: _beneficiaryNameController,
                decoration: InputDecoration(
                  labelText: 'Beneficiary Name',
                  hintText: 'Enter beneficiary full name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter beneficiary name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Beneficiary ID/CNIC
              TextFormField(
                controller: _beneficiaryIdController,
                decoration: InputDecoration(
                  labelText: 'Beneficiary CNIC',
                  hintText: '12345-1234567-1',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.badge),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter beneficiary CNIC';
                  }
                  // Basic CNIC format validation
                  final regex = RegExp(r'^\d{5}-\d{7}-\d$');
                  if (!regex.hasMatch(value)) {
                    return 'Invalid CNIC format (12345-1234567-1)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Location
              TextFormField(
                controller: _locationController,
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
              
              // Document Upload Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.cloud_upload,
                      size: 48,
                      color: AppTheme.greyColor,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Upload Supporting Documents',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Medical reports, bills, etc. (Optional)',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.greyColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {
                        // Mock file upload
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('File upload will be available with backend integration'),
                          ),
                        );
                      },
                      child: const Text('Choose Files'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitCase,
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
                          'Create Case',
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