import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../data/disease_data.dart';
import '../models/diary_entry.dart';
import '../services/diary_service.dart';
import 'diary_screen.dart';
import 'disease_detail_screen.dart';

class ProcessScreen extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  final bool showBottomNav;

  const ProcessScreen({
    super.key,
    this.onToggleTheme,
    this.showBottomNav = true,
  });

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

  // If this is null, the "View Plant Info" button is HIDDEN.
  String? _scanResult;

  @override
  void initState() {
    super.initState();
    // Lock orientation to portrait to prevent UI shifts
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _initModel();
  }

  // ------------------- CLEAN LABEL FUNCTION -------------------
  String cleanLabel(String raw) {
    String s = raw.trim();
    s = s.replaceAll(RegExp(r'_+'), ' '); // Fix underscores
    s = s.replaceAll(RegExp(r'\s+'), ' '); // Fix multiple spaces

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
      'negative': 'Negative',
    };

    corrections.forEach((k, v) {
      s = s.replaceAll(RegExp(k, caseSensitive: false), v);
    });

    s = s
        .split(' ')
        .map(
          (w) =>
              w.isEmpty ? w : w[0].toUpperCase() + w.substring(1).toLowerCase(),
        )
        .join(' ');
    return s.trim();
  }

  Future<void> _initModel() async {
    try {
      final labelData = await rootBundle.loadString('assets/labels.txt');
      labels.clear();
      labels.addAll(
        labelData
            .split('\n')
            .where((l) => l.trim().isNotEmpty)
            .map((l) => cleanLabel(l)),
      );

      _interpreter = await Interpreter.fromAsset(
        'assets/plantmodels/plant_disease_model_new.tflite',
      );

      _modelLoaded = true;
      if (mounted) setState(() => _message = "Please select an image.");
    } catch (e) {
      if (mounted) setState(() => _message = "Model load failed: $e");
    }
  }

  // --- USED BY CAMERA/GALLERY BUTTONS ---
  Future<void> _pickImage(ImageSource src) async {
    if (!_modelLoaded) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Model is still loading")));
      return;
    }

    final XFile? file = await _picker.pickImage(
      source: src,
      imageQuality: 100, // Max quality for sharpness
      maxWidth: 2048,
      maxHeight: 2048,
      preferredCameraDevice: CameraDevice.rear,
    );

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

    await Future.delayed(const Duration(milliseconds: 100));
    await _runInference(_selectedImage!);
  }

  Future<void> _runInference(File file) async {
    try {
      final bytes = await file.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      if (image == null) throw 'Cannot decode image';

      // 1. Fix Orientation
      image = img.bakeOrientation(image);

      // 2. Resize
      img.Image resized = img.copyResize(
        image,
        width: inputSize,
        height: inputSize,
        interpolation: img.Interpolation.linear,
      );

      // 3. Preprocess
      var inputFloats = _imageToFloatList(resized, inputSize);

      // 4. Run Model
      final input = inputFloats.reshape([1, inputSize, inputSize, 3]);
      var output = List.filled(labels.length, 0.0).reshape([1, labels.length]);
      _interpreter.run(input, output);

      Map<String, double> rawPredictions = {};
      for (int i = 0; i < labels.length; i++) {
        rawPredictions[labels[i]] = output[0][i] * 100;
      }

      final adjusted = _adjustPredictions(rawPredictions);
      _latestPredictions = adjusted;

      final top = _latestPredictions.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      final String cleanedKey = cleanLabel(top.key);

      // --- STRICT VALIDATION ---
      const double minConfidenceThreshold = 50.0;
      const double uncertaintyThreshold = 5.0;

      bool shouldHideButton = false;
      String statusMessage = "";

      // Check A: Low Confidence
      if (top.value < minConfidenceThreshold) {
        shouldHideButton = true;
        statusMessage =
            "⚠️ Unrecognized Crop. Please ensure the leaf one of our supported crops: Banana, Corn, Pepper, Paddy, or Strawberry.";
      }
      // Check B: Negative Result
      else if (cleanedKey == "Negative") {
        shouldHideButton = true;
        statusMessage =
            "⚠️ Unrecognized Crop. Please ensure you are scanning a supported leaf: Banana, Corn, Pepper, Paddy, or Strawberry.";
      }
      // Check C: Healthy Result
      else if (cleanedKey == "Healthy") {
        shouldHideButton = true;
        statusMessage = "🌱 Plant is Healthy! No treatment needed.";
      }
      // Check D: Uncertainty
      else {
        final sortedPredictions = _latestPredictions.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        if (sortedPredictions.length > 1) {
          final gap = sortedPredictions[0].value - sortedPredictions[1].value;
          if (gap < uncertaintyThreshold) {
            shouldHideButton = true;
            statusMessage = "⚠️ Result uncertain. Too close to call.";
          }
        }
      }

      // --- DECISION ---
      if (shouldHideButton) {
        if (!mounted) return;
        setState(() {
          _message = statusMessage;
          _isLoading = false;
          _scanResult = null; // BUTTON HIDDEN
          _selectedDiseaseInfo = null;
          _selectedDiseaseConfidence = null;
        });
        return;
      }

      // If here, result is VALID
      final DiseaseInfo info = diseaseInfoDatabase.containsKey(cleanedKey)
          ? diseaseInfoDatabase[cleanedKey]!
          : DiseaseInfo(
              name: cleanedKey,
              description: "No specific info available.",
            );

      if (!mounted) return;
      setState(() {
        _message =
            "Result: ${cleanLabel(top.key)} (${top.value.toStringAsFixed(2)}%)";
        _isLoading = false;
        _selectedDiseaseInfo = info;
        _selectedDiseaseConfidence = top.value;
        _scanResult = cleanedKey; // BUTTON SHOWN
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _message = "Error: $e";
        _isLoading = false;
        _scanResult = null;
      });
    }
  }

  Map<String, double> _adjustPredictions(Map<String, double> original) {
    const double threshold = 1.0;
    final filtered = original.entries
        .where((e) => e.value >= threshold)
        .toList();
    if (filtered.isEmpty)
      return {for (var e in original.entries) e.key: e.value};
    final double sum = filtered.fold(0.0, (s, e) => s + e.value);
    return {for (var e in filtered) e.key: (e.value / sum) * 100};
  }

  Float32List _imageToFloatList(img.Image image, int size) {
    final converted = Float32List(size * size * 3);
    int idx = 0;
    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        final px = image.getPixel(x, y);
        converted[idx++] = (px.r / 127.5) - 1.0;
        converted[idx++] = (px.g / 127.5) - 1.0;
        converted[idx++] = (px.b / 127.5) - 1.0;
      }
    }
    return converted;
  }

  // --- USED BY 'SAVE' BUTTON ---
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                'Save to Diary',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
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
                          labelStyle: GoogleFonts.montserrat(
                            color: Colors.grey.shade700,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
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
                                labelStyle: GoogleFonts.montserrat(
                                  color: Colors.grey.shade700,
                                ),
                                border: InputBorder.none,
                              ),
                              value: selectedFolder.isEmpty
                                  ? null
                                  : selectedFolder,
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            final newName = await _showCreateFolderDialog();
                            if (newName != null && newName.isNotEmpty) {
                              await DiaryService.createFolder(newName);
                              folders = DiaryService.getAllFolders();
                              setDialog(() => selectedFolder = newName);
                            }
                          },
                          child: Text(
                            "New",
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
                          labelStyle: GoogleFonts.montserrat(
                            color: Colors.grey.shade700,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.montserrat(color: Colors.grey.shade700),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                        content: Text(
                          "Saved to Diary",
                          style: GoogleFonts.montserrat(),
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.green.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    "Save",
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
        title: Text(
          "Create Folder",
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              "Cancel",
              style: GoogleFonts.montserrat(color: Colors.grey.shade700),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(dialogContext, ctrl.text.trim()),
            child: Text(
              "Create",
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    if (_modelLoaded) _interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- NEW LOGIC: Extract top prediction details ---
    double topConfidence = 0.0;
    String topLabel = "";

    if (_latestPredictions.isNotEmpty) {
      final topEntry = _latestPredictions.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      topConfidence = topEntry.value;
      topLabel = cleanLabel(
        topEntry.key,
      ); // We use cleanLabel to match your validation
    }

    // Show card only if:
    // 1. Predictions exist
    // 2. Confidence is high enough (>= 50%)
    // 3. It's NOT a "Negative" result
    final bool showConfidenceCard =
        _latestPredictions.isNotEmpty &&
        topConfidence >= 50.0 &&
        topLabel != "Negative";

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
                              colors: [
                                Colors.green.shade600,
                                Colors.green.shade400,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.analytics_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Diagnosis Result",
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
                        border: Border.all(
                          color: Colors.green.shade200,
                          width: 2,
                        ),
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

            // --- UPDATED: CONDITIONAL RENDER FOR CONFIDENCE CARD ---
            if (showConfidenceCard) ...[
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
                              colors: [
                                Colors.blue.shade600,
                                Colors.blue.shade400,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.bar_chart_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.green.shade600,
                                        Colors.green.shade400,
                                      ],
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

            // --- VISIBILITY CHECK FOR DISEASE INFO SECTIONS ---
            if (_selectedDiseaseInfo != null && _scanResult != null) ...[
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.shade700,
                                  Colors.green.shade500,
                                ],
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
                  ],
                ),
              ),
            ],

            const SizedBox(height: 28),

            // --- TIP FOR BETTER FOCUS ---
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Tip: Hold camera 20cm away and tap screen to focus.",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

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
                      label: Text(
                        "Camera",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
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
                      label: Text(
                        "Gallery",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
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
                label: Text(
                  "Save to Diary",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                onPressed: _latestPredictions.isNotEmpty ? _showSaveForm : null,
              ),
            ),

            // --- STRICT VISIBILITY CHECK FOR VIEW INFO BUTTON ---
            // Only show if _scanResult is not null AND NOT "Negative" AND NOT "Healthy"
            if (_scanResult != null &&
                _selectedDiseaseInfo != null &&
                _scanResult != "Negative" &&
                _scanResult != "Healthy") ...[
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
                  label: Text(
                    "View Plant Info",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            DiseaseDetailScreen(diseaseName: _scanResult!),
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
}
