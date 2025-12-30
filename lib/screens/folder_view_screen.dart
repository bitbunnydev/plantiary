import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/diary_service.dart';

class FolderViewScreen extends StatefulWidget {
  final String folderName;

  const FolderViewScreen({super.key, required this.folderName});

  @override
  State<FolderViewScreen> createState() => _FolderViewScreenState();
}

class _FolderViewScreenState extends State<FolderViewScreen> {
  List<ImageData> allImages = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  void _loadImages() {
    final entries = DiaryService.getEntriesByFolder(widget.folderName);
    
    final List<ImageData> images = [];
    for (var entry in entries) {
      for (var imagePath in entry.imagePaths) {
        images.add(ImageData(
          imagePath: imagePath,
          date: entry.date,
          disease: entry.disease,
          confidence: entry.confidence,
          notes: entry.notes,
          entryName: entry.name,
          entryId: entry.id,
        ));
      }
    }
    
    images.sort((a, b) => a.date.compareTo(b.date));
    
    setState(() {
      allImages = images;
    });
  }

  Future<void> _deleteEntry(String entryId) async {
    await DiaryService.deleteEntry(entryId);
    _loadImages();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Entry deleted', style: GoogleFonts.poppins()),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.folderName,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.green.shade800,
              ),
            ),
            Text(
              '${allImages.length} ${allImages.length == 1 ? 'image' : 'images'}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
      body: allImages.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: allImages.length,
              itemBuilder: (context, index) {
                return _buildImageCard(allImages[index], index);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 100, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No images in this folder',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start scanning plants to track progress',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(ImageData imageData, int index) {
    final isHealthy = imageData.disease.toLowerCase().contains('healthy');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.green.shade50.withOpacity(0.3)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                child: imageData.imagePath.isNotEmpty
                    ? Image.file(
                        File(imageData.imagePath),
                        width: double.infinity,
                        height: 320,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: double.infinity,
                        height: 320,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green.shade100, Colors.green.shade200],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 100,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
              ),
              Container(
                height: 320,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 18,
                left: 18,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade600, Colors.blue.shade400],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timeline_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Scan #${index + 1}',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 18,
                right: 18,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isHealthy
                          ? [Colors.green.shade600, Colors.green.shade400]
                          : [Colors.orange.shade600, Colors.orange.shade400],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    '${imageData.confidence.toStringAsFixed(0)}%',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                        Icons.calendar_today_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('dd MMM yyyy • hh:mm a').format(imageData.date),
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isHealthy
                          ? [Colors.green.shade50, Colors.green.shade100]
                          : [Colors.orange.shade50, Colors.orange.shade100],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isHealthy ? Colors.green.shade300 : Colors.orange.shade300,
                      width: 2,
                    ),
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
                                colors: isHealthy
                                    ? [Colors.green.shade700, Colors.green.shade500]
                                    : [Colors.orange.shade700, Colors.orange.shade500],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              isHealthy ? Icons.check_circle_rounded : Icons.warning_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Diagnosis',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  imageData.disease,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: isHealthy ? Colors.green.shade900 : Colors.orange.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (imageData.notes.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.note_alt_rounded, size: 18, color: Colors.grey.shade700),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Notes',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                imageData.notes,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey.shade800,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.label_rounded, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Text(
                            imageData.entryName,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red.shade500, Colors.red.shade400],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextButton.icon(
                        icon: const Icon(Icons.delete_rounded, size: 20, color: Colors.white),
                        label: Text(
                          'Delete',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              title: Text('Delete Entry', style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 20)),
                              content: Text('Delete this entry and all its images?', style: GoogleFonts.poppins(fontSize: 15)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade600,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  ),
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text('Delete', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            _deleteEntry(imageData.entryId);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ImageData {
  final String imagePath;
  final DateTime date;
  final String disease;
  final double confidence;
  final String notes;
  final String entryName;
  final String entryId;

  ImageData({
    required this.imagePath,
    required this.date,
    required this.disease,
    required this.confidence,
    required this.notes,
    required this.entryName,
    required this.entryId,
  });
}
