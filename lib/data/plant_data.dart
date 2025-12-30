import '../models/plant.dart';
import '../models/disease.dart';

final List<Plant> plantList = [
  Plant(
    name: 'Banana',
    image: 'assets/images/banana.jpg',
    info:
        'Banana is a tropical fruit crop widely cultivated in Malaysia. '
        'It is vulnerable to fungal and bacterial leaf diseases.',
    diseases: [
      Disease(
        name: 'Cordana',
        info: 'Fungal disease causing leaf streaks on banana leaves.',
      ),
      Disease(
        name: 'Panama Disease',
        info: 'Soil-borne fungal disease that causes wilting.',
      ),
      Disease(
        name: 'Yellow & Black Sigatoka',
        info: 'Leaf spot disease reducing photosynthesis.',
      ),
      Disease(name: 'Healthy', info: 'No disease detected.', isHealthy: true),
    ],
  ),
  Plant(
    name: 'Corn',
    image: 'assets/images/corn.jpg',
    info:
        'Corn is a staple food crop in Malaysia. It is susceptible to various '
        'leaf diseases that can impact yield.',
    diseases: [
      Disease(
        name: 'Northern Leaf Blight',
        info: 'Fungal disease causing elongated lesions on leaves.',
      ),
      Disease(
        name: 'Gray Leaf Spot',
        info: 'Fungal disease leading to grayish lesions on leaves.',
      ),
      Disease(
        name: 'Common Rust',
        info: 'Fungal disease producing rust-colored pustules on leaves.',
      ),
      Disease(name: 'Healthy', info: 'No disease detected.', isHealthy: true),
    ],
  ),
  Plant(
    name: 'Rice',
    image: 'assets/images/rice.jpg',
    info:
        'Rice is a major food crop in Malaysia. It is prone to several leaf '
        'diseases that can affect growth and yield.',
    diseases: [
      Disease(
        name: 'Rice Blast',
        info: 'Fungal disease causing lesions on leaves and stems.',
      ),
      Disease(
        name: 'Bacterial Leaf Blight',
        info: 'Bacterial disease leading to wilting and yellowing of leaves.',
      ),
      Disease(
        name: 'Sheath Blight',
        info: 'Fungal disease affecting the leaf sheath and blades.',
      ),
      Disease(name: 'Healthy', info: 'No disease detected.', isHealthy: true),
    ],
  ),
  Plant(
    name: 'Pepper',
    image: 'assets/images/pepper.jpg',
    info:
        'Pepper is a common spice crop in Malaysia. It can be affected by '
        'various leaf diseases that impact plant health.',
    diseases: [
      Disease(
        name: 'Anthracnose',
        info: 'Fungal disease causing dark lesions on leaves and fruits.',
      ),
      Disease(
        name: 'Phytophthora Blight',
        info: 'Fungal disease leading to wilting and root rot.',
      ),
      Disease(
        name: 'Bacterial Leaf Spot',
        info: 'Bacterial disease causing water-soaked spots on leaves.',
      ),
      Disease(name: 'Healthy', info: 'No disease detected.', isHealthy: true),
    ],
  ),
  Plant(
    name: 'Strawberry',
    image: 'assets/images/strawberry.jpg',
    info:
        'Strawberry is a popular fruit crop in Malaysia. It is susceptible to '
        'several leaf diseases that can affect fruit quality.',
    diseases: [
      Disease(
        name: 'Leaf Spot',
        info: 'Fungal disease causing small, dark spots on leaves.',
      ),
      Disease(name: 'Healthy', info: 'No disease detected.', isHealthy: true),
    ],
  ),
];
