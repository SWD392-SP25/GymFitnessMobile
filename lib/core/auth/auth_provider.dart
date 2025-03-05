import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_repository.dart';

// Provider cho AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Provider để theo dõi trạng thái người dùng
final authStateProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return FirebaseAuth.instance.authStateChanges();
});

// Provider để quản lý hành động đăng nhập/đăng xuất
final authControllerProvider =
StateNotifierProvider<AuthController, User?>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

// Controller để xử lý logic đăng nhập/đăng xuất
class AuthController extends StateNotifier<User?> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository) : super(_authRepository.getCurrentUser());

  Future<void> signInWithGoogle() async {
    final user = await _authRepository.signInWithGoogle();
    state = user;
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    state = null;
  }
}
