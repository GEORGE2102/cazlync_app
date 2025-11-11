import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/search_providers.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late RangeValues _priceRange;
  late RangeValues _yearRange;
  late double _maxMileage;
  String? _selectedCondition;
  String? _selectedTransmission;
  String? _selectedFuelType;

  @override
  void initState() {
    super.initState();
    final filters = ref.read(searchControllerProvider).filters;
    
    _brandController = TextEditingController(text: filters.brand);
    _modelController = TextEditingController(text: filters.model);
    _priceRange = RangeValues(
      filters.minPrice?.toDouble() ?? 0,
      filters.maxPrice?.toDouble() ?? 1000000,
    );
    _yearRange = RangeValues(
      filters.minYear?.toDouble() ?? 1990,
      filters.maxYear?.toDouble() ?? DateTime.now().year.toDouble(),
    );
    _maxMileage = filters.maxMileage?.toDouble() ?? 500000;
    _selectedCondition = filters.condition;
    _selectedTransmission = filters.transmission;
    _selectedFuelType = filters.fuelType;
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final notifier = ref.read(searchControllerProvider.notifier);
    
    if (_brandController.text.isNotEmpty) {
      notifier.updateBrand(_brandController.text);
    }
    if (_modelController.text.isNotEmpty) {
      notifier.updateModel(_modelController.text);
    }
    if (_priceRange.start > 0 || _priceRange.end < 1000000) {
      notifier.updatePriceRange(
        _priceRange.start.toInt(),
        _priceRange.end.toInt(),
      );
    }
    if (_yearRange.start > 1990 || _yearRange.end < DateTime.now().year) {
      notifier.updateYearRange(
        _yearRange.start.toInt(),
        _yearRange.end.toInt(),
      );
    }
    if (_maxMileage < 500000) {
      notifier.updateMaxMileage(_maxMileage.toInt());
    }
    if (_selectedCondition != null) {
      notifier.updateCondition(_selectedCondition);
    }
    if (_selectedTransmission != null) {
      notifier.updateTransmission(_selectedTransmission);
    }
    if (_selectedFuelType != null) {
      notifier.updateFuelType(_selectedFuelType);
    }

    Navigator.pop(context);
  }

  void _resetFilters() {
    setState(() {
      _brandController.clear();
      _modelController.clear();
      _priceRange = const RangeValues(0, 1000000);
      _yearRange = RangeValues(1990, DateTime.now().year.toDouble());
      _maxMileage = 500000;
      _selectedCondition = null;
      _selectedTransmission = null;
      _selectedFuelType = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Filter options
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand and Model
                  _buildSectionTitle('Make & Model'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _brandController,
                    decoration: const InputDecoration(
                      labelText: 'Brand',
                      hintText: 'e.g., Toyota, Honda',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.directions_car),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _modelController,
                    decoration: const InputDecoration(
                      labelText: 'Model',
                      hintText: 'e.g., Corolla, Civic',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.car_rental),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Price Range
                  _buildSectionTitle('Price Range'),
                  const SizedBox(height: 8),
                  Text(
                    'K${_priceRange.start.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} - K${_priceRange.end.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 1000000,
                    divisions: 100,
                    labels: RangeLabels(
                      'K${_priceRange.start.toInt()}',
                      'K${_priceRange.end.toInt()}',
                    ),
                    onChanged: (values) {
                      setState(() => _priceRange = values);
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Year Range
                  _buildSectionTitle('Year'),
                  const SizedBox(height: 8),
                  Text(
                    '${_yearRange.start.toInt()} - ${_yearRange.end.toInt()}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  RangeSlider(
                    values: _yearRange,
                    min: 1990,
                    max: DateTime.now().year.toDouble(),
                    divisions: DateTime.now().year - 1990,
                    labels: RangeLabels(
                      _yearRange.start.toInt().toString(),
                      _yearRange.end.toInt().toString(),
                    ),
                    onChanged: (values) {
                      setState(() => _yearRange = values);
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Mileage
                  _buildSectionTitle('Maximum Mileage'),
                  const SizedBox(height: 8),
                  Text(
                    '${_maxMileage.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} km',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Slider(
                    value: _maxMileage,
                    min: 0,
                    max: 500000,
                    divisions: 50,
                    label: '${_maxMileage.toInt()} km',
                    onChanged: (value) {
                      setState(() => _maxMileage = value);
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Condition
                  _buildSectionTitle('Condition'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildChoiceChip('New', _selectedCondition == 'New', () {
                        setState(() => _selectedCondition = 'New');
                      }),
                      _buildChoiceChip('Used', _selectedCondition == 'Used', () {
                        setState(() => _selectedCondition = 'Used');
                      }),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Transmission
                  _buildSectionTitle('Transmission'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildChoiceChip('Automatic', _selectedTransmission == 'Automatic', () {
                        setState(() => _selectedTransmission = 'Automatic');
                      }),
                      _buildChoiceChip('Manual', _selectedTransmission == 'Manual', () {
                        setState(() => _selectedTransmission = 'Manual');
                      }),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Fuel Type
                  _buildSectionTitle('Fuel Type'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChoiceChip('Petrol', _selectedFuelType == 'Petrol', () {
                        setState(() => _selectedFuelType = 'Petrol');
                      }),
                      _buildChoiceChip('Diesel', _selectedFuelType == 'Diesel', () {
                        setState(() => _selectedFuelType = 'Diesel');
                      }),
                      _buildChoiceChip('Electric', _selectedFuelType == 'Electric', () {
                        setState(() => _selectedFuelType = 'Electric');
                      }),
                      _buildChoiceChip('Hybrid', _selectedFuelType == 'Hybrid', () {
                        setState(() => _selectedFuelType = 'Hybrid');
                      }),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          
          // Apply button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildChoiceChip(String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      labelStyle: TextStyle(
        color: selected
            ? Theme.of(context).colorScheme.primary
            : Colors.grey[700],
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
