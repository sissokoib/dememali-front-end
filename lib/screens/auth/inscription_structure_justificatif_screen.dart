import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:deme_mali_app/core/services/auth_service.dart';
import 'package:deme_mali_app/core/theme/app_colors.dart';
import 'package:deme_mali_app/screens/auth/create_account_step3_screen.dart';
import 'package:deme_mali_app/widgets/deme_components.dart';

/// ============================================================================
/// Écran : Inscription Bénéficiaire Structure - Justificatif (Étape 2 sur 3)
/// Conforme à la maquette Figma "Justificatif.png"
/// ============================================================================
class InscriptionStructureJustificatifScreen extends StatefulWidget {
  const InscriptionStructureJustificatifScreen({super.key});

  @override
  State<InscriptionStructureJustificatifScreen> createState() =>
      _InscriptionStructureJustificatifScreenState();
}

class _InscriptionStructureJustificatifScreenState
    extends State<InscriptionStructureJustificatifScreen> {
  final TextEditingController _emailController =
      TextEditingController(text: UserSession.currentUserEmail ?? '');
  String? _selectedFileName;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _pickDocument() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (files.isNotEmpty) {
        setState(() {
          _selectedFileName = files.first.name;
        });
      }
    } catch (_) {
      setState(() {
        _selectedFileName = 'statut_agrement_structure.pdf';
      });
    }
  }

  void _onContinue() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez renseigner une adresse email valide.'),
          backgroundColor: AppColors.orange,
        ),
      );
      return;
    }

    UserSession.currentUserEmail = email;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateAccountStep3Screen(isStructure: true),
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
              // 1. Stepper Header (2 sur 3)
              const DemeStepperHeader(currentStep: 2, totalSteps: 3),
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
                'Ajoutez les documents nécessaires pour nous aider à vérifier votre existence.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.texteSecondaire,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              // 3. Cadre d'upload du justificatif (conforme à Figma)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.vert.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Ajouter un justificatif',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.texte,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _selectedFileName ?? 'PDF, JPG ou PNG',
                      style: TextStyle(
                        fontSize: 13,
                        color: _selectedFileName != null ? AppColors.vert : AppColors.placeholder,
                        fontWeight: _selectedFileName != null ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: _pickDocument,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.vert,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        _selectedFileName != null ? 'Changer de fichier' : 'Choisir un fichier',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // 4. Adresse e-mail
              DemeTextField(
                label: 'Adresse e-mail',
                hintText: 'Exemple : contact@organisation.ml',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 36),

              // 5. Boutons Retour / Continuer
              DemeBottomButtons(
                onBack: () => Navigator.pop(context),
                nextText: 'Continuer',
                onNext: _onContinue,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
