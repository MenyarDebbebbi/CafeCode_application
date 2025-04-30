import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import '../models/language.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class LanguageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final cloudinary = CloudinaryPublic('daav4neoy', 'ml_default', cache: false);

  // Récupérer toutes les langues
  Stream<List<Language>> getLanguages() {
    return _firestore.collection('languages').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Language.fromFirestore(doc)).toList());
  }

  // Récupérer une langue spécifique
  Future<Language?> getLanguage(String languageId) async {
    final doc = await _firestore.collection('languages').doc(languageId).get();
    return doc.exists ? Language.fromFirestore(doc) : null;
  }

  // Uploader une image vers Cloudinary
  Future<String> uploadImage(File image, String languageCode) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          image.path,
          folder: 'language_flags',
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      print('Erreur lors de l\'upload de l\'image: $e');
      rethrow;
    }
  }

  // Initialiser les langues dans Firebase
  Future<void> initializeLanguages() async {
    try {
      // Français
      final frenchRef = _firestore.collection('languages').doc('french');
      await frenchRef.set({
        'name': 'Français',
        'code': 'fr',
        'flag': '🇫🇷',
        'description': 'Apprenez le français avec des leçons interactives',
        'level': 'Débutant'
      });

      // Créer les catégories pour le français
      final frenchCategories = [
        {
          'name': 'Les bases',
          'description': 'Commencez votre apprentissage avec les fondamentaux',
          'order': 1,
          'lessons': [
            {
              'title': 'L\'alphabet et la prononciation',
              'description':
                  'Maîtrisez l\'alphabet français et ses sons uniques pour une prononciation parfaite',
              'duration': 20,
              'xp': 50,
              'level': 'A1',
              'content': [
                {
                  'type': 'text',
                  'value':
                      'L\'alphabet français comporte 26 lettres, comme l\'alphabet latin.'
                },
                {
                  'type': 'image',
                  'url': 'assets/images/french/alphabet.jpg',
                  'caption': 'L\'alphabet français'
                },
                {
                  'type': 'audio',
                  'url': 'assets/audio/french/alphabet.mp3',
                  'caption': 'Écoutez la prononciation de l\'alphabet'
                }
              ],
              'vocabulary': {
                'title': 'L\'alphabet',
                'words': [
                  {
                    'word': 'A [a]',
                    'translation': 'comme dans "chat"',
                    'example': 'ami, table, papa',
                    'image': 'assets/images/french/vocabulary/ami.jpg',
                    'audio': 'assets/audio/french/vocabulary/a.mp3'
                  },
                  {
                    'word': 'E [ə]',
                    'translation': 'comme dans "le"',
                    'example': 'petit, demain, je',
                    'image': 'assets/images/french/vocabulary/petit.jpg',
                    'audio': 'assets/audio/french/vocabulary/e.mp3'
                  }
                ]
              },
              'questions': [
                {
                  'type': 'multiple_choice',
                  'question':
                      'Quelle est la prononciation correcte de la lettre "E" ?',
                  'options': ['[a]', '[ə]', '[i]', '[o]'],
                  'correctAnswer': 1,
                  'explanation': 'La lettre "E" se prononce [ə] comme dans "le"'
                },
                {
                  'type': 'audio_recognition',
                  'question': 'Écoutez et choisissez la lettre correspondante',
                  'audio': 'assets/audio/french/questions/letter_a.mp3',
                  'options': ['A', 'E', 'I', 'O'],
                  'correctAnswer': 0
                }
              ],
              'exercises': [
                {
                  'type': 'pronunciation',
                  'title': 'Répétez après l\'audio',
                  'items': [
                    {
                      'text': 'bonjour',
                      'audio': 'assets/audio/french/exercises/bonjour.mp3',
                      'image': 'assets/images/french/exercises/bonjour.jpg'
                    }
                  ]
                }
              ]
            },
            {
              'title': 'Les salutations',
              'description':
                  'Apprenez à saluer et à vous présenter en français',
              'duration': 25,
              'xp': 75,
              'level': 'A1',
              'content': [
                {
                  'type': 'text',
                  'value':
                      'Les salutations sont essentielles dans la culture française.'
                },
                {
                  'type': 'image',
                  'url': 'assets/images/french/greetings.jpg',
                  'caption': 'Les différentes façons de se saluer en français'
                },
                {
                  'type': 'video',
                  'url': 'assets/videos/french/greetings.mp4',
                  'caption': 'Regardez comment les Français se saluent'
                }
              ],
              'vocabulary': {
                'title': 'Les salutations',
                'words': [
                  {
                    'word': 'Bonjour',
                    'translation': 'Hello',
                    'context': 'Formel, utilisé toute la journée',
                    'example': 'Bonjour, comment allez-vous ?',
                    'image': 'assets/images/french/vocabulary/bonjour.jpg',
                    'audio': 'assets/audio/french/vocabulary/bonjour.mp3'
                  }
                ]
              },
              'questions': [
                {
                  'type': 'multiple_choice',
                  'question': 'Quelle salutation est formelle ?',
                  'options': ['Salut', 'Bonjour', 'Coucou', 'Hey'],
                  'correctAnswer': 1,
                  'explanation':
                      'Bonjour est la salutation formelle standard en français'
                },
                {
                  'type': 'image_matching',
                  'question': 'Associez l\'image à la bonne salutation',
                  'images': [
                    'assets/images/french/questions/formal_greeting.jpg',
                    'assets/images/french/questions/casual_greeting.jpg'
                  ],
                  'options': ['Bonjour', 'Salut'],
                  'correctAnswers': [0, 1]
                }
              ]
            }
          ]
        },
        {
          'name': 'Voyage et Hébergement',
          'description': 'Apprenez à communiquer pendant vos voyages',
          'order': 3,
          'lessons': [
            {
              'title': 'À l\'hôtel',
              'description':
                  'Vocabulaire et expressions utiles pour séjourner à l\'hôtel',
              'duration': 30,
              'xp': 75,
              'level': 'A2',
              'content': [
                'Faire une réservation',
                'Check-in et check-out',
                'Les services de l\'hôtel'
              ],
              'vocabulary': {
                'title': 'Vocabulaire de l\'hôtel',
                'words': [
                  {
                    'word': 'Réservation',
                    'translation': 'Booking',
                    'example': 'Je voudrais faire une réservation.',
                    'audioFile': 'audio/hotel/reservation.mp3',
                    'hasAudio': true,
                    'icon': Icons.volume_up
                  },
                  {
                    'word': 'Chambre simple',
                    'translation': 'Single room',
                    'example': 'Je souhaite une chambre simple.',
                    'audioFile': 'audio/hotel/chambre_simple.mp3',
                    'hasAudio': true,
                    'icon': Icons.volume_up
                  },
                  {
                    'word': 'Service de chambre',
                    'translation': 'Room service',
                    'example': 'Puis-je commander le service de chambre ?',
                    'audioFile': 'audio/hotel/service_chambre.mp3',
                    'hasAudio': true,
                    'icon': Icons.volume_up
                  }
                ]
              },
              'completed': false,
              'progress': 0
            }
          ]
        },
        {
          'name': 'Nourriture et Restaurant',
          'description':
              'Découvrez la gastronomie française et apprenez à commander au restaurant',
          'order': 2,
          'lessons': [
            {
              'title': 'Au restaurant',
              'description':
                  'Maîtrisez l\'art de commander et de dîner dans un restaurant français',
              'duration': 35,
              'xp': 80,
              'level': 'A2',
              'content': [
                {
                  'type': 'text',
                  'value':
                      'La gastronomie française est célèbre dans le monde entier.'
                },
                {
                  'type': 'image',
                  'url': 'assets/images/french/restaurant.jpg',
                  'caption': 'Un restaurant français typique'
                },
                {
                  'type': 'video',
                  'url': 'assets/videos/french/ordering.mp4',
                  'caption': 'Comment commander dans un restaurant français'
                }
              ],
              'vocabulary': {
                'title': 'Au restaurant',
                'words': [
                  {
                    'word': 'Le menu',
                    'translation': 'The menu',
                    'example': 'Puis-je voir le menu, s\'il vous plaît ?',
                    'image': 'assets/images/french/vocabulary/menu.jpg',
                    'audio': 'assets/audio/french/vocabulary/menu.mp3'
                  },
                  {
                    'word': 'L\'addition',
                    'translation': 'The bill',
                    'example': 'L\'addition, s\'il vous plaît.',
                    'image': 'assets/images/french/vocabulary/addition.jpg',
                    'audio': 'assets/audio/french/vocabulary/addition.mp3'
                  }
                ]
              },
              'questions': [
                {
                  'type': 'role_play',
                  'scenario': 'Commander un repas',
                  'roles': ['Client', 'Serveur'],
                  'dialogue': [
                    {'role': 'Serveur', 'text': 'Bonjour, vous avez choisi ?'},
                    {'role': 'Client', 'text': 'Je voudrais...'}
                  ],
                  'image': 'assets/images/french/questions/restaurant_scene.jpg'
                },
                {
                  'type': 'menu_ordering',
                  'question': 'Composez un repas français typique',
                  'options': {
                    'entrées': ['Soupe à l\'oignon', 'Salade niçoise'],
                    'plats': ['Coq au vin', 'Boeuf bourguignon'],
                    'desserts': ['Crème brûlée', 'Tarte Tatin']
                  },
                  'images': {
                    'Soupe à l\'oignon':
                        'assets/images/french/dishes/onion_soup.jpg',
                    'Salade niçoise':
                        'assets/images/french/dishes/nicoise_salad.jpg',
                    'Coq au vin': 'assets/images/french/dishes/coq_au_vin.jpg',
                    'Boeuf bourguignon':
                        'assets/images/french/dishes/beef_bourguignon.jpg',
                    'Crème brûlée':
                        'assets/images/french/dishes/creme_brulee.jpg',
                    'Tarte Tatin': 'assets/images/french/dishes/tarte_tatin.jpg'
                  }
                }
              ]
            }
          ]
        },
        {
          'name': 'Vie quotidienne',
          'description': 'Le vocabulaire de tous les jours',
          'order': 2,
          'lessons': [
            {
              'title': 'À l\'hôtel',
              'description':
                  'Vocabulaire et expressions pour séjourner à l\'hôtel',
              'duration': '30 min',
              'xp': 80,
              'level': 'A2',
              'vocabulary_theme': {
                'title': 'Vocabulaire hôtelier',
                'words': [
                  {
                    'word': 'Réservation',
                    'translation': 'Booking',
                    'example': 'Je voudrais faire une réservation',
                    'audio': 'assets/audio/french/reservation.mp3',
                    'icon': Icons.volume_up
                  },
                  {
                    'word': 'Chambre simple',
                    'translation': 'Single room',
                    'example': 'Je voudrais une chambre simple',
                    'audio': 'assets/audio/french/chambre_simple.mp3',
                    'icon': Icons.volume_up
                  },
                  {
                    'word': 'Chambre double',
                    'translation': 'Double room',
                    'example': 'Avez-vous une chambre double ?',
                    'audio': 'assets/audio/french/chambre_double.mp3',
                    'icon': Icons.volume_up
                  },
                  {
                    'word': 'Service de chambre',
                    'translation': 'Room service',
                    'example': 'J\'aimerais commander le service de chambre',
                    'audio': 'assets/audio/french/service_chambre.mp3',
                    'icon': Icons.volume_up
                  },
                  {
                    'word': 'Petit-déjeuner',
                    'translation': 'Breakfast',
                    'example': 'Le petit-déjeuner est inclus ?',
                    'audio': 'assets/audio/french/petit_dejeuner.mp3',
                    'icon': Icons.volume_up
                  }
                ]
              },
              'dialogues': [
                {
                  'title': 'À la réception',
                  'conversation': [
                    {
                      'speaker': 'Client',
                      'text': 'Bonjour, j\'ai une réservation au nom de Martin',
                      'audio': 'assets/audio/french/hotel_dialogue1.mp3',
                      'icon': Icons.volume_up
                    },
                    {
                      'speaker': 'Réceptionniste',
                      'text':
                          'Bienvenue ! Oui, une chambre double pour 3 nuits ?',
                      'audio': 'assets/audio/french/hotel_dialogue2.mp3',
                      'icon': Icons.volume_up
                    }
                  ]
                }
              ]
            },
            {
              'title': 'Au restaurant',
              'description': 'Commander et dîner au restaurant',
              'duration': '35 min',
              'xp': 90,
              'level': 'A2',
              'vocabulary_theme': {
                'title': 'Vocabulaire de restaurant',
                'words': [
                  {
                    'word': 'Menu',
                    'translation': 'Menu',
                    'example': 'Puis-je voir le menu ?',
                    'audio': 'assets/audio/french/menu.mp3',
                    'icon': Icons.volume_up
                  },
                  {
                    'word': 'Entrée',
                    'translation': 'Starter',
                    'example': 'Comme entrée, je prendrai la soupe',
                    'audio': 'assets/audio/french/entree.mp3',
                    'icon': Icons.volume_up
                  },
                  {
                    'word': 'Plat principal',
                    'translation': 'Main course',
                    'example': 'Quel est le plat du jour ?',
                    'audio': 'assets/audio/french/plat_principal.mp3',
                    'icon': Icons.volume_up
                  },
                  {
                    'word': 'Dessert',
                    'translation': 'Dessert',
                    'example': 'Je voudrais le dessert du jour',
                    'audio': 'assets/audio/french/dessert.mp3',
                    'icon': Icons.volume_up
                  },
                  {
                    'word': 'L\'addition',
                    'translation': 'The bill',
                    'example': 'L\'addition, s\'il vous plaît',
                    'audio': 'assets/audio/french/addition.mp3',
                    'icon': Icons.volume_up
                  }
                ]
              }
            }
          ]
        },
        {
          'name': 'Transport',
          'description': 'Se déplacer en ville et en voyage',
          'order': 3,
          'lessons': [
            {
              'title': 'Les transports en commun',
              'description': 'Vocabulaire pour utiliser les transports publics',
              'duration': '25 min',
              'xp': 70,
              'level': 'A2',
              'vocabulary_theme': {
                'title': 'Vocabulaire des transports',
                'words': [
                  {
                    'word': 'Métro',
                    'translation': 'Subway',
                    'example': 'Quelle ligne de métro pour la Tour Eiffel ?',
                    'audio': 'assets/audio/french/metro.mp3',
                    'icon': Icons.volume_up
                  },
                  {
                    'word': 'Bus',
                    'translation': 'Bus',
                    'example': 'À quelle heure passe le prochain bus ?',
                    'audio': 'assets/audio/french/bus.mp3',
                    'icon': Icons.volume_up
                  },
                  {
                    'word': 'Train',
                    'translation': 'Train',
                    'example': 'Le train est à l\'heure ?',
                    'audio': 'assets/audio/french/train.mp3',
                    'icon': Icons.volume_up
                  },
                  {
                    'word': 'Billet',
                    'translation': 'Ticket',
                    'example': 'Où puis-je acheter un billet ?',
                    'audio': 'assets/audio/french/billet.mp3',
                    'icon': Icons.volume_up
                  }
                ]
              }
            }
          ]
        }
      ];

      // Ajouter les catégories à la sous-collection
      for (var category in frenchCategories) {
        await frenchRef.collection('categories').add(category);
      }

      // Anglais
      final englishRef = _firestore.collection('languages').doc('english');
      await englishRef.set({
        'name': 'English',
        'code': 'en',
        'flag': '🇬🇧',
        'description': 'Learn English',
      });

      // Créer les catégories pour l'anglais
      final englishCategories = [
        {
          'name': 'Basics',
          'description': 'Learn the fundamentals of English',
          'order': 1,
          'lessons': [
            {
              'title': 'The Alphabet',
              'description': 'Learn the English alphabet',
              'duration': '15 min',
              'xp': 50,
              'level': 'A1',
              'content': 'A, B, C, D...',
              'completed': false,
              'progress': 0.0
            }
          ]
        },
        {
          'name': 'Daily Life',
          'description': 'Everyday vocabulary',
          'order': 2,
          'lessons': [
            {
              'title': 'Greetings',
              'description': 'Learn how to greet people',
              'duration': '20 min',
              'xp': 75,
              'level': 'A1',
              'content': 'Hello, Goodbye...',
              'completed': false,
              'progress': 0.0
            }
          ]
        }
      ];

      // Ajouter les catégories à la sous-collection
      for (var category in englishCategories) {
        await englishRef.collection('categories').add(category);
      }
    } catch (e) {
      print('Erreur lors de l\'initialisation des langues: $e');
      rethrow;
    }
  }

  List<Map<String, dynamic>> _getLessonsForCategory(
      String langId, String categoryId) {
    // Définition des leçons par catégorie et par langue
    final Map<String, Map<String, List<Map<String, dynamic>>>>
        lessonsPerCategory = {
      'basics': {
        'fr': [
          {
            'id': 'greetings',
            'title': 'Les salutations',
            'duration': 15,
            'xp': 20,
            'level': 'A1',
            'content': 'Apprenez à saluer en français'
          },
          {
            'id': 'introductions',
            'title': 'Se présenter',
            'duration': 20,
            'xp': 25,
            'level': 'A1',
            'content': 'Apprenez à vous présenter en français'
          },
          {
            'id': 'numbers',
            'title': 'Les nombres et l\'alphabet',
            'duration': 25,
            'xp': 30,
            'level': 'A1',
            'content': 'Maîtrisez les nombres et l\'alphabet français'
          }
        ],
        'en': [
          {
            'id': 'greetings',
            'title': 'Greetings',
            'duration': 15,
            'xp': 20,
            'level': 'A1',
            'content': 'Learn how to greet people in English'
          },
          {
            'id': 'introductions',
            'title': 'Introducing Yourself',
            'duration': 20,
            'xp': 25,
            'level': 'A1',
            'content': 'Learn how to introduce yourself in English'
          },
          {
            'id': 'numbers',
            'title': 'Numbers and Alphabet',
            'duration': 25,
            'xp': 30,
            'level': 'A1',
            'content': 'Master English numbers and alphabet'
          }
        ],
        'ar': [
          {
            'id': 'greetings',
            'title': 'التحيات',
            'duration': 15,
            'xp': 20,
            'level': 'A1',
            'content': 'تعلم كيفية إلقاء التحية بالعربية'
          },
          {
            'id': 'introductions',
            'title': 'تقديم النفس',
            'duration': 20,
            'xp': 25,
            'level': 'A1',
            'content': 'تعلم كيفية تقديم نفسك بالعربية'
          },
          {
            'id': 'numbers',
            'title': 'الأرقام والحروف',
            'duration': 25,
            'xp': 30,
            'level': 'A1',
            'content': 'تعلم الأرقام والحروف العربية'
          }
        ],
        'it': [
          {
            'id': 'greetings',
            'title': 'I saluti',
            'duration': 15,
            'xp': 20,
            'level': 'A1',
            'content': 'Impara a salutare in italiano'
          },
          {
            'id': 'introductions',
            'title': 'Presentarsi',
            'duration': 20,
            'xp': 25,
            'level': 'A1',
            'content': 'Impara a presentarti in italiano'
          },
          {
            'id': 'numbers',
            'title': 'Numeri e alfabeto',
            'duration': 25,
            'xp': 30,
            'level': 'A1',
            'content': 'Impara i numeri e l\'alfabeto italiano'
          }
        ],
        'de': [
          {
            'id': 'greetings',
            'title': 'Begrüßungen',
            'duration': 15,
            'xp': 20,
            'level': 'A1',
            'content': 'Lernen Sie, auf Deutsch zu grüßen'
          },
          {
            'id': 'introductions',
            'title': 'Sich vorstellen',
            'duration': 20,
            'xp': 25,
            'level': 'A1',
            'content': 'Lernen Sie, sich auf Deutsch vorzustellen'
          },
          {
            'id': 'numbers',
            'title': 'Zahlen und Alphabet',
            'duration': 25,
            'xp': 30,
            'level': 'A1',
            'content': 'Lernen Sie die deutschen Zahlen und das Alphabet'
          }
        ]
      },
      'food': {
        'fr': [
          {
            'id': 'restaurant',
            'title': 'Au restaurant',
            'duration': 25,
            'xp': 30,
            'level': 'A2',
            'content': 'Commander au restaurant en français'
          },
          {
            'id': 'cuisine',
            'title': 'La cuisine française',
            'duration': 30,
            'xp': 35,
            'level': 'A2',
            'content': 'Découvrez la gastronomie française'
          },
          {
            'id': 'recipes',
            'title': 'Recettes et ingrédients',
            'duration': 35,
            'xp': 40,
            'level': 'B1',
            'content': 'Apprenez à lire et comprendre les recettes françaises'
          }
        ],
        'en': [
          {
            'id': 'restaurant',
            'title': 'At the Restaurant',
            'duration': 25,
            'xp': 30,
            'level': 'A2',
            'content': 'Order food at a restaurant in English'
          },
          {
            'id': 'cuisine',
            'title': 'British Cuisine',
            'duration': 30,
            'xp': 35,
            'level': 'A2',
            'content': 'Discover British gastronomy'
          },
          {
            'id': 'recipes',
            'title': 'Recipes and Ingredients',
            'duration': 35,
            'xp': 40,
            'level': 'B1',
            'content': 'Learn to read and understand English recipes'
          }
        ],
        'ar': [
          {
            'id': 'restaurant',
            'title': 'في المطعم',
            'duration': 25,
            'xp': 30,
            'level': 'A2',
            'content': 'تعلم كيفية الطلب في المطعم'
          },
          {
            'id': 'cuisine',
            'title': 'المطبخ العربي',
            'duration': 30,
            'xp': 35,
            'level': 'A2',
            'content': 'اكتشف المأكولات العربية التقليدية'
          },
          {
            'id': 'recipes',
            'title': 'الوصفات والمكونات',
            'duration': 35,
            'xp': 40,
            'level': 'B1',
            'content': 'تعلم قراءة وفهم الوصفات العربية'
          }
        ],
        'it': [
          {
            'id': 'restaurant',
            'title': 'Al ristorante',
            'duration': 25,
            'xp': 30,
            'level': 'A2',
            'content': 'Ordinare al ristorante in italiano'
          },
          {
            'id': 'cuisine',
            'title': 'La cucina italiana',
            'duration': 30,
            'xp': 35,
            'level': 'A2',
            'content': 'Scopri la gastronomia italiana'
          },
          {
            'id': 'recipes',
            'title': 'Ricette e ingredienti',
            'duration': 35,
            'xp': 40,
            'level': 'B1',
            'content': 'Impara a leggere e capire le ricette italiane'
          }
        ],
        'de': [
          {
            'id': 'restaurant',
            'title': 'Im Restaurant',
            'duration': 25,
            'xp': 30,
            'level': 'A2',
            'content': 'Im Restaurant bestellen'
          },
          {
            'id': 'cuisine',
            'title': 'Deutsche Küche',
            'duration': 30,
            'xp': 35,
            'level': 'A2',
            'content': 'Entdecken Sie die deutsche Küche'
          },
          {
            'id': 'recipes',
            'title': 'Rezepte und Zutaten',
            'duration': 35,
            'xp': 40,
            'level': 'B1',
            'content': 'Lernen Sie deutsche Rezepte zu lesen und zu verstehen'
          }
        ]
      },
      'culture': {
        'fr': [
          {
            'id': 'traditions',
            'title': 'Traditions françaises',
            'duration': 30,
            'xp': 35,
            'level': 'B1',
            'content': 'Découvrez les traditions françaises'
          },
          {
            'id': 'festivals',
            'title': 'Fêtes et festivals',
            'duration': 25,
            'xp': 30,
            'level': 'A2',
            'content': 'Les célébrations importantes en France'
          },
          {
            'id': 'arts',
            'title': 'Arts et littérature',
            'duration': 40,
            'xp': 45,
            'level': 'B2',
            'content': 'Explorez la culture artistique française'
          }
        ],
        'en': [
          {
            'id': 'traditions',
            'title': 'British Traditions',
            'duration': 30,
            'xp': 35,
            'level': 'B1',
            'content': 'Learn about British traditions'
          },
          {
            'id': 'festivals',
            'title': 'Festivals and Celebrations',
            'duration': 25,
            'xp': 30,
            'level': 'A2',
            'content': 'Important celebrations in British culture'
          },
          {
            'id': 'arts',
            'title': 'Arts and Literature',
            'duration': 40,
            'xp': 45,
            'level': 'B2',
            'content': 'Explore British arts and literature'
          }
        ],
        'ar': [
          {
            'id': 'traditions',
            'title': 'التقاليد العربية',
            'duration': 30,
            'xp': 35,
            'level': 'B1',
            'content': 'تعرف على التقاليد العربية'
          },
          {
            'id': 'festivals',
            'title': 'الأعياد والاحتفالات',
            'duration': 25,
            'xp': 30,
            'level': 'A2',
            'content': 'الاحتفالات المهمة في الثقافة العربية'
          },
          {
            'id': 'arts',
            'title': 'الفنون والأدب',
            'duration': 40,
            'xp': 45,
            'level': 'B2',
            'content': 'اكتشف الفنون والأدب العربي'
          }
        ],
        'it': [
          {
            'id': 'traditions',
            'title': 'Tradizioni italiane',
            'duration': 30,
            'xp': 35,
            'level': 'B1',
            'content': 'Scopri le tradizioni italiane'
          },
          {
            'id': 'festivals',
            'title': 'Feste e festival',
            'duration': 25,
            'xp': 30,
            'level': 'A2',
            'content': 'Le celebrazioni importanti in Italia'
          },
          {
            'id': 'arts',
            'title': 'Arte e letteratura',
            'duration': 40,
            'xp': 45,
            'level': 'B2',
            'content': 'Esplora l\'arte e la letteratura italiana'
          }
        ],
        'de': [
          {
            'id': 'traditions',
            'title': 'Deutsche Traditionen',
            'duration': 30,
            'xp': 35,
            'level': 'B1',
            'content': 'Lernen Sie deutsche Traditionen kennen'
          },
          {
            'id': 'festivals',
            'title': 'Feste und Festivals',
            'duration': 25,
            'xp': 30,
            'level': 'A2',
            'content': 'Wichtige Feiern in der deutschen Kultur'
          },
          {
            'id': 'arts',
            'title': 'Kunst und Literatur',
            'duration': 40,
            'xp': 45,
            'level': 'B2',
            'content': 'Entdecken Sie deutsche Kunst und Literatur'
          }
        ]
      },
      'work': {
        'fr': [
          {
            'id': 'interview',
            'title': 'Entretien d\'embauche',
            'duration': 35,
            'xp': 40,
            'level': 'B1',
            'content': 'Préparez votre entretien en français'
          },
          {
            'id': 'office',
            'title': 'Au bureau',
            'duration': 30,
            'xp': 35,
            'level': 'B1',
            'content': 'Le vocabulaire professionnel'
          },
          {
            'id': 'meetings',
            'title': 'Réunions professionnelles',
            'duration': 40,
            'xp': 45,
            'level': 'B2',
            'content': 'Participez efficacement aux réunions'
          }
        ],
        'en': [
          {
            'id': 'interview',
            'title': 'Job Interview',
            'duration': 35,
            'xp': 40,
            'level': 'B1',
            'content': 'Prepare for your job interview'
          },
          {
            'id': 'office',
            'title': 'Office Life',
            'duration': 30,
            'xp': 35,
            'level': 'B1',
            'content': 'Professional vocabulary and office communication'
          },
          {
            'id': 'meetings',
            'title': 'Business Meetings',
            'duration': 40,
            'xp': 45,
            'level': 'B2',
            'content': 'Participate effectively in meetings'
          }
        ],
        'ar': [
          {
            'id': 'interview',
            'title': 'مقابلة العمل',
            'duration': 35,
            'xp': 40,
            'level': 'B1',
            'content': 'التحضير لمقابلة العمل'
          },
          {
            'id': 'office',
            'title': 'في المكتب',
            'duration': 30,
            'xp': 35,
            'level': 'B1',
            'content': 'المفردات المهنية والتواصل في العمل'
          },
          {
            'id': 'meetings',
            'title': 'الاجتماعات المهنية',
            'duration': 40,
            'xp': 45,
            'level': 'B2',
            'content': 'المشاركة الفعالة في الاجتماعات'
          }
        ],
        'it': [
          {
            'id': 'interview',
            'title': 'Colloquio di lavoro',
            'duration': 35,
            'xp': 40,
            'level': 'B1',
            'content': 'Preparati per il tuo colloquio di lavoro'
          },
          {
            'id': 'office',
            'title': 'In ufficio',
            'duration': 30,
            'xp': 35,
            'level': 'B1',
            'content': 'Vocabolario professionale e comunicazione in ufficio'
          },
          {
            'id': 'meetings',
            'title': 'Riunioni di lavoro',
            'duration': 40,
            'xp': 45,
            'level': 'B2',
            'content': 'Partecipa efficacemente alle riunioni'
          }
        ],
        'de': [
          {
            'id': 'interview',
            'title': 'Vorstellungsgespräch',
            'duration': 35,
            'xp': 40,
            'level': 'B1',
            'content': 'Bereiten Sie sich auf Ihr Vorstellungsgespräch vor'
          },
          {
            'id': 'office',
            'title': 'Im Büro',
            'duration': 30,
            'xp': 35,
            'level': 'B1',
            'content': 'Beruflicher Wortschatz und Bürokommunikation'
          },
          {
            'id': 'meetings',
            'title': 'Geschäftsbesprechungen',
            'duration': 40,
            'xp': 45,
            'level': 'B2',
            'content': 'Nehmen Sie effektiv an Besprechungen teil'
          }
        ]
      },
      'daily_life': {
        'fr': [
          {
            'id': 'routine',
            'title': 'Routine quotidienne',
            'duration': 25,
            'xp': 30,
            'level': 'A1',
            'content': 'Apprendre à décrire sa routine quotidienne'
          },
          {
            'id': 'shopping',
            'title': 'Faire les courses',
            'duration': 30,
            'xp': 35,
            'level': 'A2',
            'content': 'Vocabulaire et expressions pour le shopping'
          },
          {
            'id': 'hobbies',
            'title': 'Loisirs et temps libre',
            'duration': 35,
            'xp': 40,
            'level': 'B1',
            'content': 'Parler de ses hobbies et activités'
          }
        ],
        'en': [
          {
            'id': 'routine',
            'title': 'Daily Routine',
            'duration': 25,
            'xp': 30,
            'level': 'A1',
            'content': 'Learn to describe your daily routine'
          },
          {
            'id': 'shopping',
            'title': 'Shopping',
            'duration': 30,
            'xp': 35,
            'level': 'A2',
            'content': 'Vocabulary and expressions for shopping'
          },
          {
            'id': 'hobbies',
            'title': 'Hobbies and Free Time',
            'duration': 35,
            'xp': 40,
            'level': 'B1',
            'content': 'Talk about your hobbies and activities'
          }
        ],
        'ar': [
          {
            'id': 'routine',
            'title': 'الروتين اليومي',
            'duration': 25,
            'xp': 30,
            'level': 'A1',
            'content': 'تعلم وصف روتينك اليومي'
          },
          {
            'id': 'shopping',
            'title': 'التسوق',
            'duration': 30,
            'xp': 35,
            'level': 'A2',
            'content': 'المفردات والتعبيرات للتسوق'
          },
          {
            'id': 'hobbies',
            'title': 'الهوايات ووقت الفراغ',
            'duration': 35,
            'xp': 40,
            'level': 'B1',
            'content': 'التحدث عن هواياتك وأنشطتك'
          }
        ],
        'it': [
          {
            'id': 'routine',
            'title': 'Routine quotidiana',
            'duration': 25,
            'xp': 30,
            'level': 'A1',
            'content': 'Imparare a descrivere la routine quotidiana'
          },
          {
            'id': 'shopping',
            'title': 'Fare la spesa',
            'duration': 30,
            'xp': 35,
            'level': 'A2',
            'content': 'Vocabolario ed espressioni per lo shopping'
          },
          {
            'id': 'hobbies',
            'title': 'Hobby e tempo libero',
            'duration': 35,
            'xp': 40,
            'level': 'B1',
            'content': 'Parlare dei tuoi hobby e attività'
          }
        ],
        'de': [
          {
            'id': 'routine',
            'title': 'Tagesablauf',
            'duration': 25,
            'xp': 30,
            'level': 'A1',
            'content': 'Lernen Sie Ihren Tagesablauf zu beschreiben'
          },
          {
            'id': 'shopping',
            'title': 'Einkaufen',
            'duration': 30,
            'xp': 35,
            'level': 'A2',
            'content': 'Vokabeln und Ausdrücke zum Einkaufen'
          },
          {
            'id': 'hobbies',
            'title': 'Hobbys und Freizeit',
            'duration': 35,
            'xp': 40,
            'level': 'B1',
            'content': 'Über Ihre Hobbys und Aktivitäten sprechen'
          }
        ]
      },
      'travel': {
        'fr': [
          {
            'id': 'transport',
            'title': 'Transports en commun',
            'duration': 30,
            'xp': 35,
            'level': 'A2',
            'content': 'Se déplacer en ville'
          },
          {
            'id': 'hotel',
            'title': 'À l\'hôtel',
            'duration': 25,
            'xp': 30,
            'level': 'A1',
            'content': 'Réserver une chambre et services'
          },
          {
            'id': 'directions',
            'title': 'Demander son chemin',
            'duration': 35,
            'xp': 40,
            'level': 'B1',
            'content': 'S\'orienter et donner des directions'
          }
        ],
        'en': [
          {
            'id': 'transport',
            'title': 'Public Transportation',
            'duration': 30,
            'xp': 35,
            'level': 'A2',
            'content': 'Getting around the city'
          },
          {
            'id': 'hotel',
            'title': 'At the Hotel',
            'duration': 25,
            'xp': 30,
            'level': 'A1',
            'content': 'Booking a room and services'
          },
          {
            'id': 'directions',
            'title': 'Asking for Directions',
            'duration': 35,
            'xp': 40,
            'level': 'B1',
            'content': 'Navigate and give directions'
          }
        ],
        'ar': [
          {
            'id': 'transport',
            'title': 'وسائل النقل العام',
            'duration': 30,
            'xp': 35,
            'level': 'A2',
            'content': 'التنقل في المدينة'
          },
          {
            'id': 'hotel',
            'title': 'في الفندق',
            'duration': 25,
            'xp': 30,
            'level': 'A1',
            'content': 'حجز غرفة والخدمات'
          },
          {
            'id': 'directions',
            'title': 'طلب الاتجاهات',
            'duration': 35,
            'xp': 40,
            'level': 'B1',
            'content': 'التنقل وإعطاء الاتجاهات'
          }
        ],
        'it': [
          {
            'id': 'transport',
            'title': 'Trasporti pubblici',
            'duration': 30,
            'xp': 35,
            'level': 'A2',
            'content': 'Muoversi in città'
          },
          {
            'id': 'hotel',
            'title': 'In albergo',
            'duration': 25,
            'xp': 30,
            'level': 'A1',
            'content': 'Prenotare una camera e servizi'
          },
          {
            'id': 'directions',
            'title': 'Chiedere indicazioni',
            'duration': 35,
            'xp': 40,
            'level': 'B1',
            'content': 'Orientarsi e dare indicazioni'
          }
        ],
        'de': [
          {
            'id': 'transport',
            'title': 'Öffentliche Verkehrsmittel',
            'duration': 30,
            'xp': 35,
            'level': 'A2',
            'content': 'In der Stadt unterwegs'
          },
          {
            'id': 'hotel',
            'title': 'Im Hotel',
            'duration': 25,
            'xp': 30,
            'level': 'A1',
            'content': 'Ein Zimmer und Services buchen'
          },
          {
            'id': 'directions',
            'title': 'Nach dem Weg fragen',
            'duration': 35,
            'xp': 40,
            'level': 'B1',
            'content': 'Sich orientieren und Wegbeschreibungen geben'
          }
        ]
      },
      'grammar': {
        'fr': [
          {
            'id': 'verbs',
            'title': 'Les verbes essentiels',
            'duration': 30,
            'xp': 35,
            'level': 'A1',
            'content': 'Conjugaison des verbes de base'
          },
          {
            'id': 'tenses',
            'title': 'Les temps verbaux',
            'duration': 35,
            'xp': 40,
            'level': 'B1',
            'content': 'Présent, passé, futur'
          },
          {
            'id': 'advanced',
            'title': 'Grammaire avancée',
            'duration': 40,
            'xp': 45,
            'level': 'B2',
            'content': 'Subjonctif et conditionnel'
          }
        ],
        'en': [
          {
            'id': 'verbs',
            'title': 'Essential Verbs',
            'duration': 30,
            'xp': 35,
            'level': 'A1',
            'content': 'Basic verb conjugation'
          },
          {
            'id': 'tenses',
            'title': 'Verb Tenses',
            'duration': 35,
            'xp': 40,
            'level': 'B1',
            'content': 'Present, past, future'
          },
          {
            'id': 'advanced',
            'title': 'Advanced Grammar',
            'duration': 40,
            'xp': 45,
            'level': 'B2',
            'content': 'Complex structures and conditionals'
          }
        ],
        'ar': [
          {
            'id': 'verbs',
            'title': 'الأفعال الأساسية',
            'duration': 30,
            'xp': 35,
            'level': 'A1',
            'content': 'تصريف الأفعال الأساسية'
          },
          {
            'id': 'tenses',
            'title': 'الأزمنة',
            'duration': 35,
            'xp': 40,
            'level': 'B1',
            'content': 'الماضي والمضارع والمستقبل'
          },
          {
            'id': 'advanced',
            'title': 'القواعد المتقدمة',
            'duration': 40,
            'xp': 45,
            'level': 'B2',
            'content': 'التراكيب المعقدة والشرط'
          }
        ],
        'it': [
          {
            'id': 'verbs',
            'title': 'Verbi essenziali',
            'duration': 30,
            'xp': 35,
            'level': 'A1',
            'content': 'Coniugazione dei verbi di base'
          },
          {
            'id': 'tenses',
            'title': 'Tempi verbali',
            'duration': 35,
            'xp': 40,
            'level': 'B1',
            'content': 'Presente, passato, futuro'
          },
          {
            'id': 'advanced',
            'title': 'Grammatica avanzata',
            'duration': 40,
            'xp': 45,
            'level': 'B2',
            'content': 'Congiuntivo e condizionale'
          }
        ],
        'de': [
          {
            'id': 'verbs',
            'title': 'Grundlegende Verben',
            'duration': 30,
            'xp': 35,
            'level': 'A1',
            'content': 'Konjugation der Grundverben'
          },
          {
            'id': 'tenses',
            'title': 'Zeitformen',
            'duration': 35,
            'xp': 40,
            'level': 'B1',
            'content': 'Präsens, Vergangenheit, Zukunft'
          },
          {
            'id': 'advanced',
            'title': 'Fortgeschrittene Grammatik',
            'duration': 40,
            'xp': 45,
            'level': 'B2',
            'content': 'Konjunktiv und Konditional'
          }
        ]
      },
      'skills': {
        'fr': [
          {
            'id': 'reading',
            'name': 'Lecture',
            'icon': 'menu_book',
            'progress': 0.0,
            'exercises': [
              {
                'id': 'read_basic',
                'title': 'Lecture de base',
                'level': 'A1',
                'xp': 20,
                'type': 'text_comprehension',
                'content': 'Un texte simple sur la vie quotidienne',
                'questions': [
                  {
                    'question': 'De quoi parle le texte ?',
                    'options': [
                      'La famille',
                      'Le travail',
                      'Les loisirs',
                      'La maison'
                    ],
                    'correct': 0
                  }
                ]
              },
              {
                'id': 'read_intermediate',
                'title': 'Lecture intermédiaire',
                'level': 'A2',
                'xp': 30,
                'type': 'text_comprehension',
                'content': 'Un article sur la culture française',
                'questions': [
                  {
                    'question': 'Quel est le thème principal ?',
                    'options': [
                      'La gastronomie',
                      'L\'art',
                      'La mode',
                      'Le cinéma'
                    ],
                    'correct': 1
                  }
                ]
              },
              {
                'id': 'read_advanced',
                'title': 'Lecture avancée',
                'level': 'B1',
                'xp': 40,
                'type': 'text_analysis',
                'content': 'Un extrait de littérature française',
                'questions': [
                  {
                    'question': 'Analysez le style de l\'auteur',
                    'type': 'open_ended'
                  }
                ]
              }
            ]
          },
          {
            'id': 'writing',
            'name': 'Écriture',
            'icon': 'edit',
            'progress': 0.0,
            'exercises': [
              {
                'id': 'write_basic',
                'title': 'Écriture de base',
                'level': 'A1',
                'xp': 20,
                'type': 'sentence_completion',
                'prompts': ['Je m\'appelle...', 'J\'habite à...', 'J\'aime...']
              },
              {
                'id': 'write_intermediate',
                'title': 'Écriture intermédiaire',
                'level': 'A2',
                'xp': 30,
                'type': 'short_essay',
                'prompt': 'Décrivez votre journée type',
                'minWords': 50,
                'maxWords': 100
              },
              {
                'id': 'write_advanced',
                'title': 'Écriture avancée',
                'level': 'B1',
                'xp': 40,
                'type': 'essay',
                'prompt': 'Rédigez un article d\'opinion',
                'minWords': 150,
                'maxWords': 300
              }
            ]
          },
          {
            'id': 'listening',
            'name': 'Écoute',
            'icon': 'headphones',
            'progress': 0.0,
            'exercises': [
              {
                'id': 'listen_basic',
                'title': 'Écoute de base',
                'level': 'A1',
                'xp': 20,
                'type': 'audio_comprehension',
                'audioUrl': 'basic_dialogue.mp3',
                'questions': [
                  {
                    'question': 'Que disent les personnages ?',
                    'options': [
                      'Bonjour',
                      'Au revoir',
                      'Merci',
                      'S\'il vous plaît'
                    ],
                    'correct': 0
                  }
                ]
              },
              {
                'id': 'listen_intermediate',
                'title': 'Écoute intermédiaire',
                'level': 'A2',
                'xp': 30,
                'type': 'audio_dictation',
                'audioUrl': 'intermediate_dialogue.mp3',
                'transcript': 'Transcription du dialogue'
              },
              {
                'id': 'listen_advanced',
                'title': 'Écoute avancée',
                'level': 'B1',
                'xp': 40,
                'type': 'audio_analysis',
                'audioUrl': 'advanced_dialogue.mp3',
                'tasks': [
                  'Identifiez les accents régionaux',
                  'Repérez les expressions idiomatiques',
                  'Analysez le registre de langue'
                ]
              }
            ]
          },
          {
            'id': 'speaking',
            'name': 'Expression orale',
            'icon': 'mic',
            'progress': 0.0,
            'exercises': [
              {
                'id': 'speak_basic',
                'title': 'Expression orale de base',
                'level': 'A1',
                'xp': 20,
                'type': 'pronunciation',
                'words': ['Bonjour', 'Merci', 'Au revoir'],
                'phonetics': ['bɔ̃.ʒuʁ', 'mɛʁ.si', 'o.ʁə.vwaʁ']
              },
              {
                'id': 'speak_intermediate',
                'title': 'Expression orale intermédiaire',
                'level': 'A2',
                'xp': 30,
                'type': 'dialogue_simulation',
                'scenarios': ['Au restaurant', 'À la gare', 'Dans un magasin']
              },
              {
                'id': 'speak_advanced',
                'title': 'Expression orale avancée',
                'level': 'B1',
                'xp': 40,
                'type': 'presentation',
                'topics': [
                  'Votre ville natale',
                  'Un sujet d\'actualité',
                  'Votre passion'
                ],
                'duration': '3-5 minutes'
              }
            ]
          }
        ],
        'en': [
          {
            'id': 'reading',
            'name': 'Reading',
            'icon': 'menu_book',
            'progress': 0.0,
            'exercises': [
              {
                'id': 'read_basic',
                'title': 'Basic Reading',
                'level': 'A1',
                'xp': 20
              },
              {
                'id': 'read_intermediate',
                'title': 'Intermediate Reading',
                'level': 'A2',
                'xp': 30
              }
            ]
          },
          {
            'id': 'writing',
            'name': 'Writing',
            'icon': 'edit',
            'progress': 0.0,
            'exercises': [
              {
                'id': 'write_basic',
                'title': 'Basic Writing',
                'level': 'A1',
                'xp': 20
              },
              {
                'id': 'write_intermediate',
                'title': 'Intermediate Writing',
                'level': 'A2',
                'xp': 30
              }
            ]
          },
          {
            'id': 'listening',
            'name': 'Listening',
            'icon': 'headphones',
            'progress': 0.0,
            'exercises': [
              {
                'id': 'listen_basic',
                'title': 'Basic Listening',
                'level': 'A1',
                'xp': 20
              },
              {
                'id': 'listen_intermediate',
                'title': 'Intermediate Listening',
                'level': 'A2',
                'xp': 30
              }
            ]
          },
          {
            'id': 'speaking',
            'name': 'Speaking',
            'icon': 'mic',
            'progress': 0.0,
            'exercises': [
              {
                'id': 'speak_basic',
                'title': 'Basic Speaking',
                'level': 'A1',
                'xp': 20
              },
              {
                'id': 'speak_intermediate',
                'title': 'Intermediate Speaking',
                'level': 'A2',
                'xp': 30
              }
            ]
          }
        ],
        'ar': [
          {
            'id': 'reading',
            'name': 'القراءة',
            'icon': 'menu_book',
            'progress': 0.0,
            'exercises': [
              {
                'id': 'read_basic',
                'title': 'القراءة الأساسية',
                'level': 'A1',
                'xp': 20
              },
              {
                'id': 'read_intermediate',
                'title': 'القراءة المتوسطة',
                'level': 'A2',
                'xp': 30
              }
            ]
          },
          {
            'id': 'writing',
            'name': 'الكتابة',
            'icon': 'edit',
            'progress': 0.0,
            'exercises': [
              {
                'id': 'write_basic',
                'title': 'الكتابة الأساسية',
                'level': 'A1',
                'xp': 20
              },
              {
                'id': 'write_intermediate',
                'title': 'الكتابة المتوسطة',
                'level': 'A2',
                'xp': 30
              }
            ]
          },
          {
            'id': 'listening',
            'name': 'الاستماع',
            'icon': 'headphones',
            'progress': 0.0,
            'exercises': [
              {
                'id': 'listen_basic',
                'title': 'الاستماع الأساسي',
                'level': 'A1',
                'xp': 20
              },
              {
                'id': 'listen_intermediate',
                'title': 'الاستماع المتوسط',
                'level': 'A2',
                'xp': 30
              }
            ]
          },
          {
            'id': 'speaking',
            'name': 'التحدث',
            'icon': 'mic',
            'progress': 0.0,
            'exercises': [
              {
                'id': 'speak_basic',
                'title': 'التحدث الأساسي',
                'level': 'A1',
                'xp': 20
              },
              {
                'id': 'speak_intermediate',
                'title': 'التحدث المتوسط',
                'level': 'A2',
                'xp': 30
              }
            ]
          }
        ],
        'it': [
          {
            'id': 'reading',
            'name': 'Lettura',
            'icon': 'menu_book',
            'progress': 0.0,
            'exercises': [
              {
                'id': 'read_basic',
                'title': 'Lettura base',
                'level': 'A1',
                'xp': 20
              },
              {
                'id': 'read_intermediate',
                'title': 'Lettura intermedia',
                'level': 'A2',
                'xp': 30
              }
            ]
          },
          {
            'id': 'writing',
            'name': 'Scrittura',
            'icon': 'edit',
            'progress': 0.0,
            'exercises': [
              {
                'id': 'write_basic',
                'title': 'Scrittura base',
                'level': 'A1',
                'xp': 20
              },
              {
                'id': 'write_intermediate',
                'title': 'Scrittura intermedia',
                'level': 'A2',
                'xp': 30
              }
            ]
          },
          {
            'id': 'listening',
            'name': 'Ascolto',
            'icon': 'headphones',
            'progress': 0.0,
            'exercises': [
              {
                'id': 'listen_basic',
                'title': 'Ascolto base',
                'level': 'A1',
                'xp': 20
              },
              {
                'id': 'listen_intermediate',
                'title': 'Ascolto intermedio',
                'level': 'A2',
                'xp': 30
              }
            ]
          },
          {
            'id': 'speaking',
            'name': 'Conversazione',
            'icon': 'mic',
            'progress': 0.0,
            'exercises': [
              {
                'id': 'speak_basic',
                'title': 'Conversazione base',
                'level': 'A1',
                'xp': 20
              },
              {
                'id': 'speak_intermediate',
                'title': 'Conversazione intermedia',
                'level': 'A2',
                'xp': 30
              }
            ]
          }
        ],
        'de': [
          {
            'id': 'reading',
            'name': 'Lesen',
            'icon': 'menu_book',
            'progress': 0.0,
            'exercises': [
              {
                'id': 'read_basic',
                'title': 'Grundlegendes Lesen',
                'level': 'A1',
                'xp': 20
              },
              {
                'id': 'read_intermediate',
                'title': 'Mittelstufe Lesen',
                'level': 'A2',
                'xp': 30
              }
            ]
          },
          {
            'id': 'writing',
            'name': 'Schreiben',
            'icon': 'edit',
            'progress': 0.0,
            'exercises': [
              {
                'id': 'write_basic',
                'title': 'Grundlegendes Schreiben',
                'level': 'A1',
                'xp': 20
              },
              {
                'id': 'write_intermediate',
                'title': 'Mittelstufe Schreiben',
                'level': 'A2',
                'xp': 30
              }
            ]
          },
          {
            'id': 'listening',
            'name': 'Hören',
            'icon': 'headphones',
            'progress': 0.0,
            'exercises': [
              {
                'id': 'listen_basic',
                'title': 'Grundlegendes Hören',
                'level': 'A1',
                'xp': 20
              },
              {
                'id': 'listen_intermediate',
                'title': 'Mittelstufe Hören',
                'level': 'A2',
                'xp': 30
              }
            ]
          },
          {
            'id': 'speaking',
            'name': 'Sprechen',
            'icon': 'mic',
            'progress': 0.0,
            'exercises': [
              {
                'id': 'speak_basic',
                'title': 'Grundlegendes Sprechen',
                'level': 'A1',
                'xp': 20
              },
              {
                'id': 'speak_intermediate',
                'title': 'Mittelstufe Sprechen',
                'level': 'A2',
                'xp': 30
              }
            ]
          }
        ]
      }
    };

    // Si la langue ou la catégorie n'existe pas, retourner une liste vide
    if (!lessonsPerCategory.containsKey(categoryId) ||
        !lessonsPerCategory[categoryId]!.containsKey(langId)) {
      return [];
    }

    return lessonsPerCategory[categoryId]![langId]!;
  }

  // Mettre à jour une langue
  Future<void> updateLanguage(
      String languageId, Map<String, dynamic> data) async {
    await _firestore.collection('languages').doc(languageId).update(data);
  }

  // Supprimer une langue
  Future<void> deleteLanguage(String languageId) async {
    await _firestore.collection('languages').doc(languageId).delete();
  }

  Future<List<Map<String, dynamic>>> getThemes(String languageId) async {
    final themesSnapshot = await _firestore
        .collection('languages')
        .doc(languageId)
        .collection('themes')
        .get();
    return themesSnapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> getSkills(String languageId) async {
    final snapshot = await _firestore
        .collection('languages')
        .doc(languageId)
        .collection('skills')
        .get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  // Méthodes pour les langues
  Stream<DocumentSnapshot> getLanguageStream(String languageId) {
    return _firestore.collection('languages').doc(languageId).snapshots();
  }

  // Méthodes pour les thèmes
  Stream<QuerySnapshot> getThemesStream(String languageId) {
    return _firestore
        .collection('languages')
        .doc(languageId)
        .collection('themes')
        .orderBy('order')
        .snapshots();
  }

  Future<void> updateThemeProgress(
      String languageId, String themeId, double progress) {
    return _firestore
        .collection('languages')
        .doc(languageId)
        .collection('themes')
        .doc(themeId)
        .update({'progress': progress});
  }

  // Méthodes pour les compétences
  Stream<QuerySnapshot> getSkillsStream(String languageId) {
    return _firestore
        .collection('languages')
        .doc(languageId)
        .collection('skills')
        .orderBy('order')
        .snapshots();
  }

  Future<void> updateSkillProgress(
      String languageId, String skillId, double progress) {
    return _firestore
        .collection('languages')
        .doc(languageId)
        .collection('skills')
        .doc(skillId)
        .update({'progress': progress});
  }

  // Méthode d'initialisation des données (à utiliser une seule fois)
  Future<void> initializeLanguageData(
      String languageId, Map<String, dynamic> languageData) async {
    final languageRef = _firestore.collection('languages').doc(languageId);

    // Créer ou mettre à jour la langue
    await languageRef.set(languageData);

    // Initialiser les thèmes par défaut
    final themesCollection = languageRef.collection('themes');
    final defaultThemes = [
      {
        'title': 'Bases',
        'description': 'Apprenez les fondamentaux',
        'iconCodePoint': 0xe88e, // school
        'order': 0,
        'progress': 0.0,
      },
      {
        'title': 'Vie quotidienne',
        'description': 'Conversations de tous les jours',
        'iconCodePoint': 0xe7fb, // people
        'order': 1,
        'progress': 0.0,
      },
      {
        'title': 'Culture',
        'description': 'Découvrez la culture',
        'iconCodePoint': 0xe55b, // museum
        'order': 2,
        'progress': 0.0,
      },
    ];

    for (final theme in defaultThemes) {
      await themesCollection.add(theme);
    }

    // Initialiser les compétences par défaut
    final skillsCollection = languageRef.collection('skills');
    final defaultSkills = [
      {
        'name': 'Écoute',
        'iconCodePoint': 0xe3a1, // headphones
        'order': 0,
        'progress': 0.0,
      },
      {
        'name': 'Lecture',
        'iconCodePoint': 0xe865, // book
        'order': 1,
        'progress': 0.0,
      },
      {
        'name': 'Écriture',
        'iconCodePoint': 0xe3c9, // edit
        'order': 2,
        'progress': 0.0,
      },
      {
        'name': 'Prononciation',
        'iconCodePoint': 0xe029, // mic
        'order': 3,
        'progress': 0.0,
      },
    ];

    for (final skill in defaultSkills) {
      await skillsCollection.add(skill);
    }
  }
}
