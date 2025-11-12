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
      price: double.parse(_priceController.text),
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
              _buildImageSection(),
              const SizedBox(height: 24),
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: 'Brand',
                  border: OutlineInputBorder(),
                ),
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
                decoration: const InputDecoration(
                  labelText: 'Model',
                  border: OutlineInputBorder(),
                ),
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
                decoration: const InputDecoration(
                  labelText: 'Year',
                  border: OutlineInputBorder(),
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
                decoration: const InputDecoration(
                  labelText: 'Price (XAF)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _mileageController,
                decoration: const InputDecoration(
                  labelText: 'Mileage (km)',
                  border: OutlineInputBorder(),
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
                decoration: const InputDecoration(
                  labelText: 'Body Type',
                  border: OutlineInputBorder(),
                  hintText: 'Select body type',
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
                decoration: const InputDecoration(
                  labelText: 'Condition',
                  border: OutlineInputBorder(),
                  hintText: 'Select condition',
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
                decoration: const InputDecoration(
                  labelText: 'Transmission',
                  border: OutlineInputBorder(),
                  hintText: 'Select transmission',
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
                decoration: const InputDecoration(
                  labelText: 'Fuel Type',
                  border: OutlineInputBorder(),
                  hintText: 'Select fuel type',
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
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Lusaka, Kitwe, Ndola',
                ),
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
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  hintText: 'Describe the vehicle condition, features, etc.',
                ),
                maxLines: 5,
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
