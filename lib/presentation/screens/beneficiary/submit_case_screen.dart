import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/color_utils.dart';
import '../../../data/models/case_model.dart';
import '../../../presentation/providers/case_provider.dart';
import '../../../presentation/providers/auth_provider.dart';

class SubmitCaseScreen extends StatefulWidget {
  const SubmitCaseScreen({super.key});

  @override
  State<SubmitCaseScreen> createState() => _SubmitCaseScreenState();
}

class _SubmitCaseScreenState extends State<SubmitCaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _uuid = const Uuid();
  
  CaseType _selectedType = CaseType.medical;
  String _selectedMosque = 'Jamia Masjid Karachi';
  final List<String> _uploadedDocuments = [];

  final List<String> _mosques = [
    'Jamia Masjid Karachi',
    'Faisal Mosque Islamabad',
    'Badshahi Mosque Lahore',
    'Masjid-e-Tooba Karachi',
    'Data Darbar Mosque Lahore',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  Color _getCategoryColor(CaseType type) {
    switch (type) {
      case CaseType.medical:
        return Colors.red;
      case CaseType.education:
        return Colors.blue;
      case CaseType.emergency:
        return Colors.orange;
      case CaseType.housing:
        return Colors.purple;
      case CaseType.food:
        return Colors.green;
      case CaseType.other:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(CaseType type) {
    switch (type) {
      case CaseType.medical:
        return Icons.local_hospital;
      case CaseType.education:
        return Icons.school;
      case CaseType.emergency:
        return Icons.warning;
      case CaseType.housing:
        return Icons.home;
      case CaseType.food:
        return Icons.restaurant;
      case CaseType.other:
        return Icons.category;
    }
  }

  Future<void> _submitCase() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_uploadedDocuments.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please upload at least one supporting document',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.errorColor,
        textColor: AppTheme.whiteColor,
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final caseProvider = Provider.of<CaseProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) {
      Fluttertoast.showToast(
        msg: 'Please login to submit a case',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.errorColor,
        textColor: AppTheme.whiteColor,
      );
      return;
    }

    final newCase = CaseModel(
      id: _uuid.v4(),
      beneficiaryName: user.name,
      beneficiaryId: user.id,
      title: _titleController.text,
      description: _descriptionController.text,
      type: _selectedType,
      targetAmount: double.parse(_targetAmountController.text),
      raisedAmount: 0,
      location: user.location,
      mosqueId: _uuid.v4(),
      mosqueName: _selectedMosque,
      isImamVerified: false,
      isAdminApproved: false,
      status: CaseStatus.pending,
      createdAt: DateTime.now(),
      documentUrls: _uploadedDocuments,
      imageUrls: [],
    );

    final success = await caseProvider.createCase(newCase);

    if (!mounted) return;

    if (success) {
      Fluttertoast.showToast(
        msg: 'Case submitted successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.successColor,
        textColor: AppTheme.whiteColor,
      );
      
      // Clear form
      _titleController.clear();
      _descriptionController.clear();
      _targetAmountController.clear();
      setState(() {
        _uploadedDocuments.clear();
        _selectedType = CaseType.medical;
      });
    } else {
      Fluttertoast.showToast(
        msg: 'Failed to submit case. Please try again.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.errorColor,
        textColor: AppTheme.whiteColor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.whiteColor,
        elevation: 0,
        title: const Text(
          'Submit New Case',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Instructions Card
              Card(
                elevation: 0,
                color: ColorUtils.withOpacity(Colors.green, 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: ColorUtils.withOpacity(Colors.green, 0.3),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.info_outline,
                            color: Colors.green,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Important Instructions',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '• Provide accurate and complete information\n'
                        '• Upload supporting documents\n'
                        '• Your case will be verified by the Imam\n'
                        '• Once approved, donors can contribute',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.greyColor,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Case Category
              const Text(
                'Case Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: CaseType.values.map((type) {
                  final isSelected = _selectedType == type;
                  final color = _getCategoryColor(type);
                  
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getCategoryIcon(type),
                          size: 16,
                          color: isSelected ? color : AppTheme.greyColor,
                        ),
                        const SizedBox(width: 4),
                        Text(type.name.toUpperCase()),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedType = type;
                      });
                    },
                    backgroundColor: AppTheme.whiteColor,
                    selectedColor: ColorUtils.withOpacity(color, 0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? color : AppTheme.greyColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? color : Colors.grey[300]!,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Case Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Case Title',
                  hintText: 'Brief title for your case',
                  prefixIcon: Icon(Icons.title, color: Colors.green),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  if (value.length < 10) {
                    return 'Title must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe your situation and need',
                  prefixIcon: Icon(Icons.description, color: Colors.green),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
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

              // Target Amount
              TextFormField(
                controller: _targetAmountController,
                decoration: const InputDecoration(
                  labelText: 'Target Amount (PKR)',
                  hintText: 'Amount needed',
                  prefixIcon: Icon(Icons.attach_money, color: Colors.green),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter target amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  if (amount < 1000) {
                    return 'Minimum amount is PKR 1,000';
                  }
                  if (amount > 1000000) {
                    return 'Maximum amount is PKR 1,000,000';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Mosque Selection
              DropdownButtonFormField<String>(
                value: _selectedMosque,
                decoration: const InputDecoration(
                  labelText: 'Select Mosque',
                  prefixIcon: Icon(Icons.mosque, color: Colors.green),
                ),
                items: _mosques.map((mosque) {
                  return DropdownMenuItem(
                    value: mosque,
                    child: Text(mosque),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMosque = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a mosque';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Document Upload Section
              const Text(
                'Supporting Documents',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload documents to support your case',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),

              // Uploaded Documents List
              if (_uploadedDocuments.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ColorUtils.withOpacity(Colors.green, 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: ColorUtils.withOpacity(Colors.green, 0.2),
                    ),
                  ),
                  child: Column(
                    children: _uploadedDocuments.map((doc) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.file_present,
                              size: 20,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                doc,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                size: 18,
                                color: AppTheme.errorColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _uploadedDocuments.remove(doc);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Upload Button
              OutlinedButton.icon(
                onPressed: () {
                  // Mock file upload
                  setState(() {
                    _uploadedDocuments.add(
                      'Document_${_uploadedDocuments.length + 1}.pdf'
                    );
                  });
                  Fluttertoast.showToast(
                    msg: 'Document uploaded successfully',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: AppTheme.successColor,
                    textColor: AppTheme.whiteColor,
                  );
                },
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Document'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green,
                  side: const BorderSide(color: Colors.green),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              Consumer<CaseProvider>(
                builder: (context, caseProvider, child) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: caseProvider.isLoading ? null : _submitCase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: caseProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.whiteColor,
                                ),
                              ),
                            )
                          : const Text(
                              'Submit Case',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.whiteColor,
                              ),
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}