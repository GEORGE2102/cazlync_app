import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../data/services/admin_service.dart';
import 'admin_controller.dart';
import 'admin_state.dart';

// Admin Service Provider
final adminServiceProvider = Provider<AdminService>((ref) {
  return AdminService();
});

// Admin Repository Provider
final adminRepositoryProvider = Provider((ref) {
  final adminService = ref.watch(adminServiceProvider);
  return AdminRepositoryImpl(adminService: adminService);
});

// Admin Controller Provider
final adminControllerProvider =
    StateNotifierProvider<AdminController, AdminState>((ref) {
  final adminRepository = ref.watch(adminRepositoryProvider);
  return AdminController(adminRepository: adminRepository);
});
