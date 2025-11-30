import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DiscoverModel {
  final String section;
  final String title;
  final String textcontent;
  final String image;
  
  final IconData icon;
  final Color colortheme;

  DiscoverModel({
    required this.section,
    required this.title,
    required this.textcontent,
    required this.image,
    required this.icon,
    required this.colortheme,
  });
}


List<DiscoverModel> discoverList = [
  DiscoverModel(
    section: "sleep apnea",
    title: "Symptoms of sleep apnea",
    textcontent: " • Waking up frequently during the night \n • Abnormal breathing patterns (breathing becoming faster and deeper, then gradually becoming shallow until breathing stops, before starting again) Snoring\n• Daytime tiredness, sleepiness, or feeling exhausted upon waking\n• Waking up feeling short of breath or as if choking",
    image: "image/dis1.jpg",
    icon: Icons.nights_stay_rounded,
    colortheme: Color.fromARGB(255, 0, 94, 160),
  ),

  DiscoverModel(
    section: "severity of sleep apnea",
    title: "What is AHI?",
    textcontent: "AHI measures the average number of apnea events (when you stop breathing during sleep) and hypopnea events (reduced airflow) per hour. The severity levels of sleep apnea are as follows:\n• Mild sleep apnea: AHI of 5–14 events per hour\n• Moderate sleep apnea: AHI of 15–29 events per hour\n• Severe sleep apnea: AHI of 30 or more events per hour",
    image: "image/dis2.jpg",
    icon: Icons.record_voice_over_rounded,
    colortheme: Color(0xFF58008B),
  ),

  DiscoverModel(
    section: "treatment",
    title: "Treatment options include ",
    textcontent: " • Using breathing support devices, such as Continuous Positive Airway Pressure (CPAP) machines \n• Managing any underlying conditions that may cause or increase the risk of sleep apnea \n• Changing your sleeping position (avoiding sleeping on your back) to prevent airway obstruction \n• Using oral appliances (mouthpieces) to help keep the airway open \n• Using Neuromuscular Electrical Stimulation (NMES) devices to prevent the tongue and upper airway muscles from collapsing and blocking the airway during sleep \n• Taking medications \n• Undergoing surgery",
    image: "image/dis3.jpg",
    icon: Icons.health_and_safety_sharp,
    colortheme: Color.fromARGB(255, 0, 161, 5),
  ),
];


