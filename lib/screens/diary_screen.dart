import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/diary_service.dart';
import 'folder_view_screen.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> with SingleTickerProviderStateMixin {
  List<String> folders = [];
  Map<String, FolderStats> folderStats = {};
  String searchQuery = '';

  final _searchCtrl = TextEditingController();
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _reload();
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _reload() {
    folders = DiaryService.getAllFolders();
    folderStats = {};
    
    for (var folder in folders) {
      final entries = DiaryService.getEntriesByFolder(folder);
      int totalImages = 0;
      int healthyCount = 0;
      int diseasedCount = 0;
      DateTime? latestDate;
      String? latestImage;
      
      for (var entry in entries) {
        totalImages += entry.imagePaths.length;
        if (entry.disease.toLowerCase().contains('healthy')) {
          healthyCount++;
        } else {
          diseasedCount++;
        }
        
        if (latestDate == null || entry.date.isAfter(latestDate)) {
          latestDate = entry.date;
          latestImage = entry.primaryImage;
        }
      }
      
      folderStats[folder] = FolderStats(
        totalEntries: entries.length,
        totalImages: totalImages,
        healthyCount: healthyCount,
        diseasedCount: diseasedCount,
        latestDate: latestDate,
        latestImage: latestImage,
      );
    }
    
    setState(() {});
  }

  List<String> get _filteredFolders {
    if (searchQuery.trim().isEmpty) {
      return folders;
    }
    final q = searchQuery.toLowerCase();
    return folders.where((f) => f.toLowerCase().contains(q)).toList();
  }

  Future<void> _showFolderManager() async {
    await showDialog(
      context: context,
      builder: (dialogContext) => FolderManagerDialog(onClose: _reload),
    );
  }

  Future<void> _confirmDeleteFolder(String folderName) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Folder', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
          'Delete folder "$folderName"? All entries will be unassigned.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Delete', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
    
    if (ok == true) {
      await DiaryService.deleteFolder(folderName, migrateTo: '');
      _reload();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Folder deleted', style: GoogleFonts.poppins()),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.green.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredFolders;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text(
          'Plant Diary',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.green.shade800,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.create_new_folder, color: Colors.green.shade700),
              onPressed: _showFolderManager,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.green.shade700),
                  hintText: 'Search folders...',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: (v) => setState(() => searchQuery = v),
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final folder = filtered[i];
                      final stats = folderStats[folder];
                      return TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: Duration(milliseconds: 300 + (i * 50)),
                        builder: (context, double value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: _buildFolderCard(folder, stats),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_outlined, size: 100, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No folders yet',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a folder to organize your scans',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: Text('Create Folder', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _showFolderManager,
          ),
        ],
      ),
    );
  }

  Widget _buildFolderCard(String folder, FolderStats? stats) {
    if (stats == null) return const SizedBox();
    
    final hasData = stats.totalImages > 0;
    final healthPercentage = stats.totalEntries > 0
        ? (stats.healthyCount / stats.totalEntries * 100)
        : 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FolderViewScreen(folderName: folder),
              ),
            ).then((_) => _reload());
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.green.shade100, Colors.green.shade200],
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: hasData && stats.latestImage != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(
                                File(stats.latestImage!),
                                fit: BoxFit.cover,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.4),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.green.shade700, Colors.green.shade500],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    '+${stats.totalImages}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.folder_rounded,
                                size: 50,
                                color: Colors.green.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Empty',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              folder,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: PopupMenuButton(
                              icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade700),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_rounded, color: Colors.red.shade400, size: 22),
                                      const SizedBox(width: 10),
                                      Text('Delete Folder', style: GoogleFonts.poppins(color: Colors.red.shade400, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  onTap: () => Future.delayed(
                                    const Duration(milliseconds: 100),
                                    () => _confirmDeleteFolder(folder),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          _buildStatChip(
                            Icons.photo_library_rounded,
                            '${stats.totalImages} images',
                            Colors.blue,
                          ),
                          if (stats.healthyCount > 0)
                            _buildStatChip(
                              Icons.check_circle_rounded,
                              '${stats.healthyCount} healthy',
                              Colors.green,
                            ),
                          if (stats.diseasedCount > 0)
                            _buildStatChip(
                              Icons.warning_rounded,
                              '${stats.diseasedCount} diseased',
                              Colors.orange,
                            ),
                        ],
                      ),
                      if (stats.latestDate != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.schedule_rounded, size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 6),
                            Text(
                              'Latest: ${stats.latestDate!.toLocal().toString().split(' ')[0]}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (stats.totalEntries > 0) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: healthPercentage / 100,
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade200,
                            color: healthPercentage >= 70
                                ? Colors.green.shade600
                                : healthPercentage >= 40
                                    ? Colors.orange.shade600
                                    : Colors.red.shade600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${healthPercentage.toStringAsFixed(0)}% healthy',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
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

  Widget _buildStatChip(IconData icon, String label, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.shade100, color.shade200],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.shade300, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color.shade700),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

class FolderStats {
  final int totalEntries;
  final int totalImages;
  final int healthyCount;
  final int diseasedCount;
  final DateTime? latestDate;
  final String? latestImage;

  FolderStats({
    required this.totalEntries,
    required this.totalImages,
    required this.healthyCount,
    required this.diseasedCount,
    this.latestDate,
    this.latestImage,
  });
}

class FolderManagerDialog extends StatefulWidget {
  final VoidCallback? onClose;
  const FolderManagerDialog({super.key, this.onClose});

  @override
  State<FolderManagerDialog> createState() => _FolderManagerDialogState();
}

class _FolderManagerDialogState extends State<FolderManagerDialog> {
  List<String> folders = [];
  final ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    folders = DiaryService.getAllFolders();
  }

  Future<void> _createFolder() async {
    final name = ctrl.text.trim();
    if (name.isEmpty) return;
    await DiaryService.createFolder(name);
    ctrl.clear();
    folders = DiaryService.getAllFolders();
    setState(() {});
  }

  Future<void> _renameFolder(String oldName) async {
    final nameCtrl = TextEditingController(text: oldName);
    final newName = await showDialog<String?>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Rename Folder', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: nameCtrl,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              hintStyle: GoogleFonts.poppins(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, null),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(dialogContext, nameCtrl.text.trim()),
            child: Text('Rename', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty) {
      await DiaryService.renameFolder(oldName, newName);
      folders = DiaryService.getAllFolders();
      setState(() {});
    }
  }

  Future<void> _deleteFolder(String name) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Folder', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
          'Delete folder "$name"? Entries in this folder will be unassigned.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Delete', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await DiaryService.deleteFolder(name, migrateTo: '');
      folders = DiaryService.getAllFolders();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text('Manage Folders', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 22)),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: ctrl,
                        decoration: InputDecoration(
                          hintText: 'New folder name',
                          hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _createFolder,
                    child: Text('Add', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (folders.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No folders yet',
                  style: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 14),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: folders.length,
                  itemBuilder: (context, i) {
                    final f = folders[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.folder, color: Colors.green.shade700),
                        title: Text(f, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit_outlined, color: Colors.blue.shade600),
                              onPressed: () => _renameFolder(f),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                              onPressed: () => _deleteFolder(f),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: () {
            Navigator.pop(context);
            widget.onClose?.call();
          },
          child: Text('Close', style: GoogleFonts.poppins(fontSize: 16)),
        ),
      ],
    );
  }
}
