// lib/data/disease_data.dart
class DiseaseInfo {
  final String name;
  final String description;
  final List<String> symptoms;
  final List<String> prevention;
  final List<String> treatment;

  DiseaseInfo({
    required this.name,
    required this.description,
    this.symptoms = const [],
    this.prevention = const [],
    this.treatment = const [],
  });
}

final Map<String, DiseaseInfo> diseaseInfoDatabase = {
  // BANANA
  "Banana Cordana": DiseaseInfo(
    name: "Banana Cordana Leaf Spot",
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
    name: "Panama Disease (Fusarium wilt)",
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
    description: "No visible disease.",
    prevention: [
      "Maintain consistent watering and sunlight",
      "Inspect leaves weekly",
    ],
    treatment: [],
  ),

  // CORN
  "Corn Cercospora Leaf Spot Gray Leaf Spot": DiseaseInfo(
    name: "Gray Leaf Spot (Cercospora)",
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
    description: "Reddish-brown pustules on leaves due to Puccinia species.",
    symptoms: ["Reddish/brown pustules", "Leaf yellowing"],
    prevention: ["Plant resistant varieties", "Avoid overhead irrigation"],
    treatment: ["Fungicide for severe outbreaks"],
  ),
  "Corn Northern Leaf Blight": DiseaseInfo(
    name: "Northern Leaf Blight",
    description: "Long cigar-shaped lesions caused by Exserohilum turcicum.",
    symptoms: ["Cigar-shaped lesions", "Leaf necrosis"],
    prevention: ["Resistant hybrids", "Residue management"],
    treatment: ["Fungicide if necessary"],
  ),
  "Corn Healthy": DiseaseInfo(
    name: "Healthy Corn Leaf",
    description: "No visible disease signs.",
    prevention: ["Proper spacing and irrigation"],
    treatment: [],
  ),

  // NEGATIVE / UNKNOWN
  "Negative": DiseaseInfo(
    name: "No Disease Detected",
    description:
        "The model did not detect a known disease. Consider retaking the photo with better lighting/angle.",
    prevention: ["Take clear photos", "Capture multiple leaves/angles"],
    treatment: [],
  ),

  // PADDY (RICE)
  "Paddy Bacterial Leaf Blight": DiseaseInfo(
    name: "Rice Bacterial Leaf Blight",
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
    description: "Brown circular lesions, often from Bipolaris.",
    symptoms: ["Brown circular spots", "Seedling blight"],
    prevention: ["Balanced fertilization", "Avoid prolonged drought stress"],
    treatment: ["Seed treatment, fungicide when required"],
  ),
  "Paddy Healthy Leaf Rice": DiseaseInfo(
    name: "Healthy Rice Leaf",
    description: "No visible disease.",
    prevention: ["Balanced fertilization and good drainage"],
    treatment: [],
  ),
  "Paddy Leaf Scald": DiseaseInfo(
    name: "Leaf Scald",
    description:
        "Burnt-looking edges on leaves; associated with certain fungal pathogens.",
    symptoms: ["Scorched leaf edges", "Brown patches"],
    prevention: ["Proper irrigation", "Avoid water stress"],
    treatment: ["Remove damaged tissue", "Improve watering regime"],
  ),
  "Paddy Leaf Blast": DiseaseInfo(
    name: "Rice Leaf Blast",
    description:
        "Diamond-shaped lesions; highly damaging fungal disease (Magnaporthe oryzae).",
    symptoms: ["Diamond-shaped lesions", "Rapid spread in humid weather"],
    prevention: [
      "Use resistant cultivars",
      "Avoid dense planting",
      "Reduce humidity",
    ],
    treatment: ["Apply approved fungicides promptly"],
  ),

  // PEPPER
  "Pepper Bell Bacterial Spot": DiseaseInfo(
    name: "Pepper Bacterial Spot",
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
  "Pepper Bell Healthy": DiseaseInfo(
    name: "Healthy Bell Pepper Leaf",
    description: "No visible issue.",
    prevention: ["Avoid excessive moisture"],
    treatment: [],
  ),

  // STRAWBERRY
  "Strawberry Leaf Scorch": DiseaseInfo(
    name: "Strawberry Leaf Scorch",
    description: "Reddish borders and dead patches caused by fungal pathogens.",
    symptoms: ["Red/purple borders", "Necrotic spots"],
    prevention: ["Good airflow", "Avoid overhead watering", "Remove debris"],
    treatment: ["Remove infected leaves", "Apply fungicide as needed"],
  ),
  "Strawberry Healthy": DiseaseInfo(
    name: "Healthy Strawberry Leaf",
    description: "No visible disease.",
    prevention: ["Provide good sunlight and airflow"],
    treatment: [],
  ),
};
