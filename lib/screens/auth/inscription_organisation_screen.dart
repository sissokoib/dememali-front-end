import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/services/organisation_service.dart';
import 'package:deme_mali_app/core/services/auth_service.dart';
import 'package:deme_mali_app/core/theme/app_colors.dart';
import 'package:deme_mali_app/screens/organisation/organisation_dashboard_screen.dart';
import 'package:deme_mali_app/widgets/deme_components.dart';

/// ============================================================================
/// Écran : Inscription Organisation Partenaire (ONG / Association / Fondation)
/// Workflow en 2 étapes :
/// Étape 1 : Informations légales & contact de l'organisation
/// Étape 2 : Coordonnées du responsable et mot de passe de connexion
/// ============================================================================
class InscriptionOrganisationScreen extends StatefulWidget {
  const InscriptionOrganisationScreen({super.key});

  @override
  State<InscriptionOrganisationScreen> createState() =>
      _InscriptionOrganisationScreenState();
}

class _InscriptionOrganisationScreenState
    extends State<InscriptionOrganisationScreen> {
  final OrganisationService _organisationService = OrganisationService();

  int _currentStep = 1;
  bool _isLoading = false;

  // Contrôleurs Étape 1 : Organisation
  final _nomOrgController = TextEditingController();
  final _nifController = TextEditingController();
  final _adresseController = TextEditingController();
  final _villeController = TextEditingController(text: 'Bamako');
  final _emailController = TextEditingController();
  final _telOrgController = TextEditingController();
  String _selectedType = 'ONG'; // 'ONG', 'ASSOCIATION', 'FONDATION'

  // Contrôleurs Étape 2 : Responsable & Compte
  final _nomRespController = TextEditingController();
  final _prenomRespController = TextEditingController();
  final _telRespController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  final List<String> _typesOrganisation = ['ONG', 'ASSOCIATION', 'FONDATION'];
  final List<String> _villes = [
    'Bamako',
    'Sikasso',
    'Ségou',
    'Mopti',
    'Kayes',
    'Koulikoro',
    'Gao',
    'Tombouctou',
    'Kidal'
  ];

  @override
  void dispose() {
    _nomOrgController.dispose();
    _nifController.dispose();
    _adresseController.dispose();
    _villeController.dispose();
    _emailController.dispose();
    _telOrgController.dispose();
    _nomRespController.dispose();
    _prenomRespController.dispose();
    _telRespController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_nomOrgController.text.trim().isEmpty) {
      _showError('Veuillez renseigner le nom de l\'organisation.');
      return;
    }
    if (_adresseController.text.trim().isEmpty) {
      _showError('Veuillez renseigner l\'adresse du siège.');
      return;
    }
    setState(() => _currentStep = 2);
  }

  void _previousStep() {
    setState(() => _currentStep = 1);
  }

  Future<void> _submitRegistration() async {
    final nomResp = _nomRespController.text.trim();
    final prenomResp = _prenomRespController.text.trim();
    final telResp = _telRespController.text.trim();
    final pass = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (nomResp.isEmpty || prenomResp.isEmpty || telResp.isEmpty) {
      _showError('Veuillez remplir tous les champs du responsable.');
      return;
    }
    if (pass.length < 6) {
      _showError('Le mot de passe doit comporter au moins 6 caractères.');
      return;
    }
    if (pass != confirm) {
      _showError('Les mots de passe ne correspondent pas.');
      return;
    }

    setState(() => _isLoading = true);

    final res = await _organisationService.inscrireOrganisation(
      nomOrganisation: _nomOrgController.text.trim(),
      typeOrganisation: _selectedType,
      nif: _nifController.text.trim().isNotEmpty
          ? _nifController.text.trim()
          : 'NIF-${DateTime.now().millisecondsSinceEpoch % 10000}',
      adresse: _adresseController.text.trim(),
      ville: _villeController.text.trim(),
      email: _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : 'contact@${_nomOrgController.text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '')}.org',
      telephoneOrganisation: _telOrgController.text.trim().isNotEmpty
          ? _telOrgController.text.trim()
          : telResp,
      nomResponsable: nomResp,
      prenomResponsable: prenomResp,
      telephoneResponsable: telResp,
      motDePasse: pass,
    );

    if (!mounted) return;

    if (res['success'] == true) {
      // Connecter immédiatement la session
      final created = res['data'];
      final orgId = created is Map ? (created['id'] as int?) : null;

      UserSession.setUser(
        id: orgId ?? 8,
        name: '$prenomResp $nomResp',
        email: _emailController.text.trim(),
        role: 'Organisation',
        phone: telResp,
        nom: nomResp,
        prenom: prenomResp,
      );
      UserSession.currentUserOrganisationId = orgId ?? 8;
      UserSession.currentUserNomStructure = _nomOrgController.text.trim();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Organisation enregistrée avec succès !'),
          backgroundColor: AppColors.vert,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OrganisationDashboardScreen()),
        (route) => false,
      );
    } else {
      setState(() => _isLoading = false);
      _showError(res['message']?.toString() ?? 'Erreur lors de l\'enregistrement.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivoire,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const DemeBackButton(),
        title: const DemeLogo(size: 26, textSize: 18, showText: true),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stepper Visuel 2 étapes
              _buildStepper(),
              const SizedBox(height: 24),

              // Titre et description
              Text(
                _currentStep == 1
                    ? "Informations de\nl'organisation"
                    : "Responsable et\naccès au compte",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.texte,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _currentStep == 1
                    ? "Renseignez les données officielles de votre structure partenaire."
                    : "Définissez le point de contact et vos identifiants sécurisés.",
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.texteSecondaire,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              if (_currentStep == 1) _buildStepOne() else _buildStepTwo(),

              const SizedBox(height: 32),

              // Boutons d'action
              if (_currentStep == 1)
                SizedBox(
                  width: double.infinity,
                  child: DemeButton(
                    text: 'Continuer',
                    onPressed: _nextStep,
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: DemeButton(
                        text: 'Retour',
                        isOutlined: true,
                        textColor: AppColors.texteSecondaire,
                        onPressed: _previousStep,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 2,
                      child: DemeButton(
                        text: _isLoading ? 'Création en cours...' : 'Finaliser le compte',
                        isLoading: _isLoading,
                        onPressed: _isLoading ? null : _submitRegistration,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepper() {
    return Row(
      children: [
        _buildStepBadge(stepNumber: 1, label: 'Organisation', isActive: _currentStep >= 1),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            height: 3,
            color: _currentStep >= 2 ? AppColors.vert : Colors.grey.shade300,
          ),
        ),
        _buildStepBadge(stepNumber: 2, label: 'Responsable', isActive: _currentStep == 2),
      ],
    );
  }

  Widget _buildStepBadge({
    required int stepNumber,
    required String label,
    required bool isActive,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: isActive ? AppColors.vert : Colors.grey.shade300,
          child: Text(
            '$stepNumber',
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black54,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.vert : AppColors.texteSecondaire,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepOne() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DemeTextField(
          label: "Nom de l'organisation *",
          hintText: "Ex : ONG Espoir Mali, Association Solidarité",
          controller: _nomOrgController,
        ),
        const SizedBox(height: 16),

        // Type d'organisation
        const Text(
          "Type d'organisation *",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.texte,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedType,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.vert),
              items: _typesOrganisation.map((t) {
                return DropdownMenuItem<String>(
                  value: t,
                  child: Text(
                    t,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedType = val);
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        DemeTextField(
          label: "Numéro NIF / Enregistrement officiel",
          hintText: "Ex : NIF-0847291B ou Récépissé",
          controller: _nifController,
        ),
        const SizedBox(height: 16),

        // Ville
        const Text(
          "Ville d'intervention principale *",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.texte,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _villes.contains(_villeController.text) ? _villeController.text : _villes.first,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.vert),
              items: _villes.map((v) {
                return DropdownMenuItem<String>(
                  value: v,
                  child: Text(v, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _villeController.text = val);
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        DemeTextField(
          label: "Adresse du siège *",
          hintText: "Ex : ACI 2000, Rue 312, Porte 45",
          controller: _adresseController,
        ),
        const SizedBox(height: 16),

        DemeTextField(
          label: "Téléphone officiel de l'organisation",
          hintText: "Ex : 70 00 00 00",
          controller: _telOrgController,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),

        DemeTextField(
          label: "Email officiel de l'organisation",
          hintText: "Ex : contact@ong-espoir.org",
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  Widget _buildStepTwo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DemeTextField(
          label: "Prénom du responsable *",
          hintText: "Ex : Oumar",
          controller: _prenomRespController,
        ),
        const SizedBox(height: 16),

        DemeTextField(
          label: "Nom du responsable *",
          hintText: "Ex : Coulibaly",
          controller: _nomRespController,
        ),
        const SizedBox(height: 16),

        DemeTextField(
          label: "Numéro de téléphone personnel (Connexion) *",
          hintText: "Ex : 76 12 34 56",
          controller: _telRespController,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),

        DemeTextField(
          label: "Mot de passe *",
          hintText: "Minimum 6 caractères",
          controller: _passwordController,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: AppColors.texteSecondaire,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 16),

        DemeTextField(
          label: "Confirmer le mot de passe *",
          hintText: "Répétez votre mot de passe",
          controller: _confirmPasswordController,
          obscureText: _obscurePassword,
        ),
      ],
    );
  }
}
