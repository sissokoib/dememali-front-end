import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/services/organisation_service.dart';
import 'package:deme_mali_app/core/theme/app_colors.dart';
import 'package:deme_mali_app/screens/organisation/formulaire_etude_terrain_screen.dart';
import 'package:deme_mali_app/screens/organisation/formulaire_rapport_besoin_screen.dart';
import 'package:deme_mali_app/screens/organisation/formulaire_rapport_technique_screen.dart';
import 'package:deme_mali_app/widgets/deme_components.dart';

/// ============================================================================
/// Écran : Détail & Vérification de la Demande d'Aide (Espace Organisation)
///
/// Permet à l'organisation partenaire de :
/// 1. Consulter les déclarations du demandeur (situation, motifs, contact, lieu)
/// 2. Planifier et enregistrer une Visite / Étude de terrain
/// 3. Rédiger le Rapport de besoin (évaluation des besoins réels constatés)
/// 4. Rédiger le Rapport technique (devis détaillé, postes budgétaires)
/// 5. Valider ou Rejeter la demande avec mise à jour immédiate
/// ============================================================================
class DemandeVerificationDetailScreen extends StatefulWidget {
  final Map<String, dynamic> demande;

  const DemandeVerificationDetailScreen({super.key, required this.demande});

  @override
  State<DemandeVerificationDetailScreen> createState() =>
      _DemandeVerificationDetailScreenState();
}

