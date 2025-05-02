import 'dart:math';

class PhraseOfDayService {
  static final List<Map<String, String>> _phrases = [
    {
      'phrase': 'The early bird catches the worm',
      'meaning': 'Celui qui se lève tôt accomplit plus de choses',
    },
    {
      'phrase': 'Practice makes perfect',
      'meaning': 'C\'est en forgeant qu\'on devient forgeron',
    },
    {
      'phrase': 'Actions speak louder than words',
      'meaning': 'Les actes valent mieux que les paroles',
    },
    {
      'phrase': 'Time is money',
      'meaning': 'Le temps, c\'est de l\'argent',
    },
    {
      'phrase': 'Better late than never',
      'meaning': 'Mieux vaut tard que jamais',
    },
    {
      'phrase': 'Knowledge is power',
      'meaning': 'Le savoir, c\'est le pouvoir',
    },
    {
      'phrase': 'Where there\'s a will, there\'s a way',
      'meaning': 'Quand on veut, on peut',
    },
    {
      'phrase': 'Every cloud has a silver lining',
      'meaning': 'Après la pluie vient le beau temps',
    },
  ];

  static Map<String, String> getRandomPhrase() {
    final random = Random();
    return _phrases[random.nextInt(_phrases.length)];
  }
}
