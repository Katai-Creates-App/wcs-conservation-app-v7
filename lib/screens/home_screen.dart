import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/observation_provider.dart';
import '../models/observation.dart';
import '../widgets/observation_card.dart';
import '../services/observation_storage_service.dart';
import 'observation_form_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _searchQuery = '';
  SpeciesType? _filterType;
  ConservationStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    if (mounted) {
      final provider = Provider.of<ObservationProvider>(context, listen: false);
      await provider.loadObservations();
    }
  }

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ObservationProvider>(context);
    final observations = provider.observations;

    final screens = [
      _buildObservationList(context, observations, provider),
      _buildObservationForm(context),
      SettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conservation Data'),
        actions: [
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterDialog(context),
            ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildObservationList(BuildContext context, List<Observation> observations, ObservationProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading observations...'),
          ],
        ),
      );
    }

    // Apply filters and search
    List<Observation> filteredObservations = observations;
    
    if (_searchQuery.isNotEmpty) {
      filteredObservations = provider.searchObservations(_searchQuery);
    }
    
    if (_filterType != null) {
      filteredObservations = filteredObservations.where((obs) => obs.speciesType == _filterType).toList();
    }
    
    if (_filterStatus != null) {
      filteredObservations = filteredObservations.where((obs) => obs.conservationStatus == _filterStatus).toList();
    }

    return Column(
      children: [
        if (provider.usingFallback)
          Container(
            width: double.infinity,
            color: Colors.orange,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: const Text(
              '⚠️ Using temporary storage - data will not persist after refresh',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        if (provider.errorMessage != null)
          Container(
            width: double.infinity,
            color: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    provider.errorMessage!,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 16),
                  onPressed: provider.clearError,
                ),
              ],
            ),
          ),
        _buildSearchBar(),
        _buildSummaryCard(observations),
        if (filteredObservations.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    observations.isEmpty ? 'No observations yet' : 'No matching observations',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    observations.isEmpty 
                        ? 'Add your first observation to get started'
                        : 'Try adjusting your search or filters',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Text(
                    'Saved Data',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredObservations.length,
                    itemBuilder: (context, index) {
                      return ObservationCard(observation: filteredObservations[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        // Debug button for testing database functionality
        _buildDebugButton(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search observations...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildSummaryCard(List<Observation> observations) {
    final plantCount = observations.where((o) => o.speciesType == SpeciesType.plant).length;
    final animalCount = observations.where((o) => o.speciesType == SpeciesType.animal).length;
    final totalCount = observations.length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSummaryItem(
              icon: Icons.list,
              label: 'Total',
              value: totalCount.toString(),
              color: Theme.of(context).primaryColor,
            ),
            _buildSummaryItem(
              icon: Icons.local_florist,
              label: 'Plants',
              value: plantCount.toString(),
              color: Colors.green,
            ),
            _buildSummaryItem(
              icon: Icons.pets,
              label: 'Animals',
              value: animalCount.toString(),
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Observations'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Species Type'),
              trailing: DropdownButton<SpeciesType?>(
                value: _filterType,
                hint: const Text('All'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All')),
                  ...SpeciesType.values.map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type.name),
                  )),
                ],
                onChanged: (value) {
                  setState(() {
                    _filterType = value;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Conservation Status'),
              trailing: DropdownButton<ConservationStatus?>(
                value: _filterStatus,
                hint: const Text('All'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All')),
                  ...ConservationStatus.values.map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(status.name),
                  )),
                ],
                onChanged: (value) {
                  setState(() {
                    _filterStatus = value;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _filterType = null;
                _filterStatus = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Clear Filters'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: _saveTestData,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        child: const Text('💾 Save Test Data'),
      ),
    );
  }

  Future<void> _saveTestData() async {
    try {
      print('🔧 Debug: Starting test data save...');
      
      // Create storage instance
      print('🔧 Debug: Creating ObservationStorage instance...');
      final storage = ObservationStorage();
      print('🔧 Debug: ObservationStorage instance created successfully');
      
      // Create test observation
      print('🔧 Debug: Creating test observation...');
      final testObservation = Observation(
        speciesName: 'Test Bird Species',
        speciesType: SpeciesType.animal,
        location: 'Near Goroka, Papua New Guinea',
        dateTime: DateTime.now(),
        quantity: 3,
        description: 'Test observation for debugging database functionality',
        conservationStatus: ConservationStatus.healthy,
        habitatType: HabitatType.forest,
      );
      print('🔧 Debug: Test observation created: ${testObservation.speciesName}');
      
      // Save to storage
      print('🔧 Debug: Calling storage.insert...');
      final id = await storage.insert(testObservation);
      print('🔧 Debug: Insert completed with ID: $id');
      
      if (id > 0) {
        print('✅ Debug: Test data saved successfully with ID: $id');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved test data! ID: $id'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Insert returned invalid ID: $id');
      }
    } catch (e, stackTrace) {
      print('❌ Debug: Error saving test data: $e');
      print('❌ Debug: Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildObservationForm(BuildContext context) {
    return ObservationFormScreen(
      onSaveSuccess: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Observation saved!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          // Switch back to the home tab after successful save
          setState(() {
            _selectedIndex = 0;
          });
        }
      },
    );
  }
} 