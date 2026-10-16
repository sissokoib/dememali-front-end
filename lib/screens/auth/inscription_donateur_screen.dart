import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/services/auth_service.dart';
import 'package:deme_mali_app/core/theme/app_colors.dart';
import 'package:deme_mali_app/screens/donateur/donateur_dashboard_screen.dart';
import 'package:deme_mali_app/widgets/deme_components.dart';

/// ============================================================================
/// Écran : Inscription DONATEUR (Particulier ou Organisation)
/// ============================================================================
class InscriptionDonateurScreen extends StatefulWidget {
  final bool initialIsOrganisation;

  const InscriptionDonateurScreen({
    super.key,
    this.initialIsOrganisation = false,
  });

  @override
  State<InscriptionDonateurScreen> createState() =>
      _InscriptionDonateurScreenState();
}

class _InscriptionDonateurScreenState extends State<InscriptionDonateurScreen> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cityController =
      TextEditingController(text: 'Bamako');
  final TextEditingController _passwordController = TextEditingController();

  late String _selectedType;
  bool _obscurePassword = true;
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  final List<String> _donorTypes = [
    'Particulier',
    'Entreprise / Organisation',
    'Diaspora solidaire',
    'Association / Fondation',
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialIsOrganisation
        ? 'Entreprise / Organisation'
        : 'Particulier';
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRegister() async {
    final nom = _nomController.text.trim();
    final prenom = _prenomController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final email = _emailController.text.trim();
    final city = _cityController.text.trim();

    if (nom.isEmpty || prenom.isEmpty || phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez renseigner le nom, prénom, téléphone et mot de passe.'),
          backgroundColor: AppColors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final fullName = '$prenom $nom'.trim();
    final effectiveEmail = email.isNotEmpty ? email : '$phone@dememali.ml';

    final dto = {
      'nom': nom,
      'prenom': prenom,
      'name': fullName,
      'telephone': phone,
      'email': effectiveEmail,
      'motDePasse': password,
      'ville': city.isNotEmpty ? city : 'Bamako',
      'typeDonateur': _selectedType.toUpperCase(),
      'role': 'DONATEUR',
    };

    final result = await _authService.registerDonateur(dto);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      UserSession.setUser(
        name: fullName,
        email: effectiveEmail,
        role: 'Donateur',
        phone: phone,
        city: city,
        nom: nom,
        prenom: prenom,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compte Donateur créé avec succès ! Bienvenue.'),
          backgroundColor: AppColors.vert,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DonateurDashboardScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Inscription : ${result['message']}'),
          backgroundColor: Colors.redAccent,
          action: SnackBarAction(
            label: 'Accéder',
            textColor: Colors.white,
            onPressed: () {
              UserSession.setUser(
                name: fullName,
                email: effectiveEmail,
                role: 'Donateur',
                phone: phone,
                city: city,
                nom: nom,
                prenom: prenom,
              );
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const DonateurDashboardScreen()),
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
              // Bouton retour circulaire
              const DemeBackButton(),
              const SizedBox(height: 16),

              // Logo centré
              const Center(
                child: DemeLogo(
                  size: 70,
                  textSize: 24,
                  showText: true,
                ),
              ),
              const SizedBox(height: 28),

              // Titre et sous-titre
              const Text(
                'Inscription Donateur',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.texte,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Rejoignez la communauté solidaire et soutenez les personnes et familles dans le besoin.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.texteSecondaire,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // Type de donateur
              DemeDropdownField<String>(
                label: 'Type de profil donateur',
                value: _selectedType,
                items: _donorTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedType = v);
                },
              ),
              const SizedBox(height: 16),

              // Nom
              DemeTextField(
                label: 'Nom',
                hintText: 'Entrez votre nom',
                controller: _nomController,
              ),
              const SizedBox(height: 16),

              // Prénom
              DemeTextField(
                label: 'Prénom',
                hintText: 'Entrez votre prénom',
                controller: _prenomController,
              ),
              const SizedBox(height: 16),

              // Téléphone
              DemeTextField(
                label: 'Numéro de téléphone',
                hintText: 'Ex: 67 89 09 78',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // E-mail (optionnel)
              DemeTextField(
                label: 'Adresse e-mail (optionnel)',
                hintText: 'exemple@gmail.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Ville
              DemeTextField(
                label: 'Ville',
                hintText: 'Ex: Bamako',
                controller: _cityController,
              ),
              const SizedBox(height: 16),

              // Mot de passe
              DemeTextField(
                label: 'Mot de passe',
                hintText: '••••••••',
                controller: _passwordController,
                isPassword: true,
                obscureText: _obscurePassword,
                onTogglePassword: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              const SizedBox(height: 32),

              // Bouton Créer mon compte
              SizedBox(
                width: double.infinity,
                child: DemeButton(
                  text: 'Créer mon compte donateur',
                  isLoading: _isLoading,
                  icon: Icons.check,
                  onPressed: _onRegister,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
