import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'course_screen.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({Key? key}) : super(key: key);

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<DocumentSnapshot> _languages = [];

  @override
  void initState() {
    super.initState();
    _loadLanguages();
  }

  Future<void> _loadLanguages() async {
    setState(() => _isLoading = true);
    try {
      final QuerySnapshot languagesSnapshot =
          await _firestore.collection('languages').orderBy('name').get();

      setState(() {
        _languages = languagesSnapshot.docs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Erreur lors du chargement des langues: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAddLanguageDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final imageUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une langue'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la langue',
                  prefixIcon: Icon(Icons.language),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL du drapeau',
                  prefixIcon: Icon(Icons.flag),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) {
                _showErrorSnackBar('Le nom de la langue est obligatoire');
                return;
              }

              try {
                await _firestore.collection('languages').add({
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'imageUrl': imageUrlController.text,
                  'levels': ['Débutant', 'Intermédiaire', 'Avancé'],
                  'createdAt': FieldValue.serverTimestamp(),
                });

                if (!mounted) return;
                Navigator.pop(context);
                _loadLanguages();
              } catch (e) {
                _showErrorSnackBar('Erreur lors de l\'ajout: $e');
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDetails(Map<String, dynamic> language, String languageId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF5F5F5),
        title: Text(
          language['name'] ?? 'Détails de la langue',
          style: const TextStyle(color: Color(0xFF4A4A4A)),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (language['imageUrl'] != null &&
                  language['imageUrl'].toString().isNotEmpty)
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage(language['imageUrl']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              if (language['description'] != null)
                Text(
                  language['description'],
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF666666),
                  ),
                ),
              const SizedBox(height: 24),
              const Text(
                'Niveaux disponibles:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4A4A),
                ),
              ),
              const SizedBox(height: 16),
              ...(language['levels'] as List<dynamic>? ?? []).map(
                (level) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseScreen(
                            languageId: languageId,
                            languageName: language['name'] ?? '',
                            level: level.toString(),
                          ),
                        ),
                      );
                    },
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFBE9E7E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        _getLevelIcon(level.toString()),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      level.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A4A4A),
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Color(0xFFBE9E7E),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Fermer',
              style: TextStyle(color: Color(0xFFBE9E7E)),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getLevelIcon(String level) {
    switch (level.toLowerCase()) {
      case 'débutant':
        return Icons.star_border;
      case 'intermédiaire':
        return Icons.star_half;
      case 'avancé':
        return Icons.star;
      default:
        return Icons.star_border;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EchoLang',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFBE9E7E),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.workspace_premium),
            onPressed: () {
              Navigator.pushNamed(context, '/certificates');
            },
          ),
        ],
      ),
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
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFBE9E7E)),
                ),
              )
            : _languages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.language,
                          size: 64,
                          color: Colors.grey.withOpacity(0.7),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Aucune langue disponible',
                          style: TextStyle(
                            color: Color(0xFF4A4A4A),
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _languages.length,
                    itemBuilder: (context, index) {
                      final data =
                          _languages[index].data() as Map<String, dynamic>;
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CourseScreen(
                                languageId: _languages[index].id,
                                languageName: data['name'] ?? '',
                                level:
                                    'Débutant', // Par défaut, commencer par le niveau débutant
                              ),
                            ),
                          ),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 120,
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: data['imageUrl'] != null
                                        ? DecorationImage(
                                            image:
                                                NetworkImage(data['imageUrl']),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                    color: const Color(0xFFE8E1D9),
                                  ),
                                  child: data['imageUrl'] == null
                                      ? const Icon(
                                          Icons.language,
                                          size: 40,
                                          color: Color(0xFFBE9E7E),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        data['name'] ?? 'Sans nom',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF4A4A4A),
                                        ),
                                      ),
                                      if (data['description'] != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          data['description'],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF666666),
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      _buildProgressIndicator(data),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Color(0xFFBE9E7E),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLanguageDialog,
        backgroundColor: const Color(0xFFBE9E7E),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildProgressIndicator(Map<String, dynamic> language) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Progression',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: 0.0, // TODO: Calculer la progression réelle
          backgroundColor: const Color(0xFFE8E1D9),
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFBE9E7E)),
        ),
      ],
    );
  }
}
