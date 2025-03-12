import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/auth_provider.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final isLoggedIn = user != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Account", style: TextStyle(fontWeight: FontWeight.bold)),
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
          const SizedBox(height: 20),
          // Danh sách tính năng
          Expanded(
            child: ListView(
              children: [
                if (isLoggedIn) ...[
                  _buildListTile(Icons.book, "My Courses", () {}),
                  _buildListTile(Icons.edit, "Edit Account", () {}),
                  _buildListTile(Icons.settings, "Settings and Privacy", () {}),
                  const Divider(thickness: 1),
                  _buildListTile(Icons.logout, "Sign Out", () {
                    ref.read(authControllerProvider.notifier).signOut();
                  }, color: Colors.redAccent),
                ] else ...[
                  _buildListTile(Icons.login, "Sign In with Google", () {
                    ref.read(authControllerProvider.notifier).signInWithGoogle();
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
  Widget _buildListTile(IconData icon, String title, VoidCallback onTap, {Color color = Colors.black54}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(fontSize: 16, color: color)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
      onTap: onTap,
    );
  }
}
