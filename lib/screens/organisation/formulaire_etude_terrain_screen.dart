import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/services/organisation_service.dart';
import 'package:deme_mali_app/core/theme/app_colors.dart';
import 'package:deme_mali_app/widgets/deme_components.dart';

/// ============================================================================
/// Écran : Formulaire d'Étude / Visite de terrain
///
/// Permet à l'agent de terrain de l'organisation partenaire d'enregistrer :
/// - Les coordonnées de la visite (date, heure, lieu)
/// - L'objectif et les observations directes
/// - Le résultat préliminaire de conformité (CONFORME, BESOIN_REAJUSTE, NON_CONFORME)
/// ============================================================================
class FormulaireEtudeTerrainScreen extends StatefulWidget {
  final Map<String, dynamic> demande;

  const FormulaireEtudeTerrainScreen({super.key, required this.demande});

  @override
  State<FormulaireEtudeTerrainScreen> createState() =>
      _FormulaireEtudeTerrainScreenState();
}

class _FormulaireEtudeTerrainScreenState
    extends State<FormulaireEtudeTerrainScreen> {
  final OrganisationService _organisationService = OrganisationService();

  late final TextEditingController _lieuController;
  late final TextEditingController _dateController;
  late final TextEditingController _heureController;
  late final TextEditingController _objectifController;
  late final TextEditingController _observationController;

  String _resultat = 'CONFORME'; // 'CONFORME', 'BESOIN_REAJUSTE', 'NON_CONFORME'
  String _status = 'TERMINEE'; // 'TERMINEE', 'PLANIFIEE'
  bool _isLoading = false;

  final List<String> _resultats = ['CONFORME', 'BESOIN_REAJUSTE', 'NON_CONFORME'];

  @override
  void initState() {
    super.initState();
    final today = DateTime.now().toIso8601String().split('T').first;
    final benefLieu = widget.demande['adresse'] ?? widget.demande['ville'] ?? 'Bamako';

    _lieuController = TextEditingController(text: benefLieu.toString());
    _dateController = TextEditingController(text: today);
    _heureController = TextEditingController(text: '10:00');
    _objectifController = TextEditingController(
      text: 'Vérification terrain de la demande d\'aide et constat de la situation réelle.',
    );
    _observationController = TextEditingController();
  }

  @override
  void dispose() {
    _lieuController.dispose();
    _dateController.dispose();
    _heureController.dispose();
    _objectifController.dispose();
    _observationController.dispose();
    super.dispose();
  }

  Future<void> _enregistrerEtude() async {
    final demandeId = widget.demande['id'] as int? ?? 0;
    final lieu = _lieuController.text.trim();
    final objectif = _objectifController.text.trim();
    final observation = _observationController.text.trim();
    final date = _dateController.text.trim();
    final heure = _heureController.text.trim();

    if (lieu.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez préciser le lieu visité.'), backgroundColor: AppColors.orange),
      );
      return;
    }
    if (observation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez renseigner vos observations sur le terrain.'), backgroundColor: AppColors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    final res = await _organisationService.creerEtudeTerrain(
      demandeAideId: demandeId,
      datePlanification: date,
      dateRealisation: date,
      heure: heure,
      lieu: lieu,
      objectif: objectif,
      observation: observation,
      resultat: _resultat,
      status: _status,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Visite de terrain enregistrée avec succès !'),
          backgroundColor: AppColors.vert,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'enregistrement de la visite.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final titreDemande = widget.demande['titre']?.toString() ?? 'Demande';

    return Scaffold(
      backgroundColor: AppColors.ivoire,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const DemeBackButton(),
        title: const Text(
          'Enregistrer une visite de terrain',
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
              // Demande associée
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.vert.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.assignment_outlined, color: AppColors.vert, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Demande d\'aide concernée :', style: TextStyle(fontSize: 11, color: AppColors.texteSecondaire)),
                          Text(
                            titreDemande,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.texte),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Lieu visité
              DemeTextField(
                label: 'Lieu visité (Adresse / Commune / Quartier) *',
                hintText: 'Ex : Commune 5, Quartier Daoudabougou, Rue 12',
                controller: _lieuController,
              ),
              const SizedBox(height: 16),

              // Date et heure
              Row(
                children: [
                  Expanded(
                    child: DemeTextField(
                      label: 'Date de la visite *',
                      hintText: 'YYYY-MM-DD',
                      controller: _dateController,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: DemeTextField(
                      label: 'Heure *',
                      hintText: 'Ex : 10:30',
                      controller: _heureController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Objectif
              DemeTextField(
                label: 'Objectif de la visite *',
                hintText: 'Ex : Constater les conditions réelles de vie',
                controller: _objectifController,
              ),
              const SizedBox(height: 16),

              // Résultat de l'étude
              const Text(
                'Résultat de l\'étude de terrain *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.texte),
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
                    value: _resultat,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.vert),
                    items: _resultats.map((r) {
                      String label = 'Conforme aux déclarations';
                      if (r == 'BESOIN_REAJUSTE') label = 'Besoin réajusté après constat';
                      if (r == 'NON_CONFORME') label = 'Non conforme / Rejet recommandé';

                      return DropdownMenuItem<String>(
                        value: r,
                        child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _resultat = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Observations de terrain
              const Text(
                'Observations directes sur le terrain *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.texte),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _observationController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Décrivez ce que vous avez constaté (logement, état de santé, échange avec le voisinage, vérification des ordonnances...).',
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

              // Bouton Enregistrer
              SizedBox(
                width: double.infinity,
                child: DemeButton(
                  text: _isLoading ? 'Enregistrement...' : 'Enregistrer la visite de terrain',
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _enregistrerEtude,
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
