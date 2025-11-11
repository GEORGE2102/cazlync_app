import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/errors/exceptions.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collection reference
  CollectionReference get _usersCollection => _firestore.collection('users');

  // Create user in Firestore
  Future<void> createUser(UserModel user) async {
    try {
      await _usersCollection
          .doc(user.id)
          .set(user.toFirestore())
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw ServerException(
                'Firestore timeout. Please check if Firestore is enabled in Firebase Console.',
              );
            },
          );
    } on FirebaseException catch (e) {
      throw ServerException('Failed to create user: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to create user: ${e.toString()}');
    }
  }

  // Get user from Firestore
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _usersCollection
          .doc(userId)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw ServerException(
                'Firestore timeout. Please check if Firestore is enabled in Firebase Console.',
              );
            },
          );
      
      if (!doc.exists) {
        return null;
      }

      return UserModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException('Failed to get user: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to get user: ${e.toString()}');
    }
  }

  // Update user in Firestore
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _usersCollection.doc(userId).update(data);
    } on FirebaseException catch (e) {
      throw ServerException('Failed to update user: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to update user: ${e.toString()}');
    }
  }

  // Delete user from Firestore
  Future<void> deleteUser(String userId) async {
    try {
      await _usersCollection.doc(userId).delete();
    } on FirebaseException catch (e) {
      throw ServerException('Failed to delete user: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to delete user: ${e.toString()}');
    }
  }

  // Check if user exists
  Future<bool> userExists(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      return doc.exists;
    } on FirebaseException catch (e) {
      throw ServerException('Failed to check user existence: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to check user existence: ${e.toString()}');
    }
  }
}
