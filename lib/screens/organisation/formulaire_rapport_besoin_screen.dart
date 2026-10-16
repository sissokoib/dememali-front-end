import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/services/organisation_service.dart';
import 'package:deme_mali_app/core/theme/app_colors.dart';
import 'package:deme_mali_app/widgets/deme_components.dart';

/// ============================================================================
/// Écran : Formulaire du Rapport de Besoin
///
/// Permet à l'organisation partenaire d'évaluer et formaliser :
/// - Le titre du rapport
/// - Le besoin réel identifié
/// - La description détaillée de la situation constatée
/// - La solution recommandée
/// - Le montant total estimé nécessaire (en FCFA)
/// ============================================================================
class FormulaireRapportBesoinScreen extends StatefulWidget {
  final int etudeTerrainId;
  final String demandeTitre;

  const FormulaireRapportBesoinScreen({
    super.key,
    required this.etudeTerrainId,
    required this.demandeTitre,
  });

  @override
  State<FormulaireRapportBesoinScreen> createState() =>
      _FormulaireRapportBesoinScreenState();
}

class _FormulaireRapportBesoinScreenState
    extends State<FormulaireRapportBesoinScreen> {
  final OrganisationService _organisationService = OrganisationService();

  late final TextEditingController _titreController;
  late final TextEditingController _besoinController;
  late final TextEditingController _situationController;
  late final TextEditingController _solutionController;
  late final TextEditingController _montantController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titreController = TextEditingController(
      text: 'Rapport d\'évaluation des besoins : ${widget.demandeTitre}',
    );
    _besoinController = TextEditingController();
    _situationController = TextEditingController();
    _solutionController = TextEditingController();
    _montantController = TextEditingController();
  }

  @override
  void dispose() {
    _titreController.dispose();
    _besoinController.dispose();
    _situationController.dispose();
    _solutionController.dispose();
    _montantController.dispose();
    super.dispose();
  }

  Future<void> _enregistrerRapport() async {
    final titre = _titreController.text.trim();
    final besoin = _besoinController.text.trim();
    final situation = _situationController.text.trim();
    final solution = _solutionController.text.trim();
    final montantStr = _montantController.text.trim();
    final montant = double.tryParse(montantStr) ?? 0.0;

    if (titre.isEmpty || besoin.isEmpty || situation.isEmpty || solution.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir l\'ensemble des rubriques du rapport.'),
          backgroundColor: AppColors.orange,
        ),
      );
      return;
    }

    if (montant <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez spécifier un montant estimé valide.'),
          backgroundColor: AppColors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final res = await _organisationService.creerRapportBesoin(
      etudeTerrainId: widget.etudeTerrainId,
      titre: titre,
      besoinIdentifie: besoin,
      descriptionSituation: situation,
      solutionProposee: solution,
      montantEstime: montant,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rapport de besoin rédigé et enregistré avec succès !'),
          backgroundColor: AppColors.vert,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Échec de l\'enregistrement du rapport de besoin.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivoire,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const DemeBackButton(),
        title: const Text(
          'Rédiger le Rapport de Besoin',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.texte,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre du rapport
              DemeTextField(
                label: 'Titre du rapport de besoin *',
                hintText: 'Ex : Rapport d\'évaluation médico-sociale',
                controller: _titreController,
              ),
              const SizedBox(height: 16),

              // Besoin identifié
              DemeTextField(
                label: 'Besoin réel identifié sur le terrain *',
                hintText: 'Ex : Traitement antipaludéen d\'urgence et vitamines',
                controller: _besoinController,
              ),
              const SizedBox(height: 16),

              // Montant estimé
              DemeTextField(
                label: 'Montant estimé requis (FCFA) *',
                hintText: 'Ex : 75000',
                controller: _montantController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Description de la situation constatée
              const Text(
                'Description de la situation constatée sur le terrain *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.texte),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _situationController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Précisez l\'état du bénéficiaire, son niveau de vulnérabilité, ses revenus et conditions d\'habitat.',
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.vert, width: 1.5)),
                ),
              ),
              const SizedBox(height: 16),

              // Solution proposée
              const Text(
                'Solution préconisée par l\'organisation *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.texte),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _solutionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Quelle intervention concrète proposez-vous ? (Achat direct, distribution de vivres, intervention médicale...)',
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.vert, width: 1.5)),
                ),
              ),
              const SizedBox(height: 30),

              // Bouton Soumettre
              SizedBox(
                width: double.infinity,
                child: DemeButton(
                  text: _isLoading ? 'Enregistrement...' : 'Valider le rapport de besoin',
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _enregistrerRapport,
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
