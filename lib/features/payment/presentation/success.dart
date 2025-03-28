import 'package:flutter/material.dart';
import 'package:gym_fitness_mobile/core/navigation/routes.dart';
import 'package:lottie/lottie.dart';

class PaymentSuccessPage extends StatelessWidget {
  const PaymentSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success Animation
                Lottie.network(
                  'https://assets10.lottiefiles.com/packages/lf20_jbrw3hcz.json',
                  width: 200,
                  height: 200,
                  repeat: false,
                ),
                
                const SizedBox(height: 32),
                
                // Success Message
                const Text(
                  'Thanh toán thành công!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                const Text(
                  'Cảm ơn bạn đã đăng ký gói tập.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                
                const SizedBox(height: 48),
                
                
                
                // Return to Home Button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green, // Add background color
                      foregroundColor: Colors.white, // Add text color
                      shape: RoundedRectangleBorder( // Add rounded corners
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.mainScreen,
                      );
                    },
                    child: const Text(
                      'Về trang chủ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold, // Make text bold
                      ),
                    ),
                  ),
                ),
                
                // Removed the second button since we're combining the functionality
              ],
            ),
          ),
        ),
      ),
    );
  }
}