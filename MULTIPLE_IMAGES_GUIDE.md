# Plant Diary - Multiple Images Support Implementation

## Overview
Enhanced the Plant Diary system to support **multiple images per entry** for comprehensive plant disease progress tracking. Each folder represents a plant/project, and all images are grouped chronologically for easy monitoring.

---

## Changes Made

### 1. **DiaryEntry Model** (`lib/models/diary_entry.dart`)

#### Added Field:
```dart
@HiveField(9)
List<String> imagePaths;  // NEW: List of image paths
```

#### New Properties:
```dart
String get primaryImage => imagePaths.isNotEmpty ? imagePaths.first : imagePath;
int get imageCount => imagePaths.length;
```

#### Constructor Update:
```dart
DiaryEntry({
  required this.id,
  required this.name,
  required this.disease,
  required this.confidence,
  required this.imagePath,
  required this.notes,
  required this.folder,
  required this.date,
  required this.allConfidences,
  List<String>? imagePaths,  // NEW: Optional parameter
}) : imagePaths = imagePaths ?? [imagePath];  // Defaults to single image
```

**Backward Compatibility:** Existing entries with single `imagePath` automatically get converted to `imagePaths` list.

---

### 2. **Hive Adapter** (`lib/models/diary_entry.g.dart`)

Updated to serialize/deserialize the new `imagePaths` field:

```dart
// Read
imagePaths: fields[9] != null ? (fields[9] as List).cast<String>() : null,

// Write
..writeByte(9)
..write(obj.imagePaths);
```

---

### 3. **DiaryService** (`lib/services/diary_service.dart`)

#### New Method:
```dart
static List<DiaryEntry> getEntriesByFolder(String folderName) {
  return _diaryBox.values
      .where((e) => e.folder == folderName)
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));  // Chronological order
}
```

This enables efficient folder-based querying for the gallery view.

---

### 4. **FolderViewScreen** (`lib/screens/folder_view_screen.dart`)

**Complete Rewrite** for chronological image display.

#### Key Features:

##### A. **Image Data Extraction**
```dart
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
  
  images.sort((a, b) => a.date.compareTo(b.date));  // Chronological
}
```

**Logic:**
1. Get all entries for the folder
2. Extract all images from all entries
3. Create `ImageData` object for each image
4. Sort chronologically (oldest first)

##### B. **Image Card Layout**

Each card displays:
- **Full-width image** (300px height)
- **"Scan #X" badge** (top-left) - Shows chronological order
- **Confidence badge** (top-right) - Green/Orange based on health
- **Date & time** - Full timestamp
- **Diagnosis card** with:
  - Icon (✓ for healthy, ⚠ for diseased)
  - Disease name
  - Notes section (if available)
- **Entry name** (bottom-left)
- **Delete button** (bottom-right)

##### C. **Visual Indicators**

**Healthy Plants:**
- Green badge (`Colors.green.shade600`)
- Green diagnosis card background
- Check circle icon

**Diseased Plants:**
- Orange badge (`Colors.orange.shade600`)
- Orange diagnosis card background
- Warning icon

---

### 5. **DiaryScreen** (`lib/screens/diary_screen.dart`)

#### Image Count Badge

Added visual indicator for entries with multiple images:

```dart
if (e.imageCount > 1) ...[
  const SizedBox(width: 8),
  Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.blue.shade50,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Icon(Icons.photo_library, size: 12, color: Colors.blue.shade700),
        const SizedBox(width: 4),
        Text('${e.imageCount}', style: GoogleFonts.montserrat(...)),
      ],
    ),
  ),
],
```

Shows: **📷 3** (if entry has 3 images)

---

## User Workflow

### **Scenario: Tracking Banana Disease Progress**

#### Step 1: Create Folder
```
Diary → Folder Manager → Create "Banana Field A"
```

#### Step 2: First Scan (Day 1)
```
Scanner → Scan leaf → Save to Diary
  Name: "Banana Plant 1"
  Folder: "Banana Field A"
  Notes: "Initial scan, leaf looks healthy"
  Image: banana_day1.jpg
```

Entry saved with:
```dart
imagePaths: ["banana_day1.jpg"]
```

#### Step 3: Follow-up Scans (Day 7, Day 14)

**Option A: Add to same entry (future enhancement)**
- Would append to existing `imagePaths` list

**Option B: Create new entries**
```
Day 7 Entry:
  imagePaths: ["banana_day7.jpg"]
  
Day 14 Entry:
  imagePaths: ["banana_day14.jpg"]
```

