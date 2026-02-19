import '../models/plant.dart';
import '../models/disease.dart';

final List<Plant> plantList = [
  Plant(
    name: 'Banana',
    image: 'assets/images/banana.png',
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
        name: 'Yellow and Black Sigatoka',
        info: 'Leaf spot disease reducing photosynthesis.',
      ),
      Disease(name: 'Healthy', info: 'No disease detected.', isHealthy: true),
    ],
  ),
  Plant(
    name: 'Corn',
    image: 'assets/images/corn.png',
    info:
        'Corn is a staple food crop in Malaysia. It is susceptible to various '
        'leaf diseases that can impact yield.',
    diseases: [
      Disease(
        name: 'Cercopora Leaf Spot Gray Leaf Spot',
        info: 'Fungal disease leading to grayish lesions on leaves.',
      ),
      Disease(
        name: 'Common Rust',
        info: 'Fungal disease producing rust-colored pustules on leaves.',
      ),
      Disease(
        name: 'Northern Leaf Blight',
        info: 'Fungal disease causing elongated lesions on leaves.',
      ),
      Disease(name: 'Healthy', info: 'No disease detected.', isHealthy: true),
    ],
  ),
  Plant(
    name: 'Paddy',
    image: 'assets/images/paddy.png',
    info:
        'Paddy is a major food crop in Malaysia. It is prone to several leaf '
        'diseases that can affect growth and yield.',
    diseases: [
      Disease(
        name: 'Bacterial Leaf Blight',
        info: 'Bacterial disease leading to wilting and yellowing of leaves.',
      ),
      Disease(
        name: 'Brown Spot',
        info: 'Fungal disease causing brown spots on leaves.',
      ),
      Disease(
        name: 'Leaf Blast',
        info: 'Fungal disease causing lesions on leaves and stems.',
      ),
      Disease(
        name: 'Leaf Scald',
        info: 'Bacterial disease affecting leaf sheath and blades.',
      ),
      Disease(name: 'Healthy', info: 'No disease detected.', isHealthy: true),
    ],
  ),
  Plant(
    name: 'Chilli',
    image: 'assets/images/pepper.png',
    info:
        'Pepper is a common spice crop in Malaysia. It can be affected by '
        'various leaf diseases that impact plant health.',
    diseases: [
      Disease(
        name: 'Bacterial Spot',
        info: 'Bacterial disease causing water-soaked spots on leaves.',
      ),
      Disease(name: 'Healthy', info: 'No disease detected.', isHealthy: true),
    ],
  ),
  Plant(
    name: 'Strawberry',
    image: 'assets/images/strawberry.png',
    info:
        'Strawberry is a popular fruit crop in Malaysia. It is susceptible to '
        'several leaf diseases that can affect fruit quality.',
    diseases: [
      Disease(
        name: 'Leaf Scorch',
        info: 'Fungal disease causing small, dark spots on leaves.',
      ),
      Disease(name: 'Healthy', info: 'No disease detected.', isHealthy: true),
    ],
  ),
];
