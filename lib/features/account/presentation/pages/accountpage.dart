import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/auth_provider.dart';

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
    final idToken = ref.watch(idTokenProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tài khoản của tôi"),
        centerTitle: true,
        automaticallyImplyLeading: false, // This will remove the back button
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlueAccent, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: user == null
              ? ElevatedButton(
                  onPressed: () {
                    ref.read(authControllerProvider.notifier).signInWithGoogle();
                  },
                  child: const Text("Đăng nhập với Google"),
                )
              : SingleChildScrollView(
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (user.photoURL != null)
                            CircleAvatar(
                              backgroundImage: NetworkImage(user.photoURL!),
                              radius: 50,
                            )
                          else
                            const CircleAvatar(
                              backgroundColor: Colors.grey,
                              radius: 50,
                              child: Icon(Icons.person, size: 50, color: Colors.white),
                            ),
                          const SizedBox(height: 20),
                          Text(
                            user.displayName ?? 'Không có tên',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            user.email ?? 'Không có email',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "SĐT: ${user.phoneNumber ?? 'Không có'}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Divider(height: 40, thickness: 1),
                          idToken.when(
                            data: (token) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "UID: ${user.uid}",
                                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                                  ),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    initialValue: token ?? 'Không có idToken',
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: "idToken",
                                      border: const OutlineInputBorder(),
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.copy),
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(text: token ?? 'Không có idToken'));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("Đã sao chép idToken")),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (err, stack) {
                              return const Text("Lỗi lấy idToken", style: TextStyle(color: Colors.red));
                            },
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Đăng nhập qua: ${user.providerData.map((e) => e.providerId).join(', ')}",
                            style: const TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () {
                              ref.read(authControllerProvider.notifier).signOut();
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            ),
                            child: const Text("Đăng xuất"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
