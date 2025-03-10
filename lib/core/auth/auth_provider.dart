import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/endpoints/auth.dart';
import '../network/dio_client.dart';
import 'auth_repository.dart';

// Provider cho DioClient
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

// Provider cho AuthApiService
final authApiServiceProvider = Provider<AuthApiService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthApiService(dioClient);
});

// Provider cho AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Provider để theo dõi trạng thái người dùng Firebase
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Provider để lưu thông tin xác thực từ API của bạn
final authTokenProvider = StateProvider<AuthResponse?>((ref) => null);

// Provider để quản lý hành động đăng nhập/đăng xuất
final authControllerProvider = StateNotifierProvider<AuthController, User?>((ref) {
  return AuthController(
    ref.watch(authRepositoryProvider),
    ref.watch(authApiServiceProvider),
    ref,
  );
});

// Controller để xử lý logic đăng nhập/đăng xuất
class AuthController extends StateNotifier<User?> {
  final AuthRepository _authRepository;
  final AuthApiService _authApiService;
  final Ref _ref;

  AuthController(this._authRepository, this._authApiService, this._ref)
      : super(_authRepository.getCurrentUser());

  // Lưu thông tin đăng nhập vào SharedPreferences
  Future<void> _saveAuthData(AuthResponse authData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', authData.token);
    await prefs.setString('refreshToken', authData.refreshToken);
    await prefs.setString('userId', authData.id);
    await prefs.setString('userEmail', authData.email);
    await prefs.setString('userRole', authData.role);
    
    // Cập nhật state provider
    _ref.read(authTokenProvider.notifier).state = authData;
  }

  // Xóa thông tin đăng nhập từ SharedPreferences
  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('refreshToken');
    await prefs.remove('userId');
    await prefs.remove('userEmail');
    await prefs.remove('userRole');
    
    // Cập nhật state provider
    _ref.read(authTokenProvider.notifier).state = null;
  }

  // Đăng nhập với Google và gọi API của bạn
  Future<AuthResponse?> signInWithGoogle() async {
  try {
    print("📱 Bắt đầu đăng nhập Google");
    // 1. Đăng nhập với Firebase Google Auth
    final user = await _authRepository.signInWithGoogle();
    state = user;
    
    if (user != null) {
      print("📱 Firebase login thành công: ${user.email}");
      
      // 2. Lấy access token từ Firebase
      final firebaseToken = await user.getIdToken();
      print("📱 Firebase token: ${firebaseToken?.substring(0, 20)}...");
      
      // 3. Gọi API login với token Firebase
      print("📱 Gọi API login backend");
      final authResponse = await _authApiService.login(firebaseToken!);
      print("📱 API login thành công: ${authResponse.email}");
      
      // 4. Lưu thông tin đăng nhập
      await _saveAuthData(authResponse);
      print("📱 Đã lưu token");
      
      return authResponse;
    }
  } catch (e) {
    print("❌ Lỗi đăng nhập chi tiết: $e");
  }
  return null;
}

  // Làm mới token
Future<RefreshTokenResponse?> refreshToken() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('token');
    final refreshToken = prefs.getString('refreshToken');
    final userId = prefs.getString('userId');
    
    if (accessToken != null && refreshToken != null && userId != null) {
      final response = await _authApiService.refresh(
        accessToken: accessToken,
        refreshToken: refreshToken,
        userId: userId,
      );
      
      // Cập nhật token mới vào SharedPreferences
      await prefs.setString('token', response.token);
      await prefs.setString('refreshToken', response.refreshToken);
      
      return response;
    }
  } catch (e) {
    print('Lỗi refresh token: $e');
    await signOut(); // Đăng xuất nếu có lỗi
  }
  return null;
}

  // Đăng xuất
  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('token');
      
      if (accessToken != null) {
        // Gọi API logout
        await _authApiService.logout(accessToken);
      }
      
      // Xóa dữ liệu đăng nhập
      await _clearAuthData();
      
      // Đăng xuất khỏi Firebase
      await _authRepository.signOut();
      state = null;
    } catch (e) {
      print('Lỗi đăng xuất: $e');
      // Vẫn xóa dữ liệu local ngay cả khi API fail
      await _clearAuthData();
      await _authRepository.signOut();
      state = null;
    }
  }

  // Lấy token hiện tại
  Future<String?> getCurrentToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}