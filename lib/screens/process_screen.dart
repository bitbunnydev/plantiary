import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../data/disease_data.dart';

import '../models/diary_entry.dart';
import '../services/diary_service.dart';
import 'diary_screen.dart';
import 'plant_list_screen.dart';

class ProcessScreen extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  const ProcessScreen({super.key, this.onToggleTheme});

  @override
  State<ProcessScreen> createState() => _ProcessScreenState();
}

class _ProcessScreenState extends State<ProcessScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  String _message = "Loading model, please wait...";
  bool _isLoading = false;
  bool _modelLoaded = false;

  late Interpreter _interpreter;
  final int inputSize = 224;
  final List<String> labels = [];
  Map<String, double> _latestPredictions = {};

  // Selected disease info for the top prediction
  DiseaseInfo? _selectedDiseaseInfo;
  double? _selectedDiseaseConfidence;
  String? _scanResult;

  @override
  void initState() {
    super.initState();
    _initModel();
  }

  // ------------------- EXTRACT PLANT NAME -------------------
  String _extractPlantName(String scanResult) {
    final words = scanResult.split(' ');
    if (words.isEmpty) return scanResult;
    return words.first;
  }

  // ------------------- CLEAN LABEL FUNCTION -------------------
  String cleanLabel(String raw) {
    String s = raw.trim();

    // Fix underscores
    s = s.replaceAll(RegExp(r'_+'), ' ');

    // Fix multiple spaces
    s = s.replaceAll(RegExp(r'\s+'), ' ');

    // Correct common typos and plant disease formatting
    final corrections = {
      'cercopora': 'Cercospora',
      'gray leaf spot': 'Gray Leaf Spot',
      'leaf _scald': 'Leaf Scald',
      'leaf scald': 'Leaf Scald',
      'cald': 'Scald',
      'rust': 'Rust',
      'blight': 'Blight',
      'bacterial spot': 'Bacterial Spot',
      'healthy': 'Healthy',
      'disease': 'Disease',
    };

    corrections.forEach((k, v) {
      s = s.replaceAll(RegExp(k, caseSensitive: false), v);
    });

    // Capitalize each word
    s = s
        .split(' ')
        .map(
          (w) =>
              w.isEmpty ? w : w[0].toUpperCase() + w.substring(1).toLowerCase(),
        )
        .join(' ');

    return s.trim();
  }
  // ------------------------------------------------------------

  Future<void> _initModel() async {
    try {
      final labelData = await rootBundle.loadString('assets/labels.txt');

      // *** APPLY CLEAN LABEL HERE ***
      labels.addAll(
        labelData
            .split('\n')
            .where((l) => l.trim().isNotEmpty)
            .map((l) => cleanLabel(l)),
      );
    } catch (_) {
      // ignore
    }

    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/plant_disease_model.tflite',
      );
      _modelLoaded = true;
      if (mounted) setState(() => _message = "Please select an image.");
    } catch (e) {
      if (mounted) setState(() => _message = "Model load failed: $e");
    }
  }

  Future<void> _pickImage(ImageSource src) async {
    if (!_modelLoaded) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Model is still loading")));
      return;
    }

    final XFile? file = await _picker.pickImage(source: src, imageQuality: 85);
    if (file == null) return;

    setState(() {
      _selectedImage = File(file.path);
      _isLoading = true;
      _latestPredictions = {};
      _selectedDiseaseInfo = null;
      _selectedDiseaseConfidence = null;
      _scanResult = null;
      _message = "Processing...";
    });

    await _runInference(_selectedImage!);
  }

  Future<void> _runInference(File file) async {
    try {
      final bytes = await file.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      if (image == null) throw 'Cannot decode image';

      final resized = img.copyResize(
        image,
        width: inputSize,
        height: inputSize,
      );
      var inputFloats = _imageToFloatList(resized, inputSize);

      // NOTE: you used .reshape in your original file. Keep as-is to match your environment.
      final input = inputFloats.reshape([1, inputSize, inputSize, 3]);
      var output = List.filled(labels.length, 0.0).reshape([1, labels.length]);
      _interpreter.run(input, output);

      Map<String, double> rawPredictions = {};
      for (int i = 0; i < labels.length; i++) {
        rawPredictions[labels[i]] = output[0][i] * 100;
      }

      final adjusted = _adjustPredictions(rawPredictions);
      // Save predictions
      _latestPredictions = adjusted;

      // Pick top prediction
      final top = _latestPredictions.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );

      // Multi-level validation
      const double minConfidenceThreshold = 50.0; // Minimum confidence required
      const double uncertaintyThreshold = 20.0;   // Gap between top 2 predictions
      
      // Get top 2 predictions
      final sortedPredictions = _latestPredictions.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      final topPrediction = sortedPredictions[0];
      final secondPrediction = sortedPredictions.length > 1 ? sortedPredictions[1] : null;
      
      // Check 1: Is top confidence too low?
      if (topPrediction.value < minConfidenceThreshold) {
        if (!mounted) return;
        setState(() {
          _message = "⚠️ Plant not recognized. Please upload a clear image of: Banana, Corn, Paddy, Pepper, or Strawberry leaf.";
          _isLoading = false;
          _selectedDiseaseInfo = null;
          _selectedDiseaseConfidence = null;
          _scanResult = null;
          _latestPredictions = {};
        });
        return;
      }
      
      // Check 2: Is model uncertain? (top 2 predictions are too close)
      if (secondPrediction != null) {
        final gap = topPrediction.value - secondPrediction.value;
        if (gap < uncertaintyThreshold) {
          if (!mounted) return;
          setState(() {
            _message = "⚠️ Image unclear. Model is uncertain. Please upload a clearer image or ensure it's one of: Banana, Corn, Paddy, Pepper, Strawberry.";
            _isLoading = false;
            _selectedDiseaseInfo = null;
            _selectedDiseaseConfidence = null;
            _scanResult = null;
            _latestPredictions = {};
          });
          return;
        }
      }

      // Get disease info by cleaned label. Fallback to "Negative" entry if not found.
      final String cleanedKey = cleanLabel(top.key);
      final DiseaseInfo info = diseaseInfoDatabase.containsKey(cleanedKey)
          ? diseaseInfoDatabase[cleanedKey]!
          : (diseaseInfoDatabase.containsKey("Negative")
                ? diseaseInfoDatabase["Negative"]!
                : DiseaseInfo(
                    name: cleanedKey,
                    description: "No additional information available.",
                  ));

      if (!mounted) return;
      setState(() {
        _message =
            "Result: ${cleanLabel(top.key)} (${top.value.toStringAsFixed(2)}%)";
        _isLoading = false;
        _selectedDiseaseInfo = info;
        _selectedDiseaseConfidence = top.value;
        _scanResult = cleanLabel(top.key);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _message = "Error: $e";
        _isLoading = false;
        _selectedDiseaseInfo = null;
        _selectedDiseaseConfidence = null;
        _scanResult = null;
      });
    }
  }

  Map<String, double> _adjustPredictions(Map<String, double> original) {
    const double threshold = 1.0;

    final filtered = original.entries
        .where((e) => e.value >= threshold)
        .toList();

    if (filtered.isEmpty) {
      return {for (var e in original.entries) e.key: e.value};
    }

    final double sum = filtered.fold(0.0, (s, e) => s + e.value);

    final adjusted = {for (var e in filtered) e.key: (e.value / sum) * 100};

    return adjusted;
  }

  Float32List _imageToFloatList(img.Image image, int size) {
    final converted = Float32List(size * size * 3);
    int idx = 0;
    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        final px = image.getPixel(x, y);
        converted[idx++] = (px.b - 103.939);
        converted[idx++] = (px.g - 116.779);
        converted[idx++] = (px.r - 123.68);
      }
    }
    return converted;
  }

  // ---------------- SAVE FORM ----------------
  void _showSaveForm() {
    if (_selectedImage == null || _latestPredictions.isEmpty) return;

    final nameCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    List<String> folders = DiaryService.getAllFolders();
    String selectedFolder = folders.isNotEmpty ? folders.first : "";

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text('Save to Diary', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 20)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: nameCtrl,
                        decoration: InputDecoration(
                          labelText: 'Entry Name',
                          labelStyle: GoogleFonts.montserrat(color: Colors.grey.shade700),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Folder',
                                labelStyle: GoogleFonts.montserrat(color: Colors.grey.shade700),
                                border: InputBorder.none,
                              ),
                              value: selectedFolder.isEmpty ? null : selectedFolder,
                              items:
                                  [
                                    const DropdownMenuItem(
                                      value: "",
                                      child: Text("None"),
                                    ),
                                  ] +
                                  folders
                                      .map(
                                        (f) => DropdownMenuItem(
                                          value: f,
                                          child: Text(f),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (v) =>
                                  setDialog(() => selectedFolder = v ?? ""),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            final newName = await _showCreateFolderDialog();
                            if (newName != null && newName.isNotEmpty) {
                              await DiaryService.createFolder(newName);
                              folders = DiaryService.getAllFolders();
                              setDialog(() => selectedFolder = newName);
                            }
                          },
                          child: Text("New", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: notesCtrl,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Notes (optional)',
                          labelStyle: GoogleFonts.montserrat(color: Colors.grey.shade700),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('Cancel', style: GoogleFonts.montserrat(color: Colors.grey.shade700)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final top = _latestPredictions.entries.reduce(
                      (a, b) => a.value > b.value ? a : b,
                    );

                    final entry = DiaryEntry(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameCtrl.text.isEmpty ? "Untitled" : nameCtrl.text,
                      disease: cleanLabel(top.key),
                      confidence: double.parse(top.value.toStringAsFixed(2)),
                      allConfidences: {
                        for (var e in _latestPredictions.entries)
                          cleanLabel(e.key): e.value,
                      },
                      imagePath: _selectedImage!.path,
                      notes: notesCtrl.text,
                      folder: selectedFolder,
                      date: DateTime.now(),
                    );

                    await DiaryService.addEntry(entry);
                    if (!mounted) return;
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Saved to Diary", style: GoogleFonts.montserrat()),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Colors.green.shade700,
                      ),
                    );
                  },
                  child: Text("Save", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<String?> _showCreateFolderDialog() {
    final ctrl = TextEditingController();
    return showDialog<String?>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Create Folder", style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: ctrl,
            decoration: InputDecoration(
              labelText: "Folder name",
              labelStyle: GoogleFonts.montserrat(color: Colors.grey.shade700),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text("Cancel", style: GoogleFonts.montserrat(color: Colors.grey.shade700)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(dialogContext, ctrl.text.trim()),
            child: Text("Create", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (_modelLoaded) _interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: Text(
          "Plant Diagnosis",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Colors.green.shade800,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
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
              icon: Icon(Icons.bookmark_rounded, color: Colors.green.shade700),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DiaryScreen()),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 340,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.green.shade50],
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.2),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: _selectedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add_photo_alternate_rounded,
                              size: 80,
                              color: Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Upload Plant Image",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Camera or Gallery",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(_selectedImage!, fit: BoxFit.cover),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.3),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 28),

            if (_isLoading)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
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
                child: Column(
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        color: Colors.green.shade700,
                        strokeWidth: 4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Analyzing Plant...',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This may take a few seconds',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )
            else if (_selectedImage != null)
              Container(
                width: double.infinity,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.green.shade600, Colors.green.shade400],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Diagnosis Result',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green.shade200, width: 2),
                      ),
                      child: Text(
                        _message,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.green.shade900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (_latestPredictions.isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade600, Colors.blue.shade400],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Confidence Scores",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    ..._latestPredictions.entries.map((e) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.grey.shade50, Colors.white],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    cleanLabel(e.key),
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.green.shade600, Colors.green.shade400],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "${e.value.toStringAsFixed(1)}%",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: e.value / 100,
                                minHeight: 10,
                                color: Colors.green.shade600,
                                backgroundColor: Colors.green.shade100,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],

            if (_selectedDiseaseInfo != null) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade50, Colors.green.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _selectedDiseaseInfo!.name,
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ),
                        if (_selectedDiseaseConfidence != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.green.shade700, Colors.green.shade500],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${_selectedDiseaseConfidence!.toStringAsFixed(1)}%",
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _selectedDiseaseInfo!.description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.green.shade800,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (_selectedDiseaseInfo!.symptoms.isNotEmpty) ...[
                      _buildInfoSection(
                        'Symptoms',
                        Icons.error_outline_rounded,
                        _selectedDiseaseInfo!.symptoms,
                        Colors.orange,
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (_selectedDiseaseInfo!.prevention.isNotEmpty) ...[
                      _buildInfoSection(
                        'Prevention',
                        Icons.shield_outlined,
                        _selectedDiseaseInfo!.prevention,
                        Colors.blue,
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (_selectedDiseaseInfo!.treatment.isNotEmpty) ...[
                      _buildInfoSection(
                        'Treatment',
                        Icons.medical_services_outlined,
                        _selectedDiseaseInfo!.treatment,
                        Colors.red,
                      ),
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),

            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        colors: [Colors.green.shade600, Colors.green.shade500],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt_rounded, size: 22),
                      label: Text("Camera", style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade600, Colors.blue.shade500],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.photo_library_rounded, size: 22),
                      label: Text("Gallery", style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: [Colors.orange.shade600, Colors.orange.shade500],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.bookmark_add_rounded, size: 22),
                label: Text("Save to Diary", style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 17)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                onPressed: _latestPredictions.isNotEmpty ? _showSaveForm : null,
              ),
            ),
            if (_scanResult != null) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade600, Colors.purple.shade500],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.info_outline_rounded, size: 22),
                  label: Text("View Plant Info", style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 17)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  onPressed: () {
                    final plantName = _extractPlantName(_scanResult!);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlantListScreen(targetPlant: plantName),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, IconData icon, List<String> items, MaterialColor color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: color.shade700),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.green.shade900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color.shade600,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.green.shade800,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