#### Step 4: View Progress
```
Diary → Filter "Banana Field A" → "View as Gallery"
```

**Displays:**
```
┌─────────────────────────────┐
│ Scan #1                 95% │
│ [Image: banana_day1.jpg]    │
│ 01 Jan 2025 • 10:00 AM     │
│ ✓ Healthy                   │
│ Notes: Initial scan...      │
└─────────────────────────────┘

┌─────────────────────────────┐
│ Scan #2                 78% │
│ [Image: banana_day7.jpg]    │
│ 07 Jan 2025 • 10:00 AM     │
│ ⚠ Banana Cordana            │
│ Notes: Disease appeared...  │
└─────────────────────────────┘

┌─────────────────────────────┐
│ Scan #3                 45% │
│ [Image: banana_day14.jpg]   │
│ 14 Jan 2025 • 10:00 AM     │
│ ⚠ Banana Cordana            │
│ Notes: Disease worsening... │
└─────────────────────────────┘
```

**Visual Story:** Farmer sees disease progression over 2 weeks!

---

## ImageData Class

Helper class for folder view:

```dart
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
```

**Purpose:** Flattens entry data to image level for chronological display.

---

## Benefits

### ✅ **Progress Tracking**
- See disease evolution over time
- Chronological timeline view
- Visual comparison between scans

### ✅ **Organized by Location**
- Folders = Fields/Crops
- All scans grouped together
- Easy navigation

### ✅ **Rich Context**
- Date & time for each scan
- Disease diagnosis
- Confidence level
- Custom notes

### ✅ **Clean UI**
- Large, clear images
- Color-coded health status
- Sequential numbering ("Scan #1, #2, #3...")
- Scrollable gallery

---

## Data Structure Example

### Entry 1:
```dart
DiaryEntry(
  id: "uuid-1",
  name: "Banana Plant 1",
  folder: "Banana Field A",
  date: DateTime(2025, 1, 1),
  disease: "Healthy",
  confidence: 95.0,
  imagePath: "path/image1.jpg",  // Backward compatibility
  imagePaths: ["path/image1.jpg"],  // NEW
  notes: "Initial scan",
)
```

### Entry 2 (Multi-image - Future):
```dart
DiaryEntry(
  id: "uuid-2",
  name: "Banana Plant 1 - Progress",
  folder: "Banana Field A",
  date: DateTime(2025, 1, 7),
  disease: "Banana Cordana",
  confidence: 78.0,
  imagePath: "path/image2a.jpg",
  imagePaths: ["path/image2a.jpg", "path/image2b.jpg", "path/image2c.jpg"],
  notes: "Multiple angles of disease",
)
```

### FolderViewScreen Output:
```
Flattened to 4 images total:
1. image1.jpg (Jan 1) - Healthy
2. image2a.jpg (Jan 7) - Diseased
3. image2b.jpg (Jan 7) - Diseased
4. image2c.jpg (Jan 7) - Diseased
```

All displayed chronologically with context!

---

## Future Enhancements

### 1. **Add Images to Existing Entry**
Currently, each scan creates a new entry. Future:
- "Add Another Photo" button
- Append to `imagePaths` list
- Track progress within single entry

### 2. **Before/After Slider**
- Compare Scan #1 vs Scan #N
- Side-by-side view
- Highlight changes

### 3. **Timeline Visualization**
- Horizontal timeline with thumbnails
- Jump to specific date
- Visual health trend graph

### 4. **Export Progress Report**
- PDF with all images
- Chronological report
- Share with agronomists

---

## Technical Notes

### **Hive Migration**
Old entries (single image):
```dart
imagePath: "path.jpg"
imagePaths: null  // Will be auto-converted
```

After first read:
```dart
imagePath: "path.jpg"
imagePaths: ["path.jpg"]  // Auto-populated by constructor
```

No data loss! ✅

### **Performance**
- Efficient folder-based querying
- Images loaded on-demand (no preloading)
- Sorted once during load
- Smooth scrolling (ListView.builder)

---

## Summary

The enhanced Plant Diary system now provides:

✅ **Multiple images per entry support**  
✅ **Chronological folder view**  
✅ **Visual progress tracking**  
✅ **Rich context (date, disease, notes)**  
✅ **Color-coded health indicators**  
✅ **Sequential scan numbering**  
✅ **Backward compatible with existing data**  
✅ **Clean, modern UI**  

Perfect for farmers who want to monitor plant health progression over time! 🌱📸📊
