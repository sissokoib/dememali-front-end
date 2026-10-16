import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/services/organisation_service.dart';
import 'package:deme_mali_app/core/theme/app_colors.dart';
import 'package:deme_mali_app/screens/organisation/demande_verification_detail_screen.dart';

/// ============================================================================
/// Écran : Visites de Terrain & Rapports (Espace Organisation Partenaire)
/// ============================================================================
class OrganisationVisitesScreen extends StatefulWidget {
  const OrganisationVisitesScreen({super.key});

  @override
  State<OrganisationVisitesScreen> createState() =>
      _OrganisationVisitesScreenState();
}

class _OrganisationVisitesScreenState extends State<OrganisationVisitesScreen> {
  final OrganisationService _organisationService = OrganisationService();

  List<Map<String, dynamic>> _etudes = [];
  List<Map<String, dynamic>> _demandes = [];
  bool _isLoading = true;
  String _selectedFilter = 'TOUTES'; // 'TOUTES', 'TERMINEE', 'PLANIFIEE'

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      _organisationService.fetchEtudesTerrain(),
      _organisationService.fetchDemandesOrganisation(),
    ]);

    if (mounted) {
      setState(() {
        _etudes = results[0];
        _demandes = results[1];
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredEtudes {
    if (_selectedFilter == 'TOUTES') return _etudes;
    return _etudes.where((e) {
      final s = (e['status'] ?? '').toString().toUpperCase();
      return s == _selectedFilter;
    }).toList();
  }

  Map<String, dynamic>? _getDemandeForEtude(int demandeId) {
    try {
      return _demandes.firstWhere((d) => d['id'] == demandeId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivoire,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Visites de terrain',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.texte,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filtres
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Row(
                children: [
                  _buildFilterChip('Toutes (${_etudes.length})', 'TOUTES'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Réalisées', 'TERMINEE'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Planifiées', 'PLANIFIEE'),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Liste des visites
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.vert))
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: AppColors.vert,
                      child: _filteredEtudes.isEmpty
                          ? ListView(
                              children: [
                                const SizedBox(height: 80),
                                const Center(
                                  child: Icon(Icons.location_city_outlined, size: 48, color: Colors.grey),
                                ),
                                const SizedBox(height: 12),
                                const Center(
                                  child: Text(
                                    'Aucune visite de terrain pour le moment.',
                                    style: TextStyle(color: AppColors.texteSecondaire, fontSize: 14),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Center(
                                  child: Text(
                                    'Sélectionnez une demande d\'aide pour démarrer une visite.',
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ),
                              ],
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                              itemCount: _filteredEtudes.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final etude = _filteredEtudes[index];
                                final demandeId = etude['demandeAideId'] as int? ?? 0;
                                final demande = _getDemandeForEtude(demandeId);

                                return _buildEtudeListItem(etude, demande);
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final bool isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.vert : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.vert : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.texte,
          ),
        ),
      ),
    );
  }

  Widget _buildEtudeListItem(Map<String, dynamic> etude, Map<String, dynamic>? demande) {
    final lieu = etude['lieu']?.toString() ?? 'Lieu non spécifié';
    final date = etude['dateRealisation']?.toString() ?? etude['datePlanification']?.toString() ?? '';
    final resultat = (etude['resultat'] ?? 'CONFORME').toString();
    final observation = etude['observation']?.toString() ?? 'Aucune observation.';
    final titreDemande = demande?['titre']?.toString() ?? 'Demande #${etude['demandeAideId']}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, size: 18, color: AppColors.vert),
                  const SizedBox(width: 6),
                  Text(
                    lieu,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.texte),
                  ),
                ],
              ),
              _buildResultatBadge(resultat),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Demande : $titreDemande',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: AppColors.texteSecondaire, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              observation,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Date : $date',
                style: const TextStyle(fontSize: 11, color: AppColors.texteSecondaire),
              ),
              if (demande != null)
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DemandeVerificationDetailScreen(demande: demande),
                      ),
                    );
                  },
                  child: const Row(
                    children: [
                      Text('Voir les rapports', style: TextStyle(fontSize: 12, color: AppColors.vert, fontWeight: FontWeight.bold)),
                      Icon(Icons.chevron_right, size: 16, color: AppColors.vert),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultatBadge(String resultat) {
    Color bg = const Color(0xFFDCFCE7);
    Color text = const Color(0xFF166534);
    if (resultat == 'BESOIN_REAJUSTE') {
      bg = const Color(0xFFFEF3C7);
      text = const Color(0xFFB45309);
    } else if (resultat == 'NON_CONFORME') {
      bg = const Color(0xFFFEE2E2);
      text = const Color(0xFF991B1B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        resultat,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: text),
      ),
    );
  }
}
