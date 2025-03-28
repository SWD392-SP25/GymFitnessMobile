import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart'; // Add this import
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gym_fitness_mobile/features/account/presentation/pages/subscription_plan_page.dart';

import '../../../../core/auth/auth_provider.dart';

// Change idTokenProvider to fcmTokenProvider
final fcmTokenProvider = FutureProvider<String?>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user != null) {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    return fcmToken;
  }
  return null;
});

// Thêm provider cho idToken
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
    final fcmToken =
        ref.watch(fcmTokenProvider); // Change from idToken to fcmToken
    final idToken = ref.watch(idTokenProvider);
    final isLoggedIn = user != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Account",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Ẩn nút back
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Avatar
          CircleAvatar(
            backgroundImage: isLoggedIn && user.photoURL != null
                ? NetworkImage(user.photoURL!)
                : null,
            radius: 50,
            backgroundColor: Colors.grey[300],
            child: isLoggedIn && user.photoURL == null
                ? const Icon(Icons.person, size: 50, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 12),
          // Tên người dùng hoặc "Guest"
          Text(
            isLoggedIn ? user.displayName ?? "No Name" : "Guest",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          fcmToken.when(
            data: (token) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  initialValue: token ?? 'Không có FCM Token',
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Firebase Token",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: token ?? 'Không có FCM Token'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Đã sao chép Firebase Token")),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => const Text(
              "Lỗi lấy Firebase Token",
              style: TextStyle(color: Colors.red),
            ),
          ),
          const SizedBox(height: 10),
          idToken.when(
            data: (token) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  initialValue: token ?? 'Không có ID Token',
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "ID Token",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: token ?? 'Không có ID Token'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Đã sao chép ID Token")),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => const Text(
              "Lỗi lấy ID Token",
              style: TextStyle(color: Colors.red),
            ),
          ),
          const SizedBox(height: 20),
          // Danh sách tính năng
          Expanded(
            child: ListView(
              children: [
                if (isLoggedIn) ...[
                  _buildListTile(Icons.book, "My Courses", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SubscriptionPlanPage()),
                    );
                  }),
                  _buildListTile(Icons.edit, "Edit Account", () {}),
                  _buildListTile(Icons.settings, "Settings and Privacy", () {}),
                  const Divider(thickness: 1),
                  _buildListTile(Icons.logout, "Sign Out", () {
                    ref.read(authControllerProvider.notifier).signOut();
                  }, color: Colors.redAccent),
                ] else ...[
                  _buildListTile(Icons.login, "Sign In with Google", () {
                    ref
                        .read(authControllerProvider.notifier)
                        .signInWithGoogle();
                  }, color: Colors.blue),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget tạo ListTile có tùy chọn màu
  Widget _buildListTile(IconData icon, String title, VoidCallback onTap,
      {Color color = Colors.black54}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(fontSize: 16, color: color)),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
      onTap: onTap,
    );
  }
}
