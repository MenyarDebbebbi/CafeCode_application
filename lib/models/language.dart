import 'package:cloud_firestore/cloud_firestore.dart';

class Language {
  final String id;
  final String name;
  final String code;
  final String imageUrl;
  final String description;
  final int totalLessons;
  final Map<String, List<Map<String, dynamic>>> themes;
  final Map<String, List<Map<String, dynamic>>> skills;

  Language({
    required this.id,
    required this.name,
    required this.code,
    required this.imageUrl,
    required this.description,
    required this.totalLessons,
    required this.themes,
    required this.skills,
  });

  factory Language.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Language(
      id: doc.id,
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      totalLessons: data['totalLessons'] ?? 0,
      themes:
          Map<String, List<Map<String, dynamic>>>.from(data['themes'] ?? {}),
      skills:
          Map<String, List<Map<String, dynamic>>>.from(data['skills'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'code': code,
      'imageUrl': imageUrl,
      'description': description,
      'totalLessons': totalLessons,
      'themes': themes,
      'skills': skills,
    };
  }
}
