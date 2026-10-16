import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/services/auth_service.dart';
import 'package:deme_mali_app/core/theme/app_colors.dart';
import 'package:deme_mali_app/screens/beneficiaire/dashboard_screen.dart';
import 'package:deme_mali_app/screens/auth/login_screen.dart';
import 'package:deme_mali_app/widgets/deme_components.dart';

/// ============================================================================
/// Écran : Inscription Bénéficiaire Structure - Étape 3 (Créer votre compte)
/// Conforme à la maquette Figma "creation-compte.png"
/// ============================================================================
class CreateAccountStep3Screen extends StatefulWidget {
  final bool isStructure;

  const CreateAccountStep3Screen({
    super.key,
    this.isStructure = true,
  });

  @override
  State<CreateAccountStep3Screen> createState() =>
      _CreateAccountStep3ScreenState();
}

class _CreateAccountStep3ScreenState extends State<CreateAccountStep3Screen> {
  final TextEditingController _nomController =
      TextEditingController(text: UserSession.currentUserNom ?? '');
  final TextEditingController _prenomController =
      TextEditingController(text: UserSession.currentUserPrenom ?? '');
  final TextEditingController _phoneController =
      TextEditingController(text: UserSession.currentUserPhone ?? '');
  final TextEditingController _passwordController =
      TextEditingController(text: UserSession.tempPassword ?? '');

  final AuthService _authService = AuthService();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRegister() async {
    final nom = _nomController.text.trim();
    final prenom = _prenomController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (nom.isEmpty || prenom.isEmpty || phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez renseigner tous les champs.'),
          backgroundColor: AppColors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    UserSession.currentUserNom = nom;
    UserSession.currentUserPrenom = prenom;
    UserSession.currentUserName = '$prenom $nom'.trim();
    UserSession.currentUserPhone = phone;
    UserSession.tempPassword = password;

    Map<String, dynamic> result;

    if (widget.isStructure) {
      final dto = {
        'nomStructure': UserSession.currentUserNomStructure ?? nom,
        'typeStructure': UserSession.currentUserTypeBeneficiaire ?? 'ECOLE',
        'nif': UserSession.currentUserNif ?? '',
        'ville': UserSession.currentUserCity ?? 'Bamako',
        'adresse': UserSession.currentUserAddress ?? 'Bamako',
        'email': UserSession.currentUserEmail ?? '$phone@dememali.ml',
        'telephone': phone,
        'motDePasse': password,
        'nomResponsable': nom,
        'prenomResponsable': prenom,
      };
      result = await _authService.registerBeneficiaireStructure(dto);
    } else {
      final dto = {
        'nom': nom,
        'prenom': prenom,
        'telephone': phone,
        'motDePasse': password,
        'email': UserSession.currentUserEmail ?? '$phone@dememali.ml',
        'adresse': UserSession.currentUserAddress ?? 'Bamako',
        'ville': UserSession.currentUserCity ?? 'Bamako',
      };
      result = await _authService.registerBeneficiaireParticulier(dto);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      UserSession.currentUserRole = 'Bénéficiaire';
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compte créé avec succès ! Bienvenue.'),
          backgroundColor: AppColors.vert,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Inscription : ${result['message']}'),
          backgroundColor: Colors.redAccent,
          action: SnackBarAction(
            label: 'Continuer',
            textColor: Colors.white,
            onPressed: () {
              UserSession.currentUserRole = 'Bénéficiaire';
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
                (route) => false,
              );
            },
          ),
        ),
      );
    }
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
              // 1. Stepper Header (3 sur 3)
              const DemeStepperHeader(currentStep: 3, totalSteps: 3),
              const SizedBox(height: 28),

              // 2. Titre et description
              const Text(
                'Créer votre compte',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.texte,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Créez vos identifiants pour accéder à votre espace structure.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.texteSecondaire,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // 3. Nom
              DemeTextField(
                label: 'Nom',
                hintText: 'Entrez votre nom',
                controller: _nomController,
              ),
              const SizedBox(height: 16),

              // 4. Prénom
              DemeTextField(
                label: 'Prenom',
                hintText: 'Entrez votre prenom',
                controller: _prenomController,
              ),
              const SizedBox(height: 16),

              // 5. Téléphone
              DemeTextField(
                label: 'Numéro de téléphone',
                hintText: 'Exemple : +223 70 00 00 00',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // 6. Mot de passe
              DemeTextField(
                label: 'Mot de passe',
                hintText: 'Entrez votre mot de passe',
                controller: _passwordController,
                isPassword: true,
                obscureText: _obscurePassword,
                onTogglePassword: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              const SizedBox(height: 36),

              // 7. Boutons Retour / Enregistrer
              DemeBottomButtons(
                onBack: () => Navigator.pop(context),
                nextText: 'Enregistrer',
                isNextLoading: _isLoading,
                onNext: _onRegister,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
