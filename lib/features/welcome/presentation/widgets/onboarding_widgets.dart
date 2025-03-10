import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_fitness_mobile/core/auth/auth_provider.dart';
import 'package:gym_fitness_mobile/features/sign_in/presentation/pages/sign_in.dart';
import 'package:gym_fitness_mobile/features/welcome/presentation/widgets/app_shadow.dart';
import 'package:gym_fitness_mobile/features/welcome/presentation/widgets/text_widgets.dart';

import '../../../../core/navigation/routes.dart';
import '../../../account/presentation/pages/accountpage.dart';

Widget appOnboardingPage(
    PageController controller,
    {required BuildContext context, String imagePath = "", String title = "", String subTitle = "", int index=0}) {
  return Column(
    children: [
      Image.asset(imagePath),
      Container(
          margin: EdgeInsets.only(top: 15),
          padding: EdgeInsets.only(left: 80, right: 80),
          child: text24Normal(text: title)),
      Container(
        margin: EdgeInsets.only(top: 15),
        padding: EdgeInsets.only(left: 30, right: 30),
        child: text16Normal(text: subTitle),
      ),
      nextButton(index, controller, context)
    ],
  );
}


  Widget nextButton(int index, PageController controller, BuildContext context) {
  String text = index < 3 ? "Next" : "Get Started";
  
  return Consumer(
    builder: (context, ref, child) {
      return GestureDetector(
        onTap: () {
          if (index < 3) {
            // Navigate to the next page (current index + 1)
            controller.animateToPage(
                index + 1, 
                duration: Duration(milliseconds: 300),
                curve: Curves.decelerate
            );
          } else {
            // Call signInWithGoogle when index is 3
            ref.read(authControllerProvider.notifier).signInWithGoogle().then((_) {
              // Navigate to AccountPage after successful sign in
              Navigator.pushReplacementNamed(context, AppRoutes.mainScreen);
            });
          }
        },
        child: Container(
          width: 325,
          height: 50,
          margin: const EdgeInsets.only(top: 100, left: 25, right: 25),
          decoration: appBoxShadow(),
          child: Center(child: text16Normal(text: text, color: Colors.white)),
        ),
      );
    }
  );
}