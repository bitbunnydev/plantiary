class DiseaseInfo {
  final String name;
  final String description;
  final String? imagePath;
  final List<String> symptoms;
  final List<String> prevention;
  final List<String> treatment;

  DiseaseInfo({
    required this.name,
    required this.description,
    this.imagePath, // <--- Add to constructor
    this.symptoms = const [],
    this.prevention = const [],
    this.treatment = const [],
  });
}

final Map<String, DiseaseInfo> diseaseInfoDatabase = {
  // BANANA
  "Banana Cordana": DiseaseInfo(
    name: "Banana Cordana Leaf Spot",
    imagePath: "assets/images/banana_cordana.jpg", // <--- Add your image path
    description:
        "Cordana leaf spot causes elongated brown lesions on banana leaves.",
    symptoms: [
      "Brown elongated lesions",
      "Yellowing near lesions",
      "Early leaf drop",
    ],
    prevention: [
      "Improve airflow",
      "Avoid overhead watering",
      "Remove decaying debris",
    ],
    treatment: [
      "Prune infected leaves",
      "Apply recommended fungicide if severe",
    ],
  ),
  "Banana Panama Disease": DiseaseInfo(
    name: "Banana Panama Disease",
    imagePath: "assets/images/banana_panama.jpg",
    description:
        "Soil-borne fungal disease causing wilting and vascular browning.",
    symptoms: ["Yellowing of lower leaves", "Wilting", "Vascular browning"],
    prevention: [
      "Use resistant varieties",
      "Avoid moving infected soil",
      "Improve drainage",
    ],
    treatment: [
      "Remove and destroy infected plants",
      "Soil health improvement",
    ],
  ),
  "Banana Yellow And Black Sigatoka": DiseaseInfo(
    name: "Sigatoka (Yellow/Black)",
    imagePath: "assets/images/banana_sigatoka.jpg",
    description:
        "Leaf-spot disease producing yellow-to-black streaks that reduce photosynthesis.",
    symptoms: [
      "Yellow/black streaks",
      "Necrotic leaf patches",
      "Reduced yield",
    ],
    prevention: [
      "Prune old leaves",
      "Ensure spacing and airflow",
      "Avoid leaf wetness",
    ],
    treatment: ["Regular leaf removal", "Fungicide applications"],
  ),
  "Banana Healthy": DiseaseInfo(
    name: "Healthy Banana Leaf",
    imagePath: "assets/images/banana_healthy.jpg",
    description: "No visible disease. Keep maintaining good practices.",
    prevention: [
      "Maintain consistent watering and sunlight",
      "Inspect leaves weekly",
    ],
    treatment: [],
  ),

  // CORN
  "Corn Cercospora Leaf Spot Gray Leaf Spot": DiseaseInfo(
    name: "Gray Leaf Spot (Cercospora)",
    imagePath: "assets/images/corn_gray_spot.png",
    description:
        "Rectangular gray lesions caused by Cercospora; reduces photosynthesis.",
    symptoms: ["Rectangular gray lesions", "Leaf blight"],
    prevention: [
      "Crop rotation",
      "Plant resistant hybrids",
      "Remove crop residue",
    ],
    treatment: ["Fungicide applications when severe"],
  ),
  "Corn Common Rust": DiseaseInfo(
    name: "Common Rust",
    imagePath: "assets/images/corn_rust.png",
    description: "Reddish-brown pustules on leaves due to Puccinia species.",
    symptoms: ["Reddish/brown pustules", "Leaf yellowing"],
    prevention: ["Plant resistant varieties", "Avoid overhead irrigation"],
    treatment: ["Fungicide for severe outbreaks"],
  ),
  "Corn Northern Leaf Blight": DiseaseInfo(
    name: "Northern Leaf Blight",
    imagePath: "assets/images/corn_blight.png",
    description: "Long cigar-shaped lesions caused by Exserohilum turcicum.",
    symptoms: ["Cigar-shaped lesions", "Leaf necrosis"],
    prevention: ["Resistant hybrids", "Residue management"],
    treatment: ["Fungicide if necessary"],
  ),
  "Corn Healthy": DiseaseInfo(
    name: "Healthy Corn Leaf",
    imagePath: "assets/images/corn_healthy.jpg",
    description: "No visible disease signs.",
    prevention: ["Proper spacing and irrigation"],
    treatment: [],
  ),

  // PADDY
  "Paddy Bacterial Leaf Blight": DiseaseInfo(
    name: "Rice Bacterial Leaf Blight",
    imagePath: "assets/images/paddy_bacterial.jpg",
    description:
        "Bacterial infection causing blade yellowing and burning from the tip.",
    symptoms: ["Yellow/white stripes from tip", "Leaf burning", "Wilting"],
    prevention: [
      "Use disease-free seed",
      "Avoid excessive nitrogen",
      "Field sanitation",
    ],
    treatment: [
      "Remove severely infected plants",
      "Follow local bactericide guidelines",
    ],
  ),
  "Paddy Brown Spot": DiseaseInfo(
    name: "Rice Brown Spot",
    imagePath: "assets/images/paddy_brown_spot.jpg",
    description: "Brown circular lesions, often from Bipolaris.",
    symptoms: ["Brown circular spots", "Seedling blight"],
    prevention: ["Balanced fertilization", "Avoid prolonged drought stress"],
    treatment: ["Seed treatment, fungicide when required"],
  ),
  "Paddy Leaf Blast": DiseaseInfo(
    name: "Rice Leaf Blast",
    imagePath: "assets/images/paddy_blast.png",
    description: "Diamond-shaped lesions; highly damaging fungal disease.",
    symptoms: ["Diamond-shaped lesions", "Rapid spread in humid weather"],
    prevention: [
      "Use resistant cultivars",
      "Avoid dense planting",
      "Reduce humidity",
    ],
    treatment: ["Apply approved fungicides promptly"],
  ),
  "Paddy Leaf Scald": DiseaseInfo(
    name: "Rice Leaf Scald",
    imagePath:
        "assets/images/paddy_scald.jpg", // Make sure this image shows leaf tip drying!
    description:
        "Fungal disease causing zonate lesionsS usually starting at leaf tips.",
    symptoms: [
      "Zonate lesions (light/dark bands)",
      "Leaf tips appear scalded/bleached",
      "Lesions enlarging toward base",
    ],
    prevention: [
      "Use clean or treated seeds",
      "Avoid excessive nitrogen fertilizer",
      "Control weeds",
    ],
    treatment: [
      "Apply fungicides at booting stage",
      "Remove infected plant debris",
    ],
  ),
  "Paddy Healthy Leaf Rice": DiseaseInfo(
    name: "Healthy Rice Leaf",
    imagePath: "assets/images/paddy_healthy.jpg",
    description: "No visible disease.",
    prevention: ["Balanced fertilization and good drainage"],
    treatment: [],
  ),

  // PEPPER
  "Chilli Bacterial Spot": DiseaseInfo(
    name: "Chilli Bacterial Spot",
    imagePath: "assets/images/pepper_bacterial.jpg",
    description: "Water-soaked spots that turn dark; affects leaves and fruit.",
    symptoms: ["Water-soaked spots", "Brown lesions", "Fruit scabbing"],
    prevention: [
      "Use certified seed",
      "Avoid handling wet plants",
      "Sanitize tools",
    ],
    treatment: [
      "Copper sprays as per local recommendations",
      "Remove infected tissue",
    ],
  ),
  "Chilli Healthy": DiseaseInfo(
    name: "Healthy Chilli Leaf",
    imagePath: "assets/images/pepper_healthy.jpg",
    description: "No visible issue.",
    prevention: ["Avoid excessive moisture"],
    treatment: [],
  ),

  // STRAWBERRY
  "Strawberry Leaf Scorch": DiseaseInfo(
    name: "Strawberry Leaf Scorch",
    imagePath: "assets/images/strawberry_scorch.jpg",
    description: "Reddish borders and dead patches caused by fungal pathogens.",
    symptoms: ["Red/purple borders", "Necrotic spots"],
    prevention: ["Good airflow", "Avoid overhead watering", "Remove debris"],
    treatment: ["Remove infected leaves", "Apply fungicide as needed"],
  ),
  "Strawberry Healthy": DiseaseInfo(
    name: "Healthy Strawberry Leaf",
    imagePath: "assets/images/strawberry_healthy.jpg",
    description: "No visible disease.",
    prevention: ["Provide good sunlight and airflow"],
    treatment: [],
  ),

  // NEGATIVE
  "Negative": DiseaseInfo(
    name: "No Disease Detected",
    imagePath: null, // No image for negative
    description: "The model did not detect a known disease.",
    prevention: ["Take clear photos"],
    treatment: [],
  ),
};
