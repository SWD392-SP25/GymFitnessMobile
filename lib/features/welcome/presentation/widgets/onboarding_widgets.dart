import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gym_fitness_mobile/features/welcome/presentation/widgets/app_shadow.dart';
import 'package:gym_fitness_mobile/features/welcome/presentation/widgets/text_widgets.dart';

Widget appOnboardingPage(
    PageController controller,
    {String imagePath = "", String title = "", String subTitle = "", int index=0}) {
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
      nextButton(index, controller)
    ],
  );
}

Widget nextButton(int index, PageController controller) {
  String text = index < 3 ? "Next" : "Get Started";
  return GestureDetector(
    onTap: () {
      if(index<3){
          controller.animateToPage(
              index,
              duration: Duration(milliseconds: 300),
              curve: Curves.decelerate
          );
      } else {
        // Navigator.of(context)
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
