import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/services/organisation_service.dart';
import 'package:deme_mali_app/core/theme/app_colors.dart';
import 'package:deme_mali_app/screens/organisation/demande_verification_detail_screen.dart';

/// ============================================================================
/// Écran : Demandes d'Aide Assignées à l'Organisation Partenaire
/// ============================================================================
class OrganisationDemandesScreen extends StatefulWidget {
  const OrganisationDemandesScreen({super.key});

  @override
  State<OrganisationDemandesScreen> createState() =>
      _OrganisationDemandesScreenState();
}

class _OrganisationDemandesScreenState
    extends State<OrganisationDemandesScreen> {
  final OrganisationService _organisationService = OrganisationService();

  List<Map<String, dynamic>> _demandes = [];
  bool _isLoading = true;
  String _selectedFilter = 'TOUTES'; // 'TOUTES', 'EN_ATTENTE', 'VALIDEE', 'REJETEE'
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDemandes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDemandes() async {
    setState(() => _isLoading = true);
    final list = await _organisationService.fetchDemandesOrganisation();
    if (mounted) {
      setState(() {
        _demandes = list;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredDemandes {
    final query = _searchController.text.trim().toLowerCase();

    return _demandes.where((d) {
      final statut = (d['statut'] ?? '').toString().toUpperCase();
      if (_selectedFilter != 'TOUTES') {
        if (_selectedFilter == 'VALIDEE' && (statut != 'VALIDEE' && statut != 'PUBLIEE')) {
          return false;
        } else if (_selectedFilter != 'VALIDEE' && statut != _selectedFilter) {
          return false;
        }
      }

      if (query.isNotEmpty) {
        final titre = (d['titre'] ?? '').toString().toLowerCase();
        final motif = (d['motif'] ?? '').toString().toLowerCase();
        final nom = '${d['beneficiairePrenom'] ?? ''} ${d['beneficiaireNom'] ?? ''}'.toLowerCase();
        return titre.contains(query) || motif.contains(query) || nom.contains(query);
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivoire,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Demandes à vérifier',
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
            // Barre de recherche
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Rechercher par titre, motif, demandeur...',
                    hintStyle: TextStyle(fontSize: 13, color: AppColors.texteSecondaire),
                    prefixIcon: Icon(Icons.search, color: AppColors.vert, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // Filtres chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
              child: Row(
                children: [
                  _buildFilterChip('Toutes', 'TOUTES'),
                  const SizedBox(width: 8),
                  _buildFilterChip('À vérifier (En attente)', 'EN_ATTENTE'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Validées / Conformes', 'VALIDEE'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Rejetées', 'REJETEE'),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Liste des demandes
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.vert))
                  : RefreshIndicator(
                      onRefresh: _loadDemandes,
                      color: AppColors.vert,
                      child: _filteredDemandes.isEmpty
                          ? ListView(
                              children: const [
                                SizedBox(height: 80),
                                Center(
                                  child: Text(
                                    'Aucune demande ne correspond aux critères.',
                                    style: TextStyle(color: AppColors.texteSecondaire, fontSize: 14),
                                  ),
                                ),
                              ],
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                              itemCount: _filteredDemandes.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final d = _filteredDemandes[index];
                                return _buildDemandeCard(d);
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

  Widget _buildDemandeCard(Map<String, dynamic> demande) {
    final titre = demande['titre']?.toString() ?? 'Demande d\'aide';
    final motif = demande['motif']?.toString() ?? 'Aide générale';
    final benefNom =
        '${demande['beneficiairePrenom'] ?? ''} ${demande['beneficiaireNom'] ?? ''}'.trim();
    final montant = demande['montantNecessaire']?.toString() ?? '0';
    final urgence = (demande['niveauUrgence'] ?? 'MOYENNE').toString().toUpperCase();
    final statut = (demande['statut'] ?? 'EN_ATTENTE').toString().toUpperCase();
    final date = demande['dateCreation']?.toString() ?? '';

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DemandeVerificationDetailScreen(demande: demande),
          ),
        );
        _loadDemandes();
      },
      child: Container(
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: urgence == 'FORTE' ? const Color(0xFFFFECE8) : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Urgence $urgence',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: urgence == 'FORTE' ? AppColors.orange : const Color(0xFF2563EB),
                    ),
                  ),
                ),
                _buildStatusPill(statut),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              titre,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.texte,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 14, color: AppColors.texteSecondaire),
                const SizedBox(width: 4),
                Text(
                  benefNom.isNotEmpty ? benefNom : 'Demandeur',
                  style: const TextStyle(fontSize: 12, color: AppColors.texteSecondaire),
                ),
                const Spacer(),
                const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.texteSecondaire),
                const SizedBox(width: 4),
                Text(
                  date,
                  style: const TextStyle(fontSize: 11, color: AppColors.texteSecondaire),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Catégorie : $motif',
                  style: const TextStyle(fontSize: 12, color: AppColors.texteSecondaire),
                ),
                Row(
                  children: [
                    Text(
                      '$montant FCFA',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.vert,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, size: 18, color: Color(0xFF9CA3AF)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill(String statut) {
    Color bg = const Color(0xFFFEF3C7);
    Color text = const Color(0xFFB45309);
    String label = 'En attente';

    if (statut == 'VALIDEE' || statut == 'PUBLIEE') {
      bg = const Color(0xFFDCFCE7);
      text = const Color(0xFF166534);
      label = 'Validée';
    } else if (statut == 'REJETEE') {
      bg = const Color(0xFFFEE2E2);
      text = const Color(0xFF991B1B);
      label = 'Rejetée';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }
}
