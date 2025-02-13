import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_fitness_mobile/features/welcome/presentation/providers/welcome_notifier.dart';
import 'package:gym_fitness_mobile/features/welcome/presentation/widgets/onboarding_widgets.dart';
import 'package:gym_fitness_mobile/features/welcome/presentation/widgets/text_widgets.dart';


class Welcome extends ConsumerWidget {
  Welcome({Key? key}) : super(key: key);

  final PageController _controller = PageController();
  double dotsIndex=0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final index = ref.watch(indexDotProvider);

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Container(
            margin: EdgeInsets.only(top: 30),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                //Showing our three welcome pages
                PageView(
                  onPageChanged: (value){
                    ref.read(indexDotProvider.notifier).changeIndex(value);
                  },
                  controller: _controller,
                  scrollDirection: Axis.horizontal,
                  children: [
                    //first page
                    appOnboardingPage(_controller,
                        context: context,
                        imagePath: "assets/images/welcome/welcome.png",
                        title: "Welcome to GYMBOT",
                        subTitle:
                            "Great place to help you improve your health ",
                        index: 1),
                    //second page
                    appOnboardingPage(_controller,
                        context: context,
                        imagePath: "assets/images/welcome/welcome.png",
                        title: "Quick and easy for newbie",
                        subTitle:
                            "AI assistant is always ready to answer all your questions",
                        index: 2),
                    //third page
                    appOnboardingPage(_controller,
                        context: context,
                        imagePath: "assets/images/welcome/welcome.png",
                        title: "Choose your own training plan",
                        subTitle:
                            "Training according to plan, making practice more motivated",
                        index: 3),
                  ],
                ),
                //For showing dots
                Positioned(
                  child: DotsIndicator(
                    position: index.toDouble(),
                    dotsCount: 3,
                    mainAxisAlignment: MainAxisAlignment.center,
                    decorator: DotsDecorator(
                        size: const Size.square(9.0),
                        activeSize: const Size(18.0, 8.0),
                        activeShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                  ),
                  bottom: 50,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
