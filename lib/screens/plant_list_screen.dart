import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/plant_data.dart';
import '../models/plant.dart';
import '../models/disease.dart';

class PlantListScreen extends StatefulWidget {
  final String? targetPlant;
  
  const PlantListScreen({super.key, this.targetPlant});

  @override
  State<PlantListScreen> createState() => _PlantListScreenState();
}

class _PlantListScreenState extends State<PlantListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.targetPlant != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToTargetPlant();
      });
    }
  }

  void _scrollToTargetPlant() {
    if (widget.targetPlant == null) return;

    final targetIndex = plantList.indexWhere(
      (plant) => plant.name.toLowerCase().contains(widget.targetPlant!.toLowerCase()),
    );

    if (targetIndex != -1) {
      final double offset = targetIndex * 290.0;
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text(
          'Plant Encyclopedia',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Colors.green.shade800,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        itemCount: plantList.length,
        itemBuilder: (context, index) {
          Plant plant = plantList[index];
          final isTarget = widget.targetPlant != null &&
              plant.name.toLowerCase().contains(widget.targetPlant!.toLowerCase());

          return TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: Duration(milliseconds: 300 + (index * 50)),
            builder: (context, double value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 30 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isTarget
                      ? [Colors.purple.shade50, Colors.purple.shade100]
                      : [Colors.white, Colors.green.shade50],
                ),
                borderRadius: BorderRadius.circular(28),
                border: isTarget
                    ? Border.all(color: Colors.purple.shade600, width: 3)
                    : Border.all(color: Colors.green.shade100, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: isTarget
                        ? Colors.purple.withOpacity(0.3)
                        : Colors.green.withOpacity(0.15),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Hero(
                          tag: 'plant_${plant.name}',
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(plant.image, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plant.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: isTarget ? Colors.purple.shade900 : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isTarget
                                        ? [Colors.purple.shade600, Colors.purple.shade400]
                                        : [Colors.green.shade600, Colors.green.shade400],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isTarget ? Colors.purple : Colors.green).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.coronavirus_outlined, color: Colors.white, size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${plant.diseases.length} disease${plant.diseases.length != 1 ? 's' : ''}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        plant.info,
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade800,
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.green.shade600, Colors.green.shade400],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.coronavirus_outlined, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Common Diseases',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: plant.diseases.length,
                        itemBuilder: (context, dIndex) {
                          Disease disease = plant.diseases[dIndex];

                          return Container(
                            width: 260,
                            margin: const EdgeInsets.only(right: 14),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: disease.isHealthy
                                    ? [Colors.green.shade50, Colors.green.shade100]
                                    : [Colors.red.shade50, Colors.red.shade100],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: disease.isHealthy
                                    ? Colors.green.shade400
                                    : Colors.red.shade400,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (disease.isHealthy ? Colors.green : Colors.red).withOpacity(0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: disease.isHealthy
                                              ? [Colors.green.shade700, Colors.green.shade500]
                                              : [Colors.red.shade700, Colors.red.shade500],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        disease.isHealthy
                                            ? Icons.check_circle_rounded
                                            : Icons.warning_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        disease.name,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                          color: disease.isHealthy
                                              ? Colors.green.shade900
                                              : Colors.red.shade900,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Expanded(
                                  child: Text(
                                    disease.info,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: disease.isHealthy
                                          ? Colors.green.shade800
                                          : Colors.red.shade800,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
