import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageUploadService {
  final FirebaseStorage _storage;

  ImageUploadService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  Future<List<String>> uploadListingImages(
    String listingId,
    List<String> imagePaths,
  ) async {
    print('🔥 Starting upload for ${imagePaths.length} images');
    
    if (imagePaths.length < 3 || imagePaths.length > 20) {
      throw Exception('Must upload between 3 and 20 images');
    }

    final List<String> downloadUrls = [];

    for (int i = 0; i < imagePaths.length; i++) {
      try {
        print('🔥 Processing image $i: ${imagePaths[i]}');
        final compressedPath = await _compressImage(imagePaths[i]);
        print('🔥 Compressed path: $compressedPath');
        
        final extension = imagePaths[i].split('.').last;
        final url = await _uploadImage(
          compressedPath,
          'listings/$listingId/image_$i.$extension',
        );
        print('🔥 Uploaded successfully: $url');
        downloadUrls.add(url);
        
        // Clean up compressed file if different from original
        if (compressedPath != imagePaths[i]) {
          try {
            await File(compressedPath).delete();
          } catch (e) {
            // Ignore cleanup errors
          }
        }
      } catch (e) {
        print('❌ Upload failed for image $i: $e');
        // If one image fails, clean up uploaded images and rethrow
        for (final url in downloadUrls) {
          try {
            final ref = _storage.refFromURL(url);
            await ref.delete();
          } catch (_) {}
        }
        rethrow;
      }
    }

    print('✅ All images uploaded successfully');
    return downloadUrls;
  }

  Future<String> uploadProfilePhoto(String userId, String imagePath) async {
    final compressedPath = await _compressImage(imagePath);
    final extension = imagePath.split('.').last;
    final url = await _uploadImage(
      compressedPath,
      'profiles/$userId/photo.$extension',
    );
    
    // Clean up compressed file if different from original
    if (compressedPath != imagePath) {
      await File(compressedPath).delete();
    }
    
    return url;
  }

  Future<String> _compressImage(String imagePath) async {
    try {
      final file = File(imagePath);
      
      // Check if file exists
      if (!await file.exists()) {
        throw Exception('Image file not found: $imagePath');
      }
      
      final fileSize = await file.length();

      // If already under 500KB, return original
      if (fileSize < 500 * 1024) {
        return imagePath;
      }

      final lastSlash = imagePath.lastIndexOf('/');
      final lastDot = imagePath.lastIndexOf('.');
      final dir = imagePath.substring(0, lastSlash);
      final filename = imagePath.substring(lastSlash + 1, lastDot);
      final ext = imagePath.substring(lastDot);
      final targetPath = '$dir/${filename}_compressed$ext';

      final result = await FlutterImageCompress.compressAndGetFile(
        imagePath,
        targetPath,
        quality: 85,
        minWidth: 1920,
        minHeight: 1080,
      );

      if (result == null) {
        // If compression fails, return original
        return imagePath;
      }

      return result.path;
    } catch (e) {
      // If any error occurs, return original path
      return imagePath;
    }
  }

  Future<String> _uploadImage(String filePath, String storagePath) async {
    final file = File(filePath);
    
    // Verify file exists before upload
    if (!await file.exists()) {
      throw Exception('Cannot upload: File not found at $filePath');
    }
    
    final ref = _storage.ref().child(storagePath);
    
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> deleteListingImages(String listingId) async {
    try {
      final ref = _storage.ref().child('listings/$listingId');
      final listResult = await ref.listAll();
      
      for (final item in listResult.items) {
        await item.delete();
      }
    } catch (e) {
      // Ignore errors if folder doesn't exist
    }
  }

  Future<void> deleteProfilePhoto(String userId) async {
    try {
      final ref = _storage.ref().child('profiles/$userId');
      final listResult = await ref.listAll();
      
      for (final item in listResult.items) {
        await item.delete();
      }
    } catch (e) {
      // Ignore errors if folder doesn't exist
    }
  }
}
