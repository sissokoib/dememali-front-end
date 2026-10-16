import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/services/auth_service.dart';
import 'package:deme_mali_app/core/theme/app_colors.dart';
import 'package:deme_mali_app/screens/auth/inscription_structure_justificatif_screen.dart';
import 'package:deme_mali_app/widgets/deme_components.dart';

/// ============================================================================
/// Écran : Inscription Bénéficiaire Structure (Étape 1 sur 3)
/// Conforme à la maquette Figma "Inscription Structure.png"
/// ============================================================================
class InscriptionStructureScreen extends StatefulWidget {
  const InscriptionStructureScreen({super.key});

  @override
  State<InscriptionStructureScreen> createState() =>
      _InscriptionStructureScreenState();
}

class _InscriptionStructureScreenState
    extends State<InscriptionStructureScreen> {
  final TextEditingController _nomStructureController =
      TextEditingController(text: UserSession.currentUserNomStructure ?? '');
  final TextEditingController _nifController =
      TextEditingController(text: UserSession.currentUserNif ?? '');
  final TextEditingController _villeController =
      TextEditingController(text: UserSession.currentUserCity ?? 'Bamako');
  final TextEditingController _adresseController =
      TextEditingController(text: UserSession.currentUserAddress ?? '');

  String _selectedType = 'Ecole';

  final List<String> _typesStructure = [
    'Ecole',
    'Orphelinat',
    'Centre de santé',
    'Association locale',
    'Autre structure',
  ];

  @override
  void dispose() {
    _nomStructureController.dispose();
    _nifController.dispose();
    _villeController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  void _onNext() {
    final nom = _nomStructureController.text.trim();
    final ville = _villeController.text.trim();

    if (nom.isEmpty || ville.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez renseigner le nom de la structure et la ville.'),
          backgroundColor: AppColors.orange,
        ),
      );
      return;
    }

    UserSession.currentUserNomStructure = nom;
    UserSession.currentUserTypeBeneficiaire = _selectedType.toUpperCase();
    UserSession.currentUserNif = _nifController.text.trim();
    UserSession.currentUserCity = ville;
    UserSession.currentUserAddress = _adresseController.text.trim();
    UserSession.currentUserRole = 'Bénéficiaire';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const InscriptionStructureJustificatifScreen(),
      ),
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
              // 1. Stepper Header (1 sur 3)
              const DemeStepperHeader(currentStep: 1, totalSteps: 3),
              const SizedBox(height: 28),

              // 2. Titre et description
              const Text(
                'Informations de la structure',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.texte,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Renseignez les informations de votre structure.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.texteSecondaire,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // 3. Nom de la structure
              DemeTextField(
                label: 'Nom de la structure',
                hintText: 'Entrez le nom de votre structure',
                controller: _nomStructureController,
              ),
              const SizedBox(height: 16),

              // 4. Type de structure
              DemeDropdownField<String>(
                label: 'Type de structure',
                value: _selectedType,
                items: _typesStructure
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedType = v);
                },
              ),
              const SizedBox(height: 16),

              // 5. NIF
              DemeTextField(
                label: "Numéro d'Identification Fiscale",
                hintText: "Entrez le numéro d'Identification Fiscale.",
                controller: _nifController,
              ),
              const SizedBox(height: 16),

              // 6. Ville
              DemeTextField(
                label: 'Ville',
                hintText: 'Entrez la ville',
                controller: _villeController,
              ),
              const SizedBox(height: 16),

              // 7. Adresse
              DemeTextField(
                label: 'Adresse',
                hintText: 'Ex: Quartier du Fleuve, Rue 110',
                controller: _adresseController,
              ),
              const SizedBox(height: 36),

              // 8. Boutons Retour / Suivant
              DemeBottomButtons(
                onBack: () => Navigator.pop(context),
                nextText: 'Suivant',
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
