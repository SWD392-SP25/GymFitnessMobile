import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/auth_provider.dart';

// 🔹 FutureProvider để lấy idToken
final idTokenProvider = FutureProvider<String?>((ref) async {
  final user = ref.watch(authStateProvider).value;
  final idToken = await user?.getIdToken();
  return idToken;
});

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final idToken = ref.watch(idTokenProvider); // 🔹 Lắng nghe idToken

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: user == null
            ? ElevatedButton(
                onPressed: () {
                  ref.read(authControllerProvider.notifier).signInWithGoogle();
                },
                child: Text("Đăng nhập với Google"),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (user.photoURL != null)
                    CircleAvatar(
                      backgroundImage: NetworkImage(user.photoURL!),
                      radius: 40,
                    ),
                  SizedBox(height: 10),

                  Text("Tên: ${user.displayName ?? 'Không có'}"),
                  Text("Email: ${user.email ?? 'Không có'}"),
                  Text("Số điện thoại: ${user.phoneNumber ?? 'Không có'}"),
                  Text("UID: ${user.uid}"),

                  // 🔹 Lấy idToken bất đồng bộ
                  idToken.when(
                    data: (token) {
                      print(
                          "🔥 idToken: ${token ?? 'Không có'}"); // In ra console
                      return TextFormField(
                        initialValue: token ?? 'Không có idToken',
                        readOnly: true, // ✅ Chỉ cho phép copy, không sửa
                        decoration: InputDecoration(
                          labelText: "idToken",
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                  text: token ?? 'Không có idToken'));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Đã sao chép idToken")),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    loading: () => CircularProgressIndicator(),
                    error: (err, stack) {
                      print("❌ Lỗi lấy idToken: $err");
                      return Text("Lỗi lấy idToken");
                    },
                  ),

                  Text(
                      "Đăng nhập qua: ${user.providerData.map((e) => e.providerId).join(", ")}"),

                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      ref.read(authControllerProvider.notifier).signOut();
                    },
                    child: Text("Đăng xuất"),
                  ),
                ],
              ),
      ),
    );
  }
}
