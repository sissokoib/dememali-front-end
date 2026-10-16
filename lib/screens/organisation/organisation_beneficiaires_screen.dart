import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/services/organisation_service.dart';
import 'package:deme_mali_app/core/theme/app_colors.dart';
import 'package:deme_mali_app/screens/organisation/enregistrer_beneficiaire_terrain_screen.dart';

/// ============================================================================
/// Écran : Bénéficiaires Suivis & Enrôlés par l'Organisation Partenaire
/// ============================================================================
class OrganisationBeneficiairesScreen extends StatefulWidget {
  const OrganisationBeneficiairesScreen({super.key});

  @override
  State<OrganisationBeneficiairesScreen> createState() =>
      _OrganisationBeneficiairesScreenState();
}

class _OrganisationBeneficiairesScreenState
    extends State<OrganisationBeneficiairesScreen> {
  final OrganisationService _organisationService = OrganisationService();

  List<Map<String, dynamic>> _beneficiaires = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBeneficiaires();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBeneficiaires() async {
    setState(() => _isLoading = true);
    final list = await _organisationService.fetchBeneficiairesOrganisation();
    if (mounted) {
      setState(() {
        _beneficiaires = list;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredBeneficiaires {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _beneficiaires;

    return _beneficiaires.where((b) {
      final nom = '${b['prenom'] ?? ''} ${b['nom'] ?? ''}'.toLowerCase();
      final ville = (b['ville'] ?? '').toString().toLowerCase();
      final adresse = (b['adresse'] ?? '').toString().toLowerCase();
      return nom.contains(query) || ville.contains(query) || adresse.contains(query);
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
          'Bénéficiaires suivis',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.texte,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined, color: AppColors.vert),
            onPressed: () async {
              final res = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EnregistrerBeneficiaireTerrainScreen(),
                ),
              );
              if (res == true) _loadBeneficiaires();
            },
          ),
        ],
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
                    hintText: 'Rechercher un bénéficiaire...',
                    hintStyle: TextStyle(fontSize: 13, color: AppColors.texteSecondaire),
                    prefixIcon: Icon(Icons.search, color: AppColors.vert, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // Compteur et bouton d'ajout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_filteredBeneficiaires.length} personnes suivies',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.texte),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final res = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EnregistrerBeneficiaireTerrainScreen(),
                        ),
                      );
                      if (res == true) _loadBeneficiaires();
                    },
                    child: const Text(
                      '+ Enrôler sur le terrain',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.vert),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Liste
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.vert))
                  : RefreshIndicator(
                      onRefresh: _loadBeneficiaires,
                      color: AppColors.vert,
                      child: _filteredBeneficiaires.isEmpty
                          ? ListView(
                              children: const [
                                SizedBox(height: 80),
                                Center(
                                  child: Text(
                                    'Aucun bénéficiaire trouvé.',
                                    style: TextStyle(color: AppColors.texteSecondaire, fontSize: 14),
                                  ),
                                ),
                              ],
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                              itemCount: _filteredBeneficiaires.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final b = _filteredBeneficiaires[index];
                                final nomComplet = '${b['prenom'] ?? ''} ${b['nom'] ?? ''}'.trim();
                                final ville = b['ville']?.toString() ?? 'Bamako';
                                final adresse = b['adresse']?.toString() ?? '';
                                final statut = (b['statut'] ?? 'ACCEPTE').toString();

                                return Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.02),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 22,
                                        backgroundColor: const Color(0xFFE2F0E9),
                                        child: Text(
                                          nomComplet.isNotEmpty ? nomComplet[0].toUpperCase() : 'B',
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.vert, fontSize: 16),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              nomComplet.isNotEmpty ? nomComplet : 'Bénéficiaire',
                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.texte),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '$ville${adresse.isNotEmpty ? " • $adresse" : ""}',
                                              style: const TextStyle(fontSize: 12, color: AppColors.texteSecondaire),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDCFCE7),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          statut == 'ACCEPTE' ? 'En suivi' : statut,
                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
