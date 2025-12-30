import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/diary_entry.dart';

class DiaryViewScreen extends StatelessWidget {
  final DiaryEntry entry;

  const DiaryViewScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text(
          'Diary Entry',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: Colors.green.shade700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.name,
              style: GoogleFonts.montserrat(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  entry.dateFormatted,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Hero(
              tag: 'diary_${entry.id}',
              child: Container(
                width: double.infinity,
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.file(
                    File(entry.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: entry.disease.toLowerCase().contains('healthy')
                      ? [Colors.green.shade50, Colors.green.shade100]
                      : [Colors.orange.shade50, Colors.orange.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        entry.disease.toLowerCase().contains('healthy')
                            ? Icons.check_circle
                            : Icons.warning_amber_rounded,
                        color: entry.disease.toLowerCase().contains('healthy')
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Diagnosis',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: entry.disease.toLowerCase().contains('healthy')
                              ? Colors.green.shade900
                              : Colors.orange.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The plant shows signs of ${entry.disease}.',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: entry.disease.toLowerCase().contains('healthy')
                          ? Colors.green.shade800
                          : Colors.orange.shade800,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: entry.disease.toLowerCase().contains('healthy')
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Confidence: ${entry.confidence.toStringAsFixed(2)}%',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notes_outlined, color: Colors.green.shade700, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Diary Notes',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    entry.notes.isEmpty
                        ? 'No notes were added.'
                        : entry.notes,
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.folder_outlined, color: Colors.grey.shade700, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Folder: ${entry.folder.isEmpty ? "None" : entry.folder}',
                    style: GoogleFonts.montserrat(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  childrenPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
                  leading: Icon(Icons.analytics_outlined, color: Colors.green.shade700),
                  title: Text(
                    'Detailed Analysis',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  children: entry.allConfidences.entries
                      .map(
                        (e) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      e.key,
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${e.value.toStringAsFixed(1)}%',
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: e.value / 100,
                                  minHeight: 8,
                                  color: Colors.green.shade600,
                                  backgroundColor: Colors.green.shade100,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
