# EchoLang - Application d'Apprentissage des Langues

## 📱 Description

EchoLang est une application moderne d'apprentissage des langues qui combine l'intelligence artificielle, la gamification et des méthodes pédagogiques éprouvées pour offrir une expérience d'apprentissage personnalisée et efficace.

## ✨ Fonctionnalités Principales

### 🎯 Apprentissage Personnalisé

- Parcours adaptatif basé sur votre niveau
- Test de niveau initial
- Suivi de progression détaillé
- Objectifs quotidiens personnalisés

### 🎮 Mini-Jeux Éducatifs

- **Quiz Rapide** : Testez vos connaissances
- **Mots Mêlés** : Trouvez les mots cachés par thème
- **Phrases à Trous** : Complétez les phrases
- **Course aux Mots** : Améliorez votre vitesse de frappe
- **Images et Mots** : Apprenez le vocabulaire avec des photos
- **Mots Croisés** : Résolvez des grilles thématiques
- **Bataille de Verbes** : Pratiquez la conjugaison
- **Memory** : Associez les mots et leurs traductions

### 🤖 Fonctionnalités Innovantes

- **ChatBot** : Assistant linguistique intelligent
- **Traduction par Caméra** : Traduisez du texte en temps réel
- **Reconnaissance Vocale** : Pratiquez votre prononciation
- **Podcasts** : Écoutez et apprenez

### 📚 Contenu Pédagogique

- Leçons structurées par niveau (A1 à C2)
- Exercices de grammaire
- Vocabulaire thématique
- Dialogues interactifs

## 🛠️ Installation

### Prérequis

- Flutter SDK (version ^3.6.1)
- Dart SDK
- Android Studio / Xcode
- Git

### Étapes d'Installation

1. Clonez le repository :

```bash
git clone [URL_DU_REPO]
cd projectflutter
```

2. Installez les dépendances :

```bash
flutter pub get
```

3. Configurez Firebase :

- Créez un projet Firebase
- Ajoutez votre fichier `google-services.json` dans `android/app/`
- Ajoutez votre fichier `GoogleService-Info.plist` pour iOS

4. Lancez l'application :

```bash
flutter run
```

## 📦 Dépendances Principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  camera: ^0.10.5+9
  image_picker: ^1.0.7
  google_mlkit_text_recognition: ^0.11.0
  translator: ^1.0.3+1
```

## 🎨 Architecture

L'application suit une architecture propre avec :

- Services pour la logique métier
- Widgets réutilisables
- Gestion d'état avec Provider
- Base de données Firebase
- Stockage local avec SharedPreferences

## 📱 Captures d'écran

[À ajouter : captures d'écran des principales fonctionnalités]

## 🔒 Sécurité

- Authentification sécurisée avec Firebase
- Stockage sécurisé des données utilisateur
- Protection des API keys
- Validation des entrées utilisateur

## 🙏 Remerciements

Un grand merci à moi !
