import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'main_navigation_screen.dart';

class IntroScreen extends StatelessWidget {
  final bool isFirstTime;
  
  const IntroScreen({super.key, this.isFirstTime = true});

  void _onIntroEnd(BuildContext context) {
    if (isFirstTime) {
      Hive.box('settings').put('seenIntro', true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Welcome to Plantiary",
          body:
              "Your AI-powered companion for healthier crops and smarter farming.",
          image: Center(
            child: Lottie.asset(
              'assets/lottie/Welcome.json',
              width: 300,
              height: 300,
              fit: BoxFit.contain,
            ),
          ),
          decoration: PageDecoration(
            pageColor: Colors.white,
            titleTextStyle: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.green.shade800,
            ),
            bodyTextStyle: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
            imagePadding: const EdgeInsets.only(top: 80, bottom: 40),
          ),
        ),
        PageViewModel(
          title: "Smart Diagnosis",
          body:
              "Scan your plant leaves and get instant disease detection powered by AI technology.",
          image: Center(
            child: Lottie.asset(
              'assets/lottie/disgnose.json',
              width: 300,
              height: 300,
              fit: BoxFit.contain,
            ),
          ),
          decoration: PageDecoration(
            pageColor: Colors.white,
            titleTextStyle: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.blue.shade800,
            ),
            bodyTextStyle: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
            imagePadding: const EdgeInsets.only(top: 80, bottom: 40),
          ),
        ),
        PageViewModel(
          title: "Track & Monitor",
          body:
              "Keep a digital diary of your plants and track their health progress over time.",
          image: Center(
            child: Lottie.asset(
              'assets/lottie/monitoring.json',
              width: 300,
              height: 300,
              fit: BoxFit.contain,
            ),
          ),
          decoration: PageDecoration(
            pageColor: Colors.white,
            titleTextStyle: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.purple.shade800,
            ),
            bodyTextStyle: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
            imagePadding: const EdgeInsets.only(top: 80, bottom: 40),
          ),
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context),
      showSkipButton: true,
      skip: Text(
        "Skip",
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.grey.shade600,
        ),
      ),
      next: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade500, Colors.green.shade700],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.arrow_forward, color: Colors.white),
      ),
      done: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade500, Colors.green.shade700],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          "Lets Go!",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
      dotsDecorator: DotsDecorator(
        size: const Size(10, 10),
        color: Colors.grey.shade300,
        activeSize: const Size(24, 10),
        activeColor: Colors.green.shade600,
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}