class _DemandeVerificationDetailScreenState
    extends State<DemandeVerificationDetailScreen> {
  final OrganisationService _organisationService = OrganisationService();

  late Map<String, dynamic> _demandeData;
  List<Map<String, dynamic>> _etudesTerrain = [];
  Map<String, dynamic>? _rapportBesoin;
  Map<String, dynamic>? _rapportTechnique;
  bool _isLoading = true;
  bool _isProcessingAction = false;

  @override
  void initState() {
    super.initState();
    _demandeData = Map<String, dynamic>.from(widget.demande);
    _loadVerificationDetails();
  }

  Future<void> _loadVerificationDetails() async {
    setState(() => _isLoading = true);
    final demandeId = _demandeData['id'] as int? ?? 0;

    if (demandeId > 0) {
      final etudes = await _organisationService.fetchEtudesTerrainDemande(demandeId);
      Map<String, dynamic>? besoin;
      Map<String, dynamic>? tech;

      if (etudes.isNotEmpty) {
        final firstEtudeId = etudes.first['id'] as int?;
        if (firstEtudeId != null) {
          besoin = await _organisationService.fetchRapportBesoinByEtude(firstEtudeId);
          if (besoin != null && besoin['id'] != null) {
            tech = await _organisationService.fetchRapportTechniqueByBesoin(besoin['id'] as int);
          }
        }
      }

      if (mounted) {
        setState(() {
          _etudesTerrain = etudes;
          _rapportBesoin = besoin;
          _rapportTechnique = tech;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _validerDemande() async {
    final demandeId = _demandeData['id'] as int?;
    if (demandeId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer la validation'),
        content: const Text(
          'Confirmez-vous que la demande a été vérifiée avec succès sur le terrain et certifiée conforme ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.vert),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Valider et publier', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessingAction = true);
    final success = await _organisationService.validerDemande(demandeId);
    if (!mounted) return;
    setState(() => _isProcessingAction = false);

    if (success) {
      setState(() {
        _demandeData['statut'] = 'VALIDEE';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demande certifiée et validée avec succès !'),
          backgroundColor: AppColors.vert,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Échec de la validation de la demande.'),
          backgroundColor: AppColors.orange,
        ),
      );
    }
  }

  Future<void> _rejeterDemande() async {
    final demandeId = _demandeData['id'] as int?;
    if (demandeId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer le rejet'),
        content: const Text(
          'Attention : vous êtes sur le point de rejeter cette demande pour non-conformité avec les constats du terrain. Continuer ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Rejeter', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessingAction = true);
    final success = await _organisationService.rejeterDemande(demandeId);
    if (!mounted) return;
    setState(() => _isProcessingAction = false);

    if (success) {
      setState(() {
        _demandeData['statut'] = 'REJETEE';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demande marquée comme rejetée.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final titre = _demandeData['titre']?.toString() ?? 'Demande d\'aide';
    final desc = _demandeData['descriptionSituation']?.toString() ??
        _demandeData['description']?.toString() ??
        'Aucune description fournie.';
    final motif = _demandeData['motif']?.toString() ?? 'Non précisé';
    final urgence = _demandeData['niveauUrgence']?.toString().toUpperCase() ?? 'MOYENNE';
    final statut = _demandeData['statut']?.toString().toUpperCase() ?? 'EN_ATTENTE';
    final benefNom =
        '${_demandeData['beneficiairePrenom'] ?? ''} ${_demandeData['beneficiaireNom'] ?? ''}'.trim();
    final montant = _demandeData['montantNecessaire']?.toString() ?? '0';

    final bool hasEtude = _etudesTerrain.isNotEmpty;
    final bool hasBesoin = _rapportBesoin != null;
    final bool hasTech = _rapportTechnique != null;
    final bool isValidee = statut == 'VALIDEE' || statut == 'PUBLIEE';
    final bool isRejetee = statut == 'REJETEE';

    return Scaffold(
      backgroundColor: AppColors.ivoire,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const DemeBackButton(),
        title: const Text(
          'Vérification de terrain',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.texte,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.vert))
          : RefreshIndicator(
              onRefresh: _loadVerificationDetails,
              color: AppColors.vert,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. En-tête : Titre de la demande et statut
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            titre,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.texte,
                              height: 1.25,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _buildStatusBadge(statut),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 2. Carte récapitulative du demandeur & urgence
                    _buildBeneficiaryCard(benefNom, urgence, montant, motif),
                    const SizedBox(height: 20),

                    // 3. Déclaration du demandeur
                    _buildSectionHeader('Déclaration du demandeur', Icons.speaker_notes_outlined),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            desc,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF374151),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.people_outline, size: 16, color: AppColors.texteSecondaire),
                              const SizedBox(width: 6),
                              Text(
                                "Personnes à charge : ${_demandeData['nombrePersonne'] ?? 1}",
                                style: const TextStyle(fontSize: 12, color: AppColors.texteSecondaire),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 4. Stepper d'avancement de la vérification terrain
                    _buildSectionHeader('Cycle de vérification de l\'organisation', Icons.timeline),
                    const SizedBox(height: 10),
                    _buildVerificationPipeline(hasEtude, hasBesoin, hasTech, isValidee, isRejetee),
                    const SizedBox(height: 24),

                    // 5. Section : Visites / Études de terrain
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionHeader('Visite de terrain', Icons.location_on_outlined),
                        if (!hasEtude && !isValidee && !isRejetee)
                          TextButton.icon(
                            icon: const Icon(Icons.add, size: 18, color: AppColors.vert),
                            label: const Text('Planifier', style: TextStyle(color: AppColors.vert, fontWeight: FontWeight.bold)),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FormulaireEtudeTerrainScreen(demande: _demandeData),
                                ),
                              );
                              if (result == true) _loadVerificationDetails();
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (hasEtude)
                      _buildEtudeCard(_etudesTerrain.first)
                    else
                      _buildEmptyCard(
                        icon: Icons.directions_walk_outlined,
                        title: 'Aucune visite de terrain enregistrée',
                        subtitle: 'Rendez-vous sur les lieux pour vérifier les conditions réelles.',
                        actionText: 'Effectuer la visite',
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FormulaireEtudeTerrainScreen(demande: _demandeData),
                            ),
                          );
                          if (result == true) _loadVerificationDetails();
                        },
                      ),
                    const SizedBox(height: 24),

                    // 6. Section : Rapport de besoin
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionHeader('Rapport de besoin', Icons.description_outlined),
                        if (hasEtude && !hasBesoin && !isValidee && !isRejetee)
                          TextButton.icon(
                            icon: const Icon(Icons.add, size: 18, color: AppColors.vert),
                            label: const Text('Rédiger', style: TextStyle(color: AppColors.vert, fontWeight: FontWeight.bold)),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FormulaireRapportBesoinScreen(
                                    etudeTerrainId: _etudesTerrain.first['id'] as int,
                                    demandeTitre: titre,
                                  ),
                                ),
                              );
                              if (result == true) _loadVerificationDetails();
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (hasBesoin)
                      _buildRapportBesoinCard(_rapportBesoin!)
                    else
                      _buildEmptyCard(
                        icon: Icons.assignment_outlined,
                        title: 'Rapport de besoin en attente',
                        subtitle: hasEtude
                            ? 'Établissez le constat des besoins réels observés sur place.'
                            : 'Effectuez d\'abord la visite de terrain pour rédiger le rapport.',
                        actionText: hasEtude ? 'Rédiger le rapport de besoin' : null,
                        onTap: hasEtude
                            ? () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FormulaireRapportBesoinScreen(
                                      etudeTerrainId: _etudesTerrain.first['id'] as int,
                                      demandeTitre: titre,
                                    ),
                                  ),
                                );
                                if (result == true) _loadVerificationDetails();
                              }
                            : null,
                      ),
                    const SizedBox(height: 24),

                    // 7. Section : Rapport technique
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionHeader('Rapport technique & Devis', Icons.build_circle_outlined),
                        if (hasBesoin && !hasTech && !isValidee && !isRejetee)
                          TextButton.icon(
                            icon: const Icon(Icons.add, size: 18, color: AppColors.vert),
                            label: const Text('Chiffrer', style: TextStyle(color: AppColors.vert, fontWeight: FontWeight.bold)),
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FormulaireRapportTechniqueScreen(
                                    rapportBesoinId: _rapportBesoin!['id'] as int,
                                    demandeTitre: titre,
                                  ),
                                ),
                              );
                              if (result == true) _loadVerificationDetails();
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (hasTech)
                      _buildRapportTechniqueCard(_rapportTechnique!)
                    else
                      _buildEmptyCard(
                        icon: Icons.receipt_long_outlined,
                        title: 'Rapport technique non chiffré',
                        subtitle: hasBesoin
                            ? 'Détaillez les postes de dépenses et les spécifications techniques.'
                            : 'Nécessite la validation préalable du rapport de besoin.',
                        actionText: hasBesoin ? 'Établir le devis technique' : null,
                        onTap: hasBesoin
                            ? () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FormulaireRapportTechniqueScreen(
                                      rapportBesoinId: _rapportBesoin!['id'] as int,
                                      demandeTitre: titre,
                                    ),
                                  ),
                                );
                                if (result == true) _loadVerificationDetails();
                              }
                            : null,
                      ),
                    const SizedBox(height: 32),

                    // 8. Boutons d'action finale de décision
                    if (!isValidee && !isRejetee) ...[
                      const Text(
                        'Décision de l\'organisation partenaire',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.texte,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Après avoir effectué la visite et fourni les rapports, validez pour certifier la demande et la publier pour collecte auprès des donateurs.',
                        style: TextStyle(fontSize: 13, color: AppColors.texteSecondaire, height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                                side: const BorderSide(color: Colors.redAccent),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              icon: const Icon(Icons.close, size: 20),
                              label: const Text('Rejeter', style: TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: _isProcessingAction ? null : _rejeterDemande,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.vert,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.check_circle_outline, size: 20),
                              label: const Text('Certifier & Valider', style: TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: _isProcessingAction ? null : _validerDemande,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isValidee ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isValidee ? Icons.verified : Icons.cancel_outlined,
                              color: isValidee ? AppColors.vert : Colors.redAccent,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isValidee
                                    ? 'Cette demande a été validée et certifiée conforme sur le terrain.'
                                    : 'Cette demande a été rejetée suite au constat de terrain.',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isValidee ? AppColors.vert : Colors.redAccent,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.vert),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.texte,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String statut) {
    Color bg = const Color(0xFFFEF3C7);
    Color text = const Color(0xFFD97706);
    String label = 'En attente';

    if (statut == 'VALIDEE' || statut == 'PUBLIEE') {
      bg = const Color(0xFFDCFCE7);
      text = const Color(0xFF166534);
      label = 'Validée & Conforme';
    } else if (statut == 'REJETEE') {
      bg = const Color(0xFFFEE2E2);
      text = const Color(0xFF991B1B);
      label = 'Non conforme / Rejetée';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  Widget _buildBeneficiaryCard(String nom, String urgence, String montant, String motif) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFE2F0E9),
                child: Text(
                  nom.isNotEmpty ? nom[0].toUpperCase() : 'B',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.vert,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nom.isNotEmpty ? nom : 'Bénéficiaire Dèmè Mali',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.texte,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Motif : $motif',
                      style: const TextStyle(fontSize: 12, color: AppColors.texteSecondaire),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: urgence == 'FORTE' ? const Color(0xFFFFECE8) : const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Urgence $urgence',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: urgence == 'FORTE' ? AppColors.orange : const Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Montant estimé sollicité :',
                style: TextStyle(fontSize: 13, color: AppColors.texteSecondaire),
              ),
              Text(
                '$montant FCFA',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.vert,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationPipeline(
    bool hasEtude,
    bool hasBesoin,
    bool hasTech,
    bool isValidee,
    bool isRejetee,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildPipelineRow(1, 'Visite de terrain effectuée', hasEtude, isLast: false),
          _buildPipelineRow(2, 'Rapport de besoin rédigé', hasBesoin, isLast: false),
          _buildPipelineRow(3, 'Rapport technique & devis validé', hasTech, isLast: false),
          _buildPipelineRow(
            4,
            isValidee
                ? 'Certification & Publication'
                : (isRejetee ? 'Demande rejetée' : 'Décision finale en attente'),
            isValidee || isRejetee,
            isLast: true,
            isError: isRejetee,
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineRow(int step, String title, bool isDone, {required bool isLast, bool isError = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isDone
                    ? (isError ? Colors.redAccent : AppColors.vert)
                    : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isDone
                    ? Icon(isError ? Icons.close : Icons.check, size: 14, color: Colors.white)
                    : Text(
                        '$step',
                        style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 24,
                color: isDone ? AppColors.vert.withOpacity(0.4) : Colors.grey.shade200,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isDone ? FontWeight.bold : FontWeight.w500,
                color: isDone
                    ? (isError ? Colors.redAccent : AppColors.texte)
                    : AppColors.texteSecondaire,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEtudeCard(Map<String, dynamic> etude) {
    final lieu = etude['lieu']?.toString() ?? 'Non précisé';
    final date = etude['dateRealisation']?.toString() ?? etude['datePlanification']?.toString() ?? '';
    final resultat = etude['resultat']?.toString() ?? 'CONFORME';
    final observation = etude['observation']?.toString() ?? 'Aucune observation enregistrée.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.vert.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.vert, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Réalisée le $date',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.texte),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: resultat == 'CONFORME' ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  resultat,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: resultat == 'CONFORME' ? const Color(0xFF166534) : const Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Lieu visité : $lieu',
            style: const TextStyle(fontSize: 12, color: AppColors.texteSecondaire),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              observation,
              style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563), fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRapportBesoinCard(Map<String, dynamic> besoin) {
    final titre = besoin['titre']?.toString() ?? 'Rapport de besoin';
    final montant = besoin['montantEstime']?.toString() ?? '0';
    final situation = besoin['descriptionSituation']?.toString() ?? '';
    final solution = besoin['solutionProposee']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.vert.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  titre,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.texte),
                ),
              ),
              Text(
                '$montant FCFA',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.vert),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (situation.isNotEmpty) ...[
            const Text('Constat de situation :', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.texteSecondaire)),
            const SizedBox(height: 2),
            Text(situation, style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563))),
            const SizedBox(height: 8),
          ],
          if (solution.isNotEmpty) ...[
            const Text('Solution recommandée :', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.texteSecondaire)),
            const SizedBox(height: 2),
            Text(solution, style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563))),
          ],
        ],
      ),
    );
  }

  Widget _buildRapportTechniqueCard(Map<String, dynamic> tech) {
    final descTech = tech['descriptionTechnique']?.toString() ?? 'Intervention technique';
    final List details = tech['details'] as List? ?? [];

    double totalCalcule = 0;
    for (final d in details) {
      if (d is Map) {
        final double q = (d['quantite'] as num?)?.toDouble() ?? 1.0;
        final double pu = (d['prixUnitaire'] as num?)?.toDouble() ?? 0.0;
        totalCalcule += (q * pu);
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.vert.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            descTech,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.texte),
          ),
          const SizedBox(height: 12),
          const Text('Devis détaillé chiffré :', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.texteSecondaire)),
          const SizedBox(height: 6),
          ...details.map((item) {
            final des = item['designation']?.toString() ?? 'Poste';
            final q = item['quantite'] ?? 1;
            final u = item['unite'] ?? 'u';
            final pu = item['prixUnitaire'] ?? 0;
            final sousTotal = (item['montant'] ?? (q is num && pu is num ? q * pu : 0)).toString();

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '$des ($q $u x $pu)',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF374151)),
                    ),
                  ),
                  Text(
                    '$sousTotal FCFA',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.texte),
                  ),
                ],
              ),
            );
          }),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Coût technique certifié :', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.texte)),
              Text(
                '${totalCalcule.toInt()} FCFA',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.vert),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionText,
    VoidCallback? onTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.grey.shade600, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.texte)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.texteSecondaire)),
                  ],
                ),
              ),
            ],
          ),
          if (actionText != null && onTap != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.vert,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: Text(actionText, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                onPressed: onTap,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
