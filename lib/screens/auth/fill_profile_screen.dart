import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/services/auth_service.dart';
import 'package:deme_mali_app/core/theme/app_colors.dart';
import 'package:deme_mali_app/screens/auth/beneficiary_situation_screen.dart';
import 'package:deme_mali_app/widgets/deme_components.dart';

/// ============================================================================
/// Écran : Inscription Bénéficiaire Particulier (Étape 1 sur 2)
/// Conforme à la maquette Figma "Inscription particulier.png"
/// ============================================================================
class FillProfileScreen extends StatefulWidget {
  const FillProfileScreen({super.key});

  @override
  State<FillProfileScreen> createState() => _FillProfileScreenState();
}

class _FillProfileScreenState extends State<FillProfileScreen> {
  final TextEditingController _nomController = TextEditingController(text: UserSession.currentUserNom ?? '');
  final TextEditingController _prenomController = TextEditingController(text: UserSession.currentUserPrenom ?? '');
  final TextEditingController _adresseController = TextEditingController(text: UserSession.currentUserAddress ?? '');
  final TextEditingController _villeController = TextEditingController(text: UserSession.currentUserCity ?? 'Bamako');
  final TextEditingController _phoneController = TextEditingController(text: UserSession.currentUserPhone ?? '');
  final TextEditingController _passwordController = TextEditingController(text: UserSession.tempPassword ?? '');

  String _selectedGenre = UserSession.currentUserGender ?? 'Masculin';
  bool _obscurePassword = true;

  final List<String> _genres = ['Féminin', 'Masculin'];

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _adresseController.dispose();
    _villeController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onNext() {
    final nom = _nomController.text.trim();
    final prenom = _prenomController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (nom.isEmpty || prenom.isEmpty || phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir les champs obligatoires (Nom, Prénom, Téléphone, Mot de passe).'),
          backgroundColor: AppColors.orange,
        ),
      );
      return;
    }

    // Sauvegarde temporaire dans UserSession
    UserSession.currentUserNom = nom;
    UserSession.currentUserPrenom = prenom;
    UserSession.currentUserName = '$prenom $nom'.trim();
    UserSession.currentUserGender = _selectedGenre;
    UserSession.currentUserAddress = _adresseController.text.trim();
    UserSession.currentUserCity = _villeController.text.trim();
    UserSession.currentUserPhone = phone;
    UserSession.tempPassword = password;
    UserSession.currentUserRole = 'Bénéficiaire';

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BeneficiarySituationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Entête avec Stepper (1 sur 2)
              const DemeStepperHeader(currentStep: 1, totalSteps: 2),
              const SizedBox(height: 28),

              // 2. Titre et description
              const Text(
                'Informations personnelles',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.texte,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Veuillez renseigner vos données de base pour démarrer l\'enregistrement.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.texteSecondaire,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // 3. Champs du formulaire
              DemeTextField(
                label: 'Nom',
                hintText: 'Entrez votre nom',
                controller: _nomController,
              ),
              const SizedBox(height: 16),

              DemeTextField(
                label: 'Prénom',
                hintText: 'Entrez votre prénom',
                controller: _prenomController,
              ),
              const SizedBox(height: 16),

              DemeDropdownField<String>(
                label: 'Genre',
                value: _selectedGenre,
                items: _genres.map((g) {
                  return DropdownMenuItem(value: g, child: Text(g));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedGenre = val);
                },
              ),
              const SizedBox(height: 16),

              DemeTextField(
                label: 'Adresse',
                hintText: 'Ex: Quartier du Fleuve, Rue 110',
                controller: _adresseController,
              ),
              const SizedBox(height: 16),

              DemeTextField(
                label: 'Ville',
                hintText: 'Ex: Bamako',
                controller: _villeController,
              ),
              const SizedBox(height: 16),

              DemeTextField(
                label: 'Numéro de téléphone',
                hintText: 'Ex: 67 89 09 78',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              DemeTextField(
                label: 'Mot de passe',
                hintText: '••••',
                controller: _passwordController,
                isPassword: true,
                obscureText: _obscurePassword,
                onTogglePassword: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              const SizedBox(height: 36),

              // 4. Barre d'action inférieure
              DemeBottomButtons(
                onBack: () => Navigator.pop(context),
                onNext: _onNext,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
