import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../controllers/listing_providers.dart';
import '../controllers/listing_state.dart';
import '../controllers/auth_providers.dart';
import '../../domain/entities/listing_entity.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  const CreateListingScreen({super.key});

  @override
  ConsumerState<CreateListingScreen> createState() =>
      _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _priceController = TextEditingController();
  final _mileageController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  final List<String> _imagePaths = [];
  final ImagePicker _picker = ImagePicker();
  
  BodyType? _selectedBodyType;
  VehicleCondition? _selectedCondition;
  TransmissionType? _selectedTransmission;
  FuelType? _selectedFuelType;
  bool _contactForPrice = false;

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _priceController.dispose();
    _mileageController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    
    // Clean up copied images if listing wasn't submitted
    _cleanupImages();
    
    super.dispose();
  }
  
  Future<void> _cleanupImages() async {
    for (final imagePath in _imagePaths) {
      try {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // Ignore cleanup errors
      }
    }
  }

  Future<void> _pickImages() async {
    if (_imagePaths.length >= 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 20 images allowed')),
      );
      return;
    }

    try {
      final images = await _picker.pickMultiImage();
      if (images.isEmpty) {
        print('📸 No images selected');
        return;
      }

      // Use application documents directory instead of temp - more persistent
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(path.join(appDir.path, 'pending_uploads'));
      
      // Create directory if it doesn't exist
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      
      final copiedPaths = <String>[];
      
      print('📸 Copying ${images.length} images to: ${imagesDir.path}');
      
      for (final image in images.take(20 - _imagePaths.length)) {
        try {
          final file = File(image.path);
          print('📸 Original path: ${image.path}');
          
          final exists = await file.exists();
          print('📸 File exists: $exists');
          
          if (!exists) {
            print('❌ Source file does not exist, skipping');
            continue;
          }
          
          final fileName = path.basename(image.path);
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final newPath = path.join(imagesDir.path, '${timestamp}_$fileName');
          
          print('📸 Copying to: $newPath');
          final copiedFile = await file.copy(newPath);
          
          final copiedExists = await copiedFile.exists();
          print('📸 Copied file exists: $copiedExists');
          
          if (copiedExists) {
            copiedPaths.add(copiedFile.path);
          }
        } catch (e) {
          print('❌ Error copying image: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to copy image: $e')),
            );
          }
        }
      }
      
      if (copiedPaths.isNotEmpty) {
        setState(() {
          _imagePaths.addAll(copiedPaths);
        });
        print('✅ Added ${copiedPaths.length} images to list');
      } else {
        print('❌ No images were successfully copied');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load images. Please try again.')),
          );
        }
      }
    } catch (e) {
      print('❌ Error in _pickImages: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting images: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imagePaths.removeAt(index);
    });
  }

  Future<void> _submitListing() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imagePaths.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least 3 images')),
      );
      return;
    }

    final authState = ref.read(authControllerProvider);
    if (authState.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to create a listing')),
      );
      return;
    }

    final listing = ListingEntity(
      id: '',
      sellerId: authState.user!.id,
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      year: int.parse(_yearController.text),
      price: _contactForPrice ? 0 : double.parse(_priceController.text),
      mileage: int.parse(_mileageController.text),
      description: _descriptionController.text.trim(),
      imageUrls: [],
      createdAt: DateTime.now(),
      bodyType: _selectedBodyType,
      condition: _selectedCondition,
      transmissionType: _selectedTransmission,
      fuelType: _selectedFuelType,
      location: _locationController.text.trim().isNotEmpty 
          ? _locationController.text.trim() 
          : null,
      contactForPrice: _contactForPrice,
    );

    await ref
        .read(createListingControllerProvider.notifier)
        .createListing(listing, _imagePaths);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createListingControllerProvider);

    ref.listen<CreateListingState>(createListingControllerProvider, (prev, next) {
      if (next.status == ListingStateStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listing created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else if (next.status == ListingStateStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'An error occurred'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Listing'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Helpful tips card
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Quick Tips',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Tap the ? icon next to any field for help\n'
                        '• Fields marked with * are required\n'
                        '• Add clear photos for better results\n'
                        '• Be honest about the car\'s condition',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade900,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildImageSection(),
              const SizedBox(height: 24),
              TextFormField(
                controller: _brandController,
                decoration: InputDecoration(
                  labelText: 'Brand *',
                  hintText: 'e.g., Toyota, Honda, BMW',
                  helperText: 'The manufacturer of the car',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.help_outline, size: 20),
                    onPressed: () => _showHelpDialog(
                      'Car Brand',
                      'The brand is the company that made the car.\n\nCommon brands:\n• Toyota\n• Honda\n• Nissan\n• BMW\n• Mercedes-Benz\n• Mazda\n• Volkswagen\n\nLook for the logo on the front of the car or check the registration documents.',
                    ),
                  ),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter brand';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modelController,
                decoration: InputDecoration(
                  labelText: 'Model *',
                  hintText: 'e.g., Corolla, Civic, X5',
                  helperText: 'The specific model name',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.help_outline, size: 20),
                    onPressed: () => _showHelpDialog(
                      'Car Model',
                      'The model is the specific name of the car.\n\nExamples:\n• Toyota Corolla\n• Honda Civic\n• BMW X5\n• Nissan Patrol\n\nYou can find this on:\n• The back of the car\n• Registration documents\n• Owner\'s manual',
                    ),
                  ),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter model';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _yearController,
                decoration: InputDecoration(
                  labelText: 'Year *',
                  hintText: 'e.g., ${DateTime.now().year}',
                  helperText: 'The year the car was manufactured',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.help_outline, size: 20),
                    onPressed: () => _showHelpDialog(
                      'Manufacturing Year',
                      'The year the car was made.\n\nWhere to find it:\n• Registration documents\n• Vehicle logbook\n• Door frame sticker\n• VIN plate\n\nIf unsure, check your car registration papers - it\'s always listed there.',
                    ),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter year';
                  }
                  final year = int.tryParse(value);
                  if (year == null || year < 1900 || year > DateTime.now().year + 1) {
                    return 'Please enter a valid year';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: _contactForPrice ? 'Price (K)' : 'Price (K) *',
                  hintText: 'e.g., 85000',
                  helperText: 'Enter amount in Zambian Kwacha',
                  border: const OutlineInputBorder(),
                  prefixText: 'K ',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.help_outline, size: 20),
                    onPressed: () => _showHelpDialog(
                      'Pricing Your Car',
                      'Tips for setting a good price:\n\n1. Check similar cars on CazLync\n2. Consider the car\'s:\n   • Age (older = lower price)\n   • Mileage (higher km = lower price)\n   • Condition (better = higher price)\n   • Brand popularity\n\n3. Be realistic - overpriced cars don\'t sell\n4. You can negotiate with buyers\n\nNot sure? Select "Contact for a price" below.',
                    ),
                  ),
                ),
                keyboardType: TextInputType.number,
                enabled: !_contactForPrice,
                validator: (value) {
                  if (_contactForPrice) return null;
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text('Contact for a price'),
                subtitle: const Text('Hide price and show "Contact for a price" instead'),
                value: _contactForPrice,
                onChanged: (value) {
                  setState(() {
                    _contactForPrice = value ?? false;
                    if (_contactForPrice) {
                      _priceController.clear();
                    }
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mileageController,
                decoration: InputDecoration(
                  labelText: 'Mileage (km) *',
                  hintText: 'e.g., 45000',
                  helperText: 'Total kilometers driven',
                  border: const OutlineInputBorder(),
                  suffixText: 'km',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.help_outline, size: 20),
                    onPressed: () => _showHelpDialog(
                      'Car Mileage',
                      'Mileage is the total distance the car has traveled.\n\nWhere to find it:\n• Look at the odometer (the number display on your dashboard)\n• It shows the total kilometers\n\nExample:\n• If it shows 45,234 km, enter: 45234\n• If it shows 120,567 km, enter: 120567\n\nLower mileage usually means:\n• Less wear and tear\n• Higher value\n• Better condition',
                    ),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter mileage';
                  }
                  final mileage = int.tryParse(value);
                  if (mileage == null || mileage < 0) {
                    return 'Please enter a valid mileage';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<BodyType>(
                decoration: InputDecoration(
                  labelText: 'Body Type *',
                  border: const OutlineInputBorder(),
                  hintText: 'Select body type',
                  helperText: 'The shape/style of the car',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.help_outline, size: 20),
                    onPressed: () => _showHelpDialog(
                      'Body Type Guide',
                      'Body type is the shape of your car:\n\n🚙 Sedan: 4 doors, separate trunk (e.g., Corolla, Camry)\n\n🚗 Hatchback: 2-4 doors, rear door opens up (e.g., Vitz, Fit)\n\n🚙 SUV: Tall, spacious, good for rough roads (e.g., Prado, RAV4)\n\n🛻 Pickup: Open cargo bed at back (e.g., Hilux, Ranger)\n\n🚗 Coupe: 2 doors, sporty (e.g., sports cars)\n\n🚐 Van: Large, for passengers/cargo (e.g., Hiace, Caravan)\n\n🚙 Wagon: Like sedan but with more cargo space\n\nNot sure? Choose "Other"',
                    ),
                  ),
                ),
                items: BodyType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getBodyTypeLabel(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBodyType = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select body type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<VehicleCondition>(
                decoration: InputDecoration(
                  labelText: 'Condition *',
                  border: const OutlineInputBorder(),
                  hintText: 'Select condition',
                  helperText: 'How new or used is the car?',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.help_outline, size: 20),
                    onPressed: () => _showHelpDialog(
                      'Car Condition',
                      'Choose the condition that best describes your car:\n\n✨ Brand New:\n• Never been used\n• 0 km on odometer\n• Still has factory warranty\n• Just bought from dealer\n\n🚗 Used:\n• Has been driven before\n• Any mileage above 0\n• Previously owned\n• Most cars fall here\n\nBe honest about the condition - buyers will inspect the car!',
                    ),
                  ),
                ),
                items: VehicleCondition.values.map((condition) {
                  return DropdownMenuItem(
                    value: condition,
                    child: Text(_getConditionLabel(condition)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCondition = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select condition';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TransmissionType>(
                decoration: InputDecoration(
                  labelText: 'Transmission *',
                  border: const OutlineInputBorder(),
                  hintText: 'Select transmission',
                  helperText: 'Manual or automatic gear shifting',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.help_outline, size: 20),
                    onPressed: () => _showHelpDialog(
                      'Transmission Type',
                      'Transmission is how the car changes gears:\n\n🔧 Manual:\n• You shift gears yourself\n• Has a clutch pedal (3 pedals total)\n• Gear stick you move by hand\n• More common in Zambia\n\n⚙️ Automatic:\n• Car shifts gears automatically\n• No clutch pedal (2 pedals only)\n• Just press gas and brake\n• Easier to drive\n\nHow to check:\n• Count the pedals\n• 3 pedals = Manual\n• 2 pedals = Automatic\n\nOr check the gear stick:\n• Numbers (1,2,3,4,5) = Manual\n• Letters (P,R,N,D) = Automatic',
                    ),
                  ),
                ),
                items: TransmissionType.values.map((transmission) {
                  return DropdownMenuItem(
                    value: transmission,
                    child: Text(_getTransmissionLabel(transmission)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTransmission = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select transmission';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<FuelType>(
                decoration: InputDecoration(
                  labelText: 'Fuel Type *',
                  border: const OutlineInputBorder(),
                  hintText: 'Select fuel type',
                  helperText: 'What the car uses for fuel',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.help_outline, size: 20),
                    onPressed: () => _showHelpDialog(
                      'Fuel Type',
                      'What your car runs on:\n\n⛽ Petrol (Gasoline):\n• Most common in Zambia\n• Usually cheaper than diesel\n• Green pump at gas station\n\n🚛 Diesel:\n• Common in trucks and SUVs\n• Better fuel economy\n• Black pump at gas station\n\n🔋 Electric:\n• Runs on battery only\n• No fuel needed\n• Very rare in Zambia\n\n🔋⛽ Hybrid:\n• Uses both petrol and electric\n• Better fuel economy\n• Examples: Prius, Aqua\n\nHow to check:\n• Look at fuel cap label\n• Check registration papers\n• Ask at gas station which pump you use',
                    ),
                  ),
                ),
                items: FuelType.values.map((fuel) {
                  return DropdownMenuItem(
                    value: fuel,
                    child: Text(_getFuelTypeLabel(fuel)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFuelType = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select fuel type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location *',
                  border: const OutlineInputBorder(),
                  hintText: 'e.g., Lusaka, Kitwe, Ndola',
                  helperText: 'Where the car is located',
                  prefixIcon: const Icon(Icons.location_on),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.help_outline, size: 20),
                    onPressed: () => _showHelpDialog(
                      'Location',
                      'Where is the car located?\n\nJust enter the city or town:\n• Lusaka\n• Kitwe\n• Ndola\n• Livingstone\n• Kabwe\n• Chingola\n• Mufulira\n• Solwezi\n\nBuyers will contact you for the exact address.',
                    ),
                  ),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description *',
                  border: const OutlineInputBorder(),
                  hintText: 'Tell buyers about your car...',
                  helperText: 'Describe condition, features, history (min 20 characters)',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.help_outline, size: 20),
                    onPressed: () => _showHelpDialog(
                      'Writing a Good Description',
                      'Help buyers understand your car better!\n\nWhat to include:\n\n✅ Condition:\n• "Well maintained"\n• "Recently serviced"\n• "Clean interior"\n• "No accidents"\n\n✅ Features:\n• "Air conditioning works"\n• "Power windows"\n• "Good tires"\n• "Sound system"\n\n✅ History:\n• "Single owner"\n• "Full service history"\n• "Recently painted"\n\n✅ Reason for selling:\n• "Upgrading to new car"\n• "Relocating"\n\n❌ Avoid:\n• Lying about condition\n• Hiding problems\n• Too short descriptions\n\nExample:\n"Well maintained Toyota Corolla. Single owner, full service history. Air conditioning works perfectly. Good tires. Selling because I\'m upgrading to a newer model."',
                    ),
                  ),
                ),
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  if (value.length < 20) {
                    return 'Description must be at least 20 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: state.status == ListingStateStatus.loading
                    ? null
                    : _submitListing,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: state.status == ListingStateStatus.loading
                    ? const CircularProgressIndicator()
                    : const Text('Submit Listing'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Images (3-20 required)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${_imagePaths.length}/20',
              style: TextStyle(
                color: _imagePaths.length >= 3 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ..._imagePaths.asMap().entries.map((entry) {
                return _buildImageThumbnail(entry.key, entry.value);
              }),
              _buildAddImageButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageThumbnail(int index, String path) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(path),
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
                padding: EdgeInsets.zero,
              ),
              onPressed: () => _removeImage(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddImageButton() {
    return InkWell(
      onTap: _pickImages,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 32),
            SizedBox(height: 4),
            Text('Add Images'),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.help, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  String _getBodyTypeLabel(BodyType type) {
    switch (type) {
      case BodyType.sedan:
        return 'Sedan';
      case BodyType.coupe:
        return 'Coupe';
      case BodyType.suv:
        return 'SUV';
      case BodyType.hatchback:
        return 'Hatchback';
      case BodyType.convertible:
        return 'Convertible';
      case BodyType.pickup:
        return 'Pickup';
      case BodyType.van:
        return 'Van';
      case BodyType.wagon:
        return 'Wagon';
      case BodyType.other:
        return 'Other';
    }
  }

  String _getConditionLabel(VehicleCondition condition) {
    switch (condition) {
      case VehicleCondition.brandNew:
        return 'Brand New';
      case VehicleCondition.used:
        return 'Used';
      case VehicleCondition.certifiedPreOwned:
        return 'Certified Pre-Owned';
    }
  }

  String _getTransmissionLabel(TransmissionType transmission) {
    switch (transmission) {
      case TransmissionType.automatic:
        return 'Automatic';
      case TransmissionType.manual:
        return 'Manual';
      case TransmissionType.cvt:
        return 'CVT';
      case TransmissionType.dct:
        return 'DCT';
    }
  }

  String _getFuelTypeLabel(FuelType fuel) {
    switch (fuel) {
      case FuelType.petrol:
        return 'Petrol';
      case FuelType.diesel:
        return 'Diesel';
      case FuelType.electric:
        return 'Electric';
      case FuelType.hybrid:
        return 'Hybrid';
      case FuelType.pluginHybrid:
        return 'Plug-in Hybrid';
      case FuelType.lpg:
        return 'LPG';
    }
  }
}
