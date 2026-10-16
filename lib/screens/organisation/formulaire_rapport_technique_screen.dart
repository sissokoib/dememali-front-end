import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/services/organisation_service.dart';
import 'package:deme_mali_app/core/theme/app_colors.dart';
import 'package:deme_mali_app/widgets/deme_components.dart';

/// Item de devis pour le rapport technique
class _DetailItem {
  final TextEditingController designationController = TextEditingController();
  final TextEditingController quantiteController = TextEditingController(text: '1');
  final TextEditingController uniteController = TextEditingController(text: 'lot');
  final TextEditingController prixUnitaireController = TextEditingController();

  void dispose() {
    designationController.dispose();
    quantiteController.dispose();
    uniteController.dispose();
    prixUnitaireController.dispose();
  }

  double get sousTotal {
    final q = double.tryParse(quantiteController.text) ?? 1.0;
    final pu = double.tryParse(prixUnitaireController.text) ?? 0.0;
    return q * pu;
  }
}

/// ============================================================================
/// Écran : Formulaire du Rapport Technique & Chiffrage
///
/// Permet à l'organisation partenaire d'établir :
/// - Les spécifications techniques de l'aide
/// - La décomposition chiffrée des postes de dépense (Désignation, Qté, Unité, PU)
/// - Le calcul automatique du montant certifié
/// ============================================================================
class FormulaireRapportTechniqueScreen extends StatefulWidget {
  final int rapportBesoinId;
  final String demandeTitre;

  const FormulaireRapportTechniqueScreen({
    super.key,
    required this.rapportBesoinId,
    required this.demandeTitre,
  });

  @override
  State<FormulaireRapportTechniqueScreen> createState() =>
      _FormulaireRapportTechniqueScreenState();
}

class _FormulaireRapportTechniqueScreenState
    extends State<FormulaireRapportTechniqueScreen> {
  final OrganisationService _organisationService = OrganisationService();

  late final TextEditingController _descriptionTechniqueController;
  final List<_DetailItem> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _descriptionTechniqueController = TextEditingController(
      text: 'Spécifications techniques et devis pour : ${widget.demandeTitre}',
    );
    // 2 lignes de devis par défaut
    _items.add(_DetailItem());
    _items.add(_DetailItem());
  }

  @override
  void dispose() {
    _descriptionTechniqueController.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add(_DetailItem());
    });
  }

  void _removeItem(int index) {
    if (_items.length > 1) {
      setState(() {
        _items[index].dispose();
        _items.removeAt(index);
      });
    }
  }

  double get _totalGeneral {
    double total = 0.0;
    for (final item in _items) {
      total += item.sousTotal;
    }
    return total;
  }

  Future<void> _enregistrerRapportTechnique() async {
    final desc = _descriptionTechniqueController.text.trim();
    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez fournir une description technique.'),
          backgroundColor: AppColors.orange,
        ),
      );
      return;
    }

    final List<Map<String, dynamic>> detailsPayload = [];
    for (final item in _items) {
      final des = item.designationController.text.trim();
      final q = int.tryParse(item.quantiteController.text.trim()) ?? 1;
      final u = item.uniteController.text.trim().isNotEmpty ? item.uniteController.text.trim() : 'unité';
      final pu = double.tryParse(item.prixUnitaireController.text.trim()) ?? 0.0;

      if (des.isNotEmpty && pu > 0) {
        detailsPayload.add({
          'designation': des,
          'quantite': q,
          'unite': u,
          'prixUnitaire': pu,
        });
      }
    }

    if (detailsPayload.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez renseigner au moins une ligne de devis valide avec un prix unitaire.'),
          backgroundColor: AppColors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final res = await _organisationService.creerRapportTechnique(
      rapportBesoinId: widget.rapportBesoinId,
      descriptionTechnique: desc,
      details: detailsPayload,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rapport technique et devis enregistrés avec succès !'),
          backgroundColor: AppColors.vert,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'enregistrement du devis technique.'),
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
          'Devis & Rapport Technique',
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
              // Description de l'intervention technique
              const Text(
                'Description de l\'intervention technique *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.texte),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _descriptionTechniqueController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Spécifications techniques, mode opératoire ou références des devis certifiés.',
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.vert, width: 1.5)),
                ),
              ),
              const SizedBox(height: 24),

              // Postes de dépenses / Devis
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Postes budgétaires chiffrés',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.texte),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 18, color: AppColors.vert),
                    label: const Text('Ajouter une ligne', style: TextStyle(color: AppColors.vert, fontWeight: FontWeight.bold)),
                    onPressed: _addItem,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Liste dynamique des lignes de devis
              ...List.generate(_items.length, (index) {
                final item = _items[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: item.designationController,
                              decoration: const InputDecoration(
                                labelText: 'Désignation de l\'article ou service *',
                                hintText: 'Ex : Médicaments, Ciment, Sac de riz',
                                isDense: true,
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          if (_items.length > 1)
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                              onPressed: () => _removeItem(index),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          // Quantité
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: item.quantiteController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Quantité',
                                isDense: true,
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Unité
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: item.uniteController,
                              decoration: const InputDecoration(
                                labelText: 'Unité',
                                hintText: 'kg, sac, lot',
                                isDense: true,
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Prix unitaire
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: item.prixUnitaireController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Prix Unit. (FCFA) *',
                                isDense: true,
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Sous-total : ${item.sousTotal.toInt()} FCFA',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.vert),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Total Général Récapitulatif
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2F0E9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL DU DEVIS TECHNIQUE :',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.texte),
                    ),
                    Text(
                      '${_totalGeneral.toInt()} FCFA',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.vert,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Bouton Enregistrer
              SizedBox(
                width: double.infinity,
                child: DemeButton(
                  text: _isLoading ? 'Enregistrement...' : 'Enregistrer le devis technique',
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _enregistrerRapportTechnique,
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
