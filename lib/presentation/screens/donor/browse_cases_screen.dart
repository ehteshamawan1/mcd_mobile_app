import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/color_utils.dart';
import '../../../data/models/case_model.dart';
import '../../../presentation/providers/case_provider.dart';

class BrowseCasesScreen extends StatefulWidget {
  const BrowseCasesScreen({super.key});

  @override
  State<BrowseCasesScreen> createState() => _BrowseCasesScreenState();
}

class _BrowseCasesScreenState extends State<BrowseCasesScreen> {
  CaseType? _selectedCategory;
  String? _selectedCity;
  final _searchController = TextEditingController();
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CaseProvider>(context, listen: false).loadCases();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CaseModel> _filterCases(List<CaseModel> cases) {
    var filtered = cases.where((c) => c.status == CaseStatus.active).toList();
    
    if (_selectedCategory != null) {
      filtered = filtered.where((c) => c.type == _selectedCategory).toList();
    }
    
    if (_selectedCity != null && _selectedCity!.isNotEmpty) {
      filtered = filtered.where((c) => 
        c.location.toLowerCase().contains(_selectedCity!.toLowerCase())
      ).toList();
    }
    
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((c) => 
        c.title.toLowerCase().contains(query) ||
        c.description.toLowerCase().contains(query) ||
        c.beneficiaryName.toLowerCase().contains(query)
      ).toList();
    }
    
    return filtered;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.whiteColor,
        elevation: 0,
        title: const Text(
          'Browse Cases',
          style: TextStyle(
            color: AppTheme.secondaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isGridView ? Icons.list : Icons.grid_view,
              color: AppTheme.secondaryColor,
            ),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.filter_list,
              color: AppTheme.secondaryColor,
            ),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: AppTheme.whiteColor,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search cases...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.secondaryColor),
                ),
                filled: true,
                fillColor: AppTheme.backgroundColor,
              ),
            ),
          ),
          
          // Category Chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildCategoryChip(null, 'All'),
                ...CaseType.values.map((type) => 
                  _buildCategoryChip(type, type.name.toUpperCase())
                ),
              ],
            ),
          ),
          
          // Cases List/Grid
          Expanded(
            child: Consumer<CaseProvider>(
              builder: (context, caseProvider, child) {
                final filteredCases = _filterCases(caseProvider.cases);
                
                if (caseProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.secondaryColor,
                    ),
                  );
                }
                
                if (filteredCases.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No cases found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: () async {
                    await caseProvider.loadCases();
                  },
                  color: AppTheme.secondaryColor,
                  child: _isGridView
                      ? GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: filteredCases.length,
                          itemBuilder: (context, index) => 
                            _buildCaseGridItem(filteredCases[index]),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredCases.length,
                          itemBuilder: (context, index) => 
                            _buildCaseListItem(filteredCases[index]),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(CaseType? type, String label) {
    final isSelected = _selectedCategory == type;
    final color = type != null ? _getCategoryColor(type) : AppTheme.secondaryColor;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? type : null;
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
      ),
    );
  }

  Widget _buildCaseListItem(CaseModel caseItem) {
    final progress = caseItem.targetAmount > 0
        ? (caseItem.raisedAmount / caseItem.targetAmount)
        : 0.0;
    final categoryColor = _getCategoryColor(caseItem.type);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          context.push('/donor/case-details/${caseItem.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorUtils.withOpacity(categoryColor, 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(caseItem.type),
                      size: 20,
                      color: categoryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          caseItem.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          caseItem.beneficiaryName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.greyColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (caseItem.isImamVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ColorUtils.withOpacity(
                          AppTheme.successColor,
                          0.1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.verified,
                            size: 12,
                            color: AppTheme.successColor,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.successColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                caseItem.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.greyColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    caseItem.location,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.mosque,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      caseItem.mosqueName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PKR ${caseItem.raisedAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                      Text(
                        'of PKR ${caseItem.targetAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.push('/donor/donate/${caseItem.id}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Donate',
                      style: TextStyle(
                        color: AppTheme.whiteColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.secondaryColor,
                ),
                minHeight: 4,
              ),
              const SizedBox(height: 4),
              Text(
                '${(progress * 100).toStringAsFixed(0)}% funded',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaseGridItem(CaseModel caseItem) {
    final progress = caseItem.targetAmount > 0
        ? (caseItem.raisedAmount / caseItem.targetAmount)
        : 0.0;
    final categoryColor = _getCategoryColor(caseItem.type);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          context.push('/donor/case-details/${caseItem.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: ColorUtils.withOpacity(categoryColor, 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      _getCategoryIcon(caseItem.type),
                      size: 16,
                      color: categoryColor,
                    ),
                  ),
                  const Spacer(),
                  if (caseItem.isImamVerified)
                    Icon(
                      Icons.verified,
                      size: 16,
                      color: AppTheme.successColor,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                caseItem.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                caseItem.beneficiaryName,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.greyColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Text(
                'PKR ${caseItem.raisedAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryColor,
                ),
              ),
              Text(
                'of ${caseItem.targetAmount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.secondaryColor,
                ),
                minHeight: 4,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    caseItem.location.split(',')[0],
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Cases',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'City',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCity,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                hint: const Text('Select city'),
                items: [
                  const DropdownMenuItem(
                    value: '',
                    child: Text('All Cities'),
                  ),
                  ...['Karachi', 'Lahore', 'Islamabad', 'Rawalpindi', 'Faisalabad']
                      .map((city) => DropdownMenuItem(
                            value: city,
                            child: Text(city),
                          )),
                ],
                onChanged: (value) {
                  setModalState(() {
                    _selectedCity = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedCity = null;
                          _selectedCategory = null;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                      ),
                      child: const Text(
                        'Apply',
                        style: TextStyle(color: AppTheme.whiteColor),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}