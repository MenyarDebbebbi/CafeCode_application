import 'package:flutter/material.dart';

class LessonsScreen extends StatelessWidget {
  final String theme;
  final List<Map<String, dynamic>> lessons;
  final String languageId;
  final bool isAdmin;

  const LessonsScreen({
    Key? key,
    required this.theme,
    required this.lessons,
    required this.languageId,
    this.isAdmin = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          theme,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () =>
                Navigator.of(context).pushReplacementNamed('/home'),
          ),
        ],
        backgroundColor: const Color(0xFFBE9E7E),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fonctionnalité d\'ajout de leçon à venir'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              backgroundColor: const Color(0xFFBE9E7E),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F5F5),
              Color(0xFFE8E1D9),
            ],
          ),
        ),
        child: lessons.isEmpty
            ? const Center(
                child: Text(
                  'Aucune leçon disponible dans cette catégorie',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: lessons.length,
                itemBuilder: (context, index) {
                  final lesson = lessons[index];
                  final bool isCompleted = lesson['completed'] ?? false;
                  final double progress = lesson['progress']?.toDouble() ?? 0.0;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/lesson',
                          arguments: {
                            'lesson': lesson,
                            'languageId': languageId,
                            'categoryId': theme,
                          },
                        );
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFBE9E7E)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    isCompleted
                                        ? Icons.check_circle
                                        : Icons.play_circle_filled,
                                    color: const Color(0xFFBE9E7E),
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        lesson['title'] ?? 'Sans titre',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Durée: ${lesson['duration'] ?? '15'} min',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFBE9E7E)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '+${lesson['xp'] ?? 0} XP',
                                    style: const TextStyle(
                                      color: Color(0xFFBE9E7E),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (lesson['description'] != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                lesson['description'],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: isCompleted ? 1.0 : progress,
                                backgroundColor: Colors.grey[200],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFBE9E7E),
                                ),
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  isCompleted
                                      ? 'Terminé'
                                      : '${(progress * 100).toInt()}% complété',
                                  style: TextStyle(
                                    color: isCompleted
                                        ? const Color(0xFFBE9E7E)
                                        : Colors.grey[600],
                                    fontSize: 12,
                                    fontWeight: isCompleted
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                if (isCompleted) ...[
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.quiz,
                                    color: Color(0xFFBE9E7E),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Quiz disponible',
                                    style: TextStyle(
                                      color: Color(0xFFBE9E7E),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
