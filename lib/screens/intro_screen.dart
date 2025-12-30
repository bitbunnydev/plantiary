import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'home_screen.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  void _onIntroEnd(BuildContext context) {
    Hive.box('settings').put('seenIntro', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Welcome to Plantiary",
          body: "Your AI-powered companion for healthier crops and smarter farming.",
          image: Center(
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Image.asset('assets/onboard1.png', height: 160),
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
          body: "Scan your plant leaves and get instant disease detection powered by AI technology.",
          image: Center(
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Image.asset('assets/onboard2.png', height: 160),
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
          body: "Keep a digital diary of your plants and track their health progress over time.",
          image: Center(
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.purple.shade400, Colors.purple.shade600],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Image.asset('assets/onboard3.png', height: 160),
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
          "Get Started",
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
