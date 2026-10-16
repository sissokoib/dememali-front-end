import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/services/auth_service.dart';
import 'package:deme_mali_app/core/theme/app_colors.dart';
import 'package:deme_mali_app/screens/auth/choix_organisation_inscription_screen.dart';
import 'package:deme_mali_app/widgets/deme_components.dart';

/// ============================================================================
/// Écran : Inscription Bénéficiaire Particulier (Étape 2 sur 2)
/// Conforme à la maquette Figma "Inscription 2 particulier.png"
/// ============================================================================
class BeneficiarySituationScreen extends StatefulWidget {
  const BeneficiarySituationScreen({super.key});

  @override
  State<BeneficiarySituationScreen> createState() =>
      _BeneficiarySituationScreenState();
}

class _BeneficiarySituationScreenState
    extends State<BeneficiarySituationScreen> {
  String _selectedType = 'Famille';
  String _selectedSituation = 'Marié(e)';
  String _selectedHandicap = 'Aucun handicap';

  final TextEditingController _enfantsController =
      TextEditingController(text: '4');
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateNaissanceController =
      TextEditingController(text: UserSession.currentUserDateNaissance ?? '');

  final List<String> _typesBeneficiaire = [
    'Famille',
    'Individu',
    'Étudiant',
    'Personne âgée',
    'Autre',
  ];

  final List<String> _situationsMatrimoniales = [
    'Marié(e)',
    'Célibataire',
    'Veuf(ve)',
    'Divorcé(e)',
  ];

  final List<String> _typesHandicap = [
    'Aucun handicap',
    'Handicap moteur',
    'Handicap visuel',
    'Handicap auditif',
    'Autre handicap',
  ];

  @override
  void dispose() {
    _enfantsController.dispose();
    _descriptionController.dispose();
    _dateNaissanceController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25, 1, 1),
      firstDate: DateTime(now.year - 100),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.vert,
              onPrimary: Colors.white,
              onSurface: AppColors.texte,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final day = picked.day.toString().padLeft(2, '0');
      final month = picked.month.toString().padLeft(2, '0');
      setState(() {
        _dateNaissanceController.text = '$day / $month / ${picked.year}';
      });
    }
  }

  void _onNext() {
    // Sauvegarder dans la session
    UserSession.currentUserTypeBeneficiaire = _selectedType.toUpperCase();
    UserSession.currentUserSituationMatrimoniale = _selectedSituation;
    UserSession.currentUserNbEnfants = int.tryParse(_enfantsController.text) ?? 0;
    UserSession.currentUserHandicap = _selectedHandicap;
    UserSession.currentUserBesoins = _descriptionController.text.trim();
    UserSession.currentUserDateNaissance = _dateNaissanceController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ChoixOrganisationInscriptionScreen(),
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
              // 1. Stepper Header (2 sur 2)
              const DemeStepperHeader(currentStep: 2, totalSteps: 2),
              const SizedBox(height: 28),

              // 2. Titre et description
              const Text(
                'Informations bénéficiaire',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.texte,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ces critères nous permettent de mieux cibler et prioriser nos interventions de soutien.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.texteSecondaire,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // 3. Type de bénéficiaire
              DemeDropdownField<String>(
                label: 'Type de bénéficiaire',
                value: _selectedType,
                items: _typesBeneficiaire
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedType = v);
                },
              ),
              const SizedBox(height: 16),

              // 4. Situation matrimoniale
              DemeDropdownField<String>(
                label: 'Situation matrimoniale',
                value: _selectedSituation,
                items: _situationsMatrimoniales
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedSituation = v);
                },
              ),
              const SizedBox(height: 16),

              // 5. Nombre d'enfants
              DemeTextField(
                label: 'Nombre d\'enfants',
                hintText: '4',
                controller: _enfantsController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // 6. Type de handicap
              DemeDropdownField<String>(
                label: 'Type de handicap',
                value: _selectedHandicap,
                items: _typesHandicap
                    .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedHandicap = v);
                },
              ),
              const SizedBox(height: 16),

              // 7. Description de votre situation
              DemeTextField(
                label: 'Description de votre situation',
                hintText:
                    'Décrivez brièvement vos besoins prioritaires actuels (santé, alimentation, éducation...)',
                controller: _descriptionController,
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // 8. Date de naissance
              DemeTextField(
                label: 'Date de naissance',
                hintText: 'JJ / MM / AAAA',
                controller: _dateNaissanceController,
                readOnly: true,
                onTap: _pickDate,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today_outlined,
                      color: AppColors.placeholder),
                  onPressed: _pickDate,
                ),
              ),
              const SizedBox(height: 36),

              // 9. Boutons Retour / Suivant
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
