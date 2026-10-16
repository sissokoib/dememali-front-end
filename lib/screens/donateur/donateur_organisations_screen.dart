import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/services/demande_service.dart';
import 'package:deme_mali_app/core/theme/app_colors.dart';
import 'package:deme_mali_app/screens/donateur/choisir_cause_screen.dart';
import 'package:deme_mali_app/screens/donateur/choix_type_don_screen.dart';
import 'package:deme_mali_app/screens/donateur/organisation_detail_screen.dart';
import 'package:deme_mali_app/widgets/bottom_nav_bar.dart';

/// ============================================================================
/// Écran Organisations Partenaires (Espace Donateur)
/// Conforme à la maquette Figma "Donateur Organisation.png"
/// ============================================================================
class DonateurOrganisationsScreen extends StatefulWidget {
  const DonateurOrganisationsScreen({super.key});

  @override
  State<DonateurOrganisationsScreen> createState() => _DonateurOrganisationsScreenState();
}

class _DonateurOrganisationsScreenState extends State<DonateurOrganisationsScreen> {
  final DemandeService _demandeService = DemandeService();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _organisations = [];
  bool _isLoading = true;
  String _searchQuery = '';

  final List<Map<String, dynamic>> _defaultOrgs = [
    {
      'id': 1,
      'nom': 'Fondation Orange Mali',
      'ville': 'Bamako',
      'type': 'Fondation',
      'mission': 'Éducation, santé et solidarité numérique',
    },
    {
      'id': 2,
      'nom': 'Association Malienne pour la Survie au Sahel',
      'ville': 'Bamako',
      'type': 'Association',
      'mission': 'Aide humanitaire d\'urgence et développement',
    },
    {
      'id': 3,
      'nom': 'Croix-Rouge malienne',
      'ville': 'Bamako',
      'type': 'ONG',
      'mission': 'Secours d\'urgence, santé communautaire',
    },
    {
      'id': 4,
      'nom': 'Association Espoir Mali',
      'ville': 'Sikasso',
      'type': 'Association',
      'mission': 'Soutien aux orphelins et veuves',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadOrganisations();
  }

  Future<void> _loadOrganisations() async {
    setState(() => _isLoading = true);
    final orgs = await _demandeService.fetchOrganisations();
    if (mounted) {
      setState(() {
        _organisations = orgs.isNotEmpty ? orgs : _defaultOrgs;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrgs = _organisations.where((org) {
      final name = (org['nom'] ?? org['nomStructure'] ?? '').toString().toLowerCase();
      final city = (org['ville'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery.toLowerCase()) || city.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Entête avec titre et cloche de notification
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Organisation Partenaire',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.texte,
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.bordure),
                    ),
                    child: const Icon(
                      Icons.notifications_none_outlined,
                      color: AppColors.texte,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Découvrez la liste des organisations partenaires.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.texteSecondaire,
                ),
              ),
              const SizedBox(height: 20),

              // Barre de recherche
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.bordure),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: const InputDecoration(
                    hintText: 'Rechercher une organisation...',
                    hintStyle: TextStyle(color: AppColors.placeholder, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: AppColors.placeholder),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Liste des organisations
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.vert),
                      )
                    : filteredOrgs.isEmpty
                        ? const Center(
                            child: Text(
                              'Aucune organisation trouvée',
                              style: TextStyle(color: AppColors.texteSecondaire),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filteredOrgs.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final org = filteredOrgs[index];
                              return _buildOrgCard(org);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const DonateurBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildOrgCard(Map<String, dynamic> org) {
    final String name = (org['nom'] ?? org['nomStructure'] ?? 'Organisation').toString();
    final String ville = (org['ville'] ?? 'Bamako').toString();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.bordure),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.vertClair,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: AppColors.vert,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.texte,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ville,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.texteSecondaire,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrganisationDetailScreen(organisation: org),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.vert, width: 1.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Voir le profil',
                      style: TextStyle(
                        color: AppColors.vert,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChoixTypeDonScreen(
                            cause: {
                              'titre': 'Soutien à $name',
                              'partenaire': name,
                            },
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.vert,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite, size: 14, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'Soutenir',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showOrgDetails(Map<String, dynamic> org) {
    final String name = (org['nom'] ?? org['nomStructure'] ?? 'Organisation').toString();
    final String ville = (org['ville'] ?? 'Bamako').toString();
    final String mission = (org['mission'] ?? 'Accompagnement social et aide aux communautés locales.').toString();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.texte),
            ),
            const SizedBox(height: 6),
            Text(ville, style: const TextStyle(color: AppColors.texteSecondaire, fontSize: 14)),
            const SizedBox(height: 16),
            const Text(
              'Mission & Objectifs :',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(mission, style: const TextStyle(fontSize: 14, color: AppColors.texte, height: 1.4)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChoisirCauseScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.vert,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Faire un don à cette organisation', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
