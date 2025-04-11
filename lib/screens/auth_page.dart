import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/user_service.dart';
import 'home_screen.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with WidgetsBindingObserver {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final UserService _userService = UserService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _message = "Préparation de l'authentification...";
  bool _showForm = false;
  String _firstName = '';
  String _lastName = '';
  String? _deviceId;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Démarrer l'authentification après le premier frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndStartAuth();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_isAuthenticating) {
      _checkAndStartAuth();
    }
  }

  Future<void> _checkAndStartAuth() async {
    if (_isAuthenticating || !mounted) return;

    setState(() {
      _isLoading = true;
      _message = "Vérification du système...";
    });

    try {
      // Vérifier si l'authentification biométrique est disponible
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        throw PlatformException(
            code: 'NotSupported',
            message: "L'authentification biométrique n'est pas disponible");
      }

      // Vérifier les types de biométrie disponibles
      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();

      if (availableBiometrics.isEmpty) {
        throw PlatformException(
            code: 'NoBiometrics',
            message: "Aucune donnée biométrique n'est enregistrée");
      }

      // Lancer l'authentification
      _startAuthentication(availableBiometrics);
    } catch (e) {
      _handleError(e.toString());
    }
  }

  Future<void> _startAuthentication(
      List<BiometricType> availableBiometrics) async {
    if (!mounted) return;

    setState(() {
      _isAuthenticating = true;
      _message = "Placez votre doigt sur le capteur...";
    });

    try {
      final bool authenticated = await _localAuth.authenticate(
        localizedReason: availableBiometrics.contains(BiometricType.face)
            ? 'Utilisez Face ID pour vous connecter'
            : 'Scannez votre empreinte pour vous connecter',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );

      if (!mounted) return;

      if (authenticated) {
        await _handleSuccessfulAuth();
      } else {
        _handleError("Authentification échouée");
      }
    } on PlatformException catch (e) {
      String message = "Erreur d'authentification";
      switch (e.code) {
        case 'NotEnrolled':
          message =
              "Veuillez configurer vos données biométriques dans les paramètres";
          break;
        case 'LockedOut':
          message = "Trop de tentatives, réessayez plus tard";
          break;
        case 'PermanentlyLockedOut':
          message =
              "Appareil verrouillé. Déverrouillez-le avec votre mot de passe";
          break;
        default:
          message = e.message ?? "Une erreur s'est produite";
      }
      _handleError(message);
    } catch (e) {
      _handleError("Une erreur inattendue s'est produite");
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSuccessfulAuth() async {
    setState(() {
      _isLoading = true;
      _message = "Vérification de l'utilisateur...";
    });

    try {
      // Obtenir la liste des empreintes disponibles
      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        throw Exception("Aucune empreinte enregistrée");
      }

      // Utiliser la première empreinte comme deviceId
      _deviceId = availableBiometrics.first.toString();

      // Vérifier si l'utilisateur existe dans Firestore
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('deviceId', isEqualTo: _deviceId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Utilisateur trouvé, récupérer ses données
        final userData = querySnapshot.docs.first.data();

        if (!mounted) return;

        // Mettre à jour la dernière connexion
        await FirebaseFirestore.instance
            .collection('users')
            .doc(querySnapshot.docs.first.id)
            .update({'lastLogin': FieldValue.serverTimestamp()});

        // Rediriger vers l'écran d'accueil
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              firstName: userData['firstName'],
              lastName: userData['lastName'],
            ),
          ),
        );
      } else {
        // Aucun utilisateur trouvé, afficher le formulaire d'enregistrement
        if (!mounted) return;
        setState(() {
          _message = "Authentification réussie! Veuillez vous enregistrer.";
          _showForm = true;
        });
      }
    } catch (e) {
      _handleError("Erreur lors de la vérification: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleError(String error) {
    if (!mounted) return;
    setState(() {
      _message = error;
      _showForm = false;
      _isLoading = false;
      _isAuthenticating = false;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _deviceId == null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _message = "Enregistrement en cours...";
    });

    try {
      // Sauvegarder les valeurs du formulaire
      _formKey.currentState!.save();

      // Vérifier que les champs ne sont pas vides après le trim
      final String firstName = _firstName.trim();
      final String lastName = _lastName.trim();

      if (firstName.isEmpty || lastName.isEmpty) {
        throw Exception("Le prénom et le nom ne peuvent pas être vides");
      }

      // Créer le document utilisateur dans Firestore
      await FirebaseFirestore.instance.collection('users').doc(_deviceId).set({
        'firstName': firstName,
        'lastName': lastName,
        'deviceId': _deviceId,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // Rediriger vers la page d'accueil
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            firstName: firstName,
            lastName: lastName,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _message = "Erreur: ${e.toString()}";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _retryAuthentication() async {
    setState(() {
      _isLoading = false;
      _showForm = false;
      _message = "Veuillez vous authentifier";
    });
    await _checkAndStartAuth();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final safeArea = MediaQuery.of(context).padding;
    final availableHeight = size.height - safeArea.top - safeArea.bottom;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade400,
              Colors.blue.shade800,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: availableHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: availableHeight * 0.05),

                    // Logo et titre
                    Container(
                      height: 120,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Pointage App",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Bienvenue",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white.withOpacity(0.9),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: availableHeight * 0.08),

                    // Icône d'empreinte animée
                    Hero(
                      tag: 'fingerprint_icon',
                      child: GestureDetector(
                        onTap: _isLoading ? null : _retryAuthentication,
                        child: Container(
                          height: 160,
                          width: 160,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _isLoading
                                ? Colors.grey.shade300
                                : Colors.white,
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: _isLoading
                                ? const Center(
                                    child: SizedBox(
                                      height: 80,
                                      width: 80,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.blue),
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.fingerprint,
                                    size: 80,
                                    color: Colors.blue,
                                  ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: availableHeight * 0.06),

                    // Message d'état
                    Container(
                      constraints: const BoxConstraints(
                        minHeight: 60,
                        maxWidth: 300,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          _message,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    // Formulaire avec animation
                    if (_showForm) ...[
                      SizedBox(height: availableHeight * 0.06),
                      AnimatedOpacity(
                        opacity: _showForm ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 500),
                        child: Container(
                          constraints: BoxConstraints(
                            maxHeight: availableHeight * 0.6,
                            maxWidth: 400,
                          ),
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      "Inscription",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade800,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      height: 56,
                                      child: TextFormField(
                                        decoration: const InputDecoration(
                                          labelText: 'Prénom',
                                          prefixIcon: Icon(Icons.person),
                                        ),
                                        textCapitalization:
                                            TextCapitalization.words,
                                        onChanged: (value) =>
                                            _firstName = value,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Veuillez entrer votre prénom';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) =>
                                            _firstName = value?.trim() ?? '',
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      height: 56,
                                      child: TextFormField(
                                        decoration: const InputDecoration(
                                          labelText: 'Nom',
                                          prefixIcon:
                                              Icon(Icons.person_outline),
                                        ),
                                        textCapitalization:
                                            TextCapitalization.words,
                                        onChanged: (value) => _lastName = value,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Veuillez entrer votre nom';
                                          }
                                          return null;
                                        },
                                        onSaved: (value) =>
                                            _lastName = value?.trim() ?? '',
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    SizedBox(
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed:
                                            _isLoading ? null : _submitForm,
                                        child: _isLoading
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.white),
                                                ),
                                              )
                                            : const Text(
                                                'Enregistrer',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    SizedBox(
                                      height: 40,
                                      child: TextButton(
                                        onPressed: _isLoading
                                            ? null
                                            : _retryAuthentication,
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.blue.shade700,
                                        ),
                                        child: const Text(
                                          'Réessayer l\'authentification',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
