import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/color_utils.dart';
import '../../../data/models/mosque_model.dart';

class MosqueLibraryScreen extends StatefulWidget {
  const MosqueLibraryScreen({super.key});

  @override
  State<MosqueLibraryScreen> createState() => _MosqueLibraryScreenState();
}

class _MosqueLibraryScreenState extends State<MosqueLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCity = 'All Cities';
  bool _verifiedOnly = false;
  List<MosqueModel> _filteredMosques = [];
  
  // Mock data for mosques
  final List<MosqueModel> _mosques = [
    MosqueModel(
      id: '1',
      name: 'Faisal Mosque',
      address: 'Islamabad Capital Territory',
      city: 'Islamabad',
      imamId: 'imam1',
      imamName: 'Imam Muhammad Ali',
      muazzinName: 'Ahmad Hassan',
      contactNumber: '+92-51-9261045',
      email: 'info@faisalmosque.pk',
      prayerCount: 250000,
      isVerified: true,
      createdAt: DateTime(2020, 1, 1),
    ),
    MosqueModel(
      id: '2',
      name: 'Badshahi Mosque',
      address: 'Walled City, Lahore',
      city: 'Lahore',
      imamId: 'imam2',
      imamName: 'Imam Abdul Rahman',
      muazzinName: 'Bilal Ahmed',
      contactNumber: '+92-42-37220645',
      email: 'info@badshahimosque.pk',
      prayerCount: 100000,
      isVerified: true,
      createdAt: DateTime(2020, 2, 1),
    ),
    MosqueModel(
      id: '3',
      name: 'Masjid-e-Tooba',
      address: 'DHA Phase 2, Karachi',
      city: 'Karachi',
      imamId: 'imam3',
      imamName: 'Imam Usman Khan',
      muazzinName: 'Saeed Ahmad',
      contactNumber: '+92-21-35311234',
      email: 'info@masjidtooba.pk',
      prayerCount: 75000,
      isVerified: true,
      createdAt: DateTime(2020, 3, 1),
    ),
    MosqueModel(
      id: '4',
      name: 'Jamia Masjid',
      address: 'M.A. Jinnah Road, Karachi',
      city: 'Karachi',
      imamId: 'imam4',
      imamName: 'Imam Hassan Ali',
      muazzinName: 'Abdullah Shah',
      contactNumber: '+92-21-32456789',
      email: 'info@jamimasjid.pk',
      prayerCount: 50000,
      isVerified: true,
      createdAt: DateTime(2020, 4, 1),
    ),
    MosqueModel(
      id: '5',
      name: 'Data Darbar Mosque',
      address: 'Old City, Lahore',
      city: 'Lahore',
      imamId: 'imam5',
      imamName: 'Imam Tariq Jameel',
      muazzinName: 'Hafiz Qari Saeed',
      contactNumber: '+92-42-37654321',
      email: 'info@datadarbar.pk',
      prayerCount: 80000,
      isVerified: true,
      createdAt: DateTime(2020, 5, 1),
    ),
    MosqueModel(
      id: '6',
      name: 'Al-Noor Mosque',
      address: 'F-8 Sector, Islamabad',
      city: 'Islamabad',
      imamId: 'imam6',
      imamName: 'Imam Khalid Mahmood',
      muazzinName: 'Qari Fahad',
      contactNumber: '+92-51-2345678',
      email: 'info@alnoor.pk',
      prayerCount: 15000,
      isVerified: false,
      createdAt: DateTime(2021, 1, 1),
    ),
  ];

  final List<String> _cities = [
    'All Cities',
    'Karachi',
    'Lahore',
    'Islamabad',
    'Rawalpindi',
    'Faisalabad',
    'Peshawar',
    'Quetta',
  ];

  @override
  void initState() {
    super.initState();
    _filteredMosques = _mosques;
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      _filteredMosques = _mosques.where((mosque) {
        // Search filter
        final searchTerm = _searchController.text.toLowerCase();
        final matchesSearch = searchTerm.isEmpty ||
            mosque.name.toLowerCase().contains(searchTerm) ||
            mosque.address.toLowerCase().contains(searchTerm) ||
            mosque.imamName.toLowerCase().contains(searchTerm);
        
        // City filter
        final matchesCity = _selectedCity == 'All Cities' ||
            mosque.city == _selectedCity;
        
        // Verified filter
        final matchesVerified = !_verifiedOnly || mosque.isVerified;
        
        return matchesSearch && matchesCity && matchesVerified;
      }).toList();
      
      // Sort by prayer count (descending)
      _filteredMosques.sort((a, b) => b.prayerCount.compareTo(a.prayerCount));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Mosque Library',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.whiteColor,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search mosques, imam names, or addresses',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Filter Row
                Row(
                  children: [
                    // City Filter
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCity,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            isExpanded: true,
                            items: _cities.map((city) {
                              return DropdownMenuItem(
                                value: city,
                                child: Text(city),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCity = value!;
                              });
                              _applyFilters();
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Verified Filter
                    FilterChip(
                      label: const Text('Verified Only'),
                      selected: _verifiedOnly,
                      onSelected: (selected) {
                        setState(() {
                          _verifiedOnly = selected;
                        });
                        _applyFilters();
                      },
                      selectedColor: ColorUtils.withOpacity(AppTheme.primaryColor, 0.2),
                      checkmarkColor: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Results Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.grey[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredMosques.length} mosques found',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.greyColor,
                  ),
                ),
                Icon(
                  Icons.mosque,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
          
          // Mosque List
          Expanded(
            child: _filteredMosques.isEmpty
                ? Center(
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
                          'No mosques found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredMosques.length,
                    itemBuilder: (context, index) {
                      final mosque = _filteredMosques[index];
                      return _buildMosqueCard(mosque);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMosqueCard(MosqueModel mosque) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ColorUtils.withOpacity(AppTheme.primaryColor, 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.mosque,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              mosque.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (mosque.isVerified)
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
                                mainAxisSize: MainAxisSize.min,
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
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.successColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${mosque.address}, ${mosque.city}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Details Grid
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          'Imam',
                          mosque.imamName,
                          Icons.person,
                        ),
                      ),
                      if (mosque.muazzinName != null)
                        Expanded(
                          child: _buildDetailItem(
                            'Muazzin',
                            mosque.muazzinName!,
                            Icons.record_voice_over,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          'Prayer Count',
                          _formatPrayerCount(mosque.prayerCount),
                          Icons.people,
                        ),
                      ),
                      if (mosque.contactNumber != null)
                        Expanded(
                          child: _buildDetailItem(
                            'Contact',
                            mosque.contactNumber!,
                            Icons.phone,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            if (mosque.email != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.email,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    mosque.email!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatPrayerCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }
}