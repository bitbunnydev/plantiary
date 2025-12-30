import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'process_screen.dart';
import 'plant_list_screen.dart';
import 'weather_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _greetingAnimation;

  int _currentIndex = 0;
  final List<IconData> _icons = [Icons.home, Icons.camera_alt, Icons.info];
  final List<String> _labels = ['Home', 'Scan', 'Info'];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _greetingAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProcessScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PlantListScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      extendBody: true,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 24),
              _animatedGreeting(),
              const SizedBox(height: 32),
              _animatedFeatureCard(),
              const SizedBox(height: 32),
              _sectionTitle('Heal your crop'),
              const SizedBox(height: 16),
              _animatedStepsCard(),
              const SizedBox(height: 32),
              _animatedUploadButton(context),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _modernFloatingNavBar(),
    );
  }

  // AppBar
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF8FAF9),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade600, Colors.green.shade400],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.eco,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Plantiary',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.green.shade800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PlantListScreen()),
              );
            },
            icon: Icon(
              Icons.info_outline,
              color: Colors.grey.shade700,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  // Greeting Animation
  Widget _animatedGreeting() {
    return FadeTransition(
      opacity: _greetingAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.2),
          end: Offset.zero,
        ).animate(_greetingAnimation),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    color: Colors.black87,
                    height: 1.2,
                    fontWeight: FontWeight.w300,
                  ),
                  children: [
                    const TextSpan(text: 'Your Digital Partner\n'),
                    TextSpan(
                      text: 'in Farming',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Diagnose and heal your crops with AI',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Animated Feature Card
  Widget _animatedFeatureCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.95, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutBack,
        builder: (context, double scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WeatherScreen()),
            );
          },
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade600,
                  Colors.green.shade400,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.shade300.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -40,
                  bottom: -40,
                  child: Opacity(
                    opacity: 0.15,
                    child: Icon(
                      Icons.cloud,
                      size: 180,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  left: 24,
                  top: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Live Updates',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.wb_sunny,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Weather Insights',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Get real-time weather updates',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Section Title
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Animated Steps Card
  Widget _animatedStepsCard() {
    final steps = [
      {'icon': Icons.camera_alt_rounded, 'label': 'Capture', 'color': Colors.blue},
      {'icon': Icons.psychology_rounded, 'label': 'Diagnose', 'color': Colors.orange},
      {'icon': Icons.tips_and_updates_rounded, 'label': 'Solutions', 'color': Colors.purple},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: steps.asMap().entries.map((entry) {
            int idx = entry.key;
            var step = entry.value;
            return TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: Duration(milliseconds: 500 + idx * 150),
              curve: Curves.easeOutBack,
              builder: (context, double value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
                );
              },
              child: _stepItem(
                step['icon'] as IconData,
                step['label'] as String,
                step['color'] as Color,
                idx,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Single Step Item
  Widget _stepItem(IconData icon, String label, Color color, int index) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // Animated Upload Button
  Widget _animatedUploadButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.95, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutBack,
        builder: (context, double scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.green.shade400.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProcessScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_upload_rounded, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Start Diagnosis',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Modern Floating NavBar with Sliding Indicator
  Widget _modernFloatingNavBar() {
    final width = MediaQuery.of(context).size.width;
    final itemWidth = (width - 48) / _icons.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            left: _currentIndex * itemWidth + itemWidth / 2 - 32,
            top: 10,
            child: Container(
              height: 52,
              width: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade500, Colors.green.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.shade300.withOpacity(0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: List.generate(_icons.length, (index) {
              final isActive = index == _currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _onNavTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _icons[index],
                          size: isActive ? 28 : 24,
                          color: isActive ? Colors.white : Colors.grey.shade500,
                        ),
                        if (isActive) ...[
                          const SizedBox(height: 4),
                          Text(
                            _labels[index],
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
