import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/services/organisation_service.dart';
import 'package:deme_mali_app/core/theme/app_colors.dart';
import 'package:deme_mali_app/widgets/deme_components.dart';

/// ============================================================================
/// Écran : Enregistrer un Bénéficiaire sur le Terrain
///
/// Permet à l'organisation partenaire d'enrôler directement un individu
/// vulnérable rencontré lors d'une mission de terrain.
/// ============================================================================
class EnregistrerBeneficiaireTerrainScreen extends StatefulWidget {
  const EnregistrerBeneficiaireTerrainScreen({super.key});

  @override
  State<EnregistrerBeneficiaireTerrainScreen> createState() =>
      _EnregistrerBeneficiaireTerrainScreenState();
}

class _EnregistrerBeneficiaireTerrainScreenState
    extends State<EnregistrerBeneficiaireTerrainScreen> {
  final OrganisationService _organisationService = OrganisationService();

  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _villeController = TextEditingController(text: 'Bamako');
  final _adresseController = TextEditingController();
  final _dateNaissanceController = TextEditingController(text: '1995-01-01');
  final _nbEnfantsController = TextEditingController(text: '0');
  final _besoinsController = TextEditingController();

  String _situationMatrimoniale = 'CELIBATAIRE';
  String _handicap = 'AUCUN';
  bool _isLoading = false;

  final List<String> _situations = ['CELIBATAIRE', 'MARIE', 'VEUF', 'DIVORCE'];
  final List<String> _handicaps = ['AUCUN', 'MOTEUR', 'VISUEL', 'AUDITIF', 'AUTRE'];

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _villeController.dispose();
    _adresseController.dispose();
    _dateNaissanceController.dispose();
    _nbEnfantsController.dispose();
    _besoinsController.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    final nom = _nomController.text.trim();
    final prenom = _prenomController.text.trim();
    final tel = _telephoneController.text.trim();
    final ville = _villeController.text.trim();
    final adresse = _adresseController.text.trim();

    if (nom.isEmpty || prenom.isEmpty || tel.isEmpty || adresse.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir le nom, prénom, téléphone et l\'adresse.'),
          backgroundColor: AppColors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final res = await _organisationService.enregistrerBeneficiaire(
      nom: nom,
      prenom: prenom,
      telephone: tel,
      ville: ville,
      adresse: adresse,
      situationMatrimoniale: _situationMatrimoniale,
      nbEnfants: int.tryParse(_nbEnfantsController.text.trim()) ?? 0,
      dateNaissance: _dateNaissanceController.text.trim(),
      handicap: _handicap,
      besoins: _besoinsController.text.trim().isNotEmpty
          ? _besoinsController.text.trim()
          : 'Aide d\'urgence terrain',
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bénéficiaire enrôlé avec succès !'),
          backgroundColor: AppColors.vert,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'enregistrement du bénéficiaire.'),
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
          'Enrôler un bénéficiaire',
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
              DemeTextField(
                label: 'Prénom *',
                hintText: 'Ex : Oumou',
                controller: _prenomController,
              ),
              const SizedBox(height: 14),

              DemeTextField(
                label: 'Nom de famille *',
                hintText: 'Ex : Diarra',
                controller: _nomController,
              ),
              const SizedBox(height: 14),

              DemeTextField(
                label: 'Numéro de téléphone *',
                hintText: 'Ex : 75 11 22 33',
                controller: _telephoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: DemeTextField(
                      label: 'Ville *',
                      hintText: 'Ex : Bamako',
                      controller: _villeController,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DemeTextField(
                      label: 'Nombre d\'enfants',
                      hintText: 'Ex : 3',
                      controller: _nbEnfantsController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              DemeTextField(
                label: 'Adresse précise / Quartier *',
                hintText: 'Ex : Commune 6, Banankabougou, Porte 12',
                controller: _adresseController,
              ),
              const SizedBox(height: 14),

              // Situation matrimoniale
              const Text(
                'Situation matrimoniale',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.texte),
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
                    value: _situationMatrimoniale,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.vert),
                    items: _situations.map((s) {
                      return DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _situationMatrimoniale = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Handicap éventuel
              const Text(
                'Situation de handicap',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.texte),
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
                    value: _handicap,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.vert),
                    items: _handicaps.map((h) {
                      return DropdownMenuItem(value: h, child: Text(h, style: const TextStyle(fontSize: 13)));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _handicap = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Besoins constatés
              const Text(
                'Besoins prioritaires constatés sur place',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.texte),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _besoinsController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Ex : Ravitaillement alimentaire d\'urgence, soutien scolaire pour 2 enfants...',
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: DemeButton(
                  text: _isLoading ? 'Enrôlement en cours...' : 'Valider l\'enrôlement du bénéficiaire',
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _enregistrer,
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
