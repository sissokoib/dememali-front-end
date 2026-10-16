import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/services/auth_service.dart';
import 'package:deme_mali_app/core/services/demande_service.dart';
import 'package:deme_mali_app/core/theme/app_colors.dart';
import 'package:deme_mali_app/screens/beneficiaire/dashboard_screen.dart';
import 'package:deme_mali_app/widgets/deme_components.dart';

/// ============================================================================
/// Écran : Choix de l'organisation partenaire pour l'inscription
/// Conforme à la maquette Figma "Choisir Particulier organisation.png"
/// ============================================================================
class ChoixOrganisationInscriptionScreen extends StatefulWidget {
  final Map<String, dynamic>? registrationPayload;

  const ChoixOrganisationInscriptionScreen({
    super.key,
    this.registrationPayload,
  });

  @override
  State<ChoixOrganisationInscriptionScreen> createState() =>
      _ChoixOrganisationInscriptionScreenState();
}

class _ChoixOrganisationInscriptionScreenState
    extends State<ChoixOrganisationInscriptionScreen> {
  final DemandeService _demandeService = DemandeService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _organisations = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  int? _selectedOrgId;
  String _selectedFilter = 'Toutes';
  String _searchQuery = '';

  final List<String> _filters = ['Toutes', 'ONG', 'Association', 'Fondation'];

  final List<Map<String, dynamic>> _defaultOrgs = [
    {
      'id': 1,
      'nom': 'Association Espoir',
      'type': 'Association',
      'ville': 'Bamako',
      'domaine': 'Accompagnement social',
    },
    {
      'id': 2,
      'nom': 'Fondation Orange Mali',
      'type': 'Fondation',
      'ville': 'Mali',
      'domaine': 'Éducation, santé, solidarité',
    },
    {
      'id': 3,
      'nom': 'ONG Solidarité Mali',
      'type': 'ONG',
      'ville': 'Sikasso',
      'domaine': 'Aide aux familles vulnérables',
    },
    {
      'id': 4,
      'nom': 'Croix-Rouge malienne',
      'type': 'ONG',
      'ville': 'Bamako',
      'domaine': 'Santé et secours humanitaire',
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
        if (_organisations.isNotEmpty) {
          _selectedOrgId = _organisations.first['id'] as int?;
        }
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _finalizeRegistration() async {
    if (_selectedOrgId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une organisation partenaire.'),
          backgroundColor: AppColors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Préparer le DTO complet pour Spring Boot
    final dto = {
      'nom': UserSession.currentUserNom ?? 'Nom',
      'prenom': UserSession.currentUserPrenom ?? 'Prénom',
      'telephone': UserSession.currentUserPhone ?? '',
      'motDePasse': UserSession.tempPassword ?? 'password123',
      'email': UserSession.currentUserEmail ?? '${UserSession.currentUserPhone ?? "user"}@dememali.ml',
      'adresse': UserSession.currentUserAddress ?? 'Bamako',
      'ville': UserSession.currentUserCity ?? 'Bamako',
      'sexe': (UserSession.currentUserGender?.toUpperCase().contains('F') == true)
          ? 'FEMININ'
          : 'MASCULIN',
      'typeBeneficiaire': UserSession.currentUserTypeBeneficiaire ?? 'FAMILLE',
      'situationMatrimoniale': UserSession.currentUserSituationMatrimoniale ?? 'MARIE',
      'nombreEnfants': UserSession.currentUserNbEnfants ?? 0,
      'handicap': UserSession.currentUserHandicap ?? 'AUCUN',
      'besoins': UserSession.currentUserBesoins ?? '',
      'organisationPartenaireId': _selectedOrgId,
    };

    final result = await _authService.registerBeneficiaireParticulier(dto);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result['success'] == true) {
      // Mettre à jour la session utilisateur
      UserSession.currentUserRole = 'Bénéficiaire';
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compte créé avec succès ! Bienvenue sur Dèmè Mali.'),
          backgroundColor: AppColors.vert,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (route) => false,
      );
    } else {
      // En cas d'erreur backend (ex: compte déjà existant ou serveur hors ligne),
      // proposer de continuer en mode démo ou afficher l'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enregistrement : ${result['message']}'),
          backgroundColor: Colors.redAccent,
          action: SnackBarAction(
            label: 'Accéder quand même',
            textColor: Colors.white,
            onPressed: () {
              UserSession.currentUserRole = 'Bénéficiaire';
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
                (route) => false,
              );
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _organisations.where((org) {
      final name = (org['nom'] ?? org['nomStructure'] ?? '').toString().toLowerCase();
      final type = (org['type'] ?? 'ONG').toString().toLowerCase();
      final city = (org['ville'] ?? '').toString().toLowerCase();

      final matchesQuery = name.contains(_searchQuery.toLowerCase()) ||
          city.contains(_searchQuery.toLowerCase());

      if (_selectedFilter == 'Toutes') return matchesQuery;
      return matchesQuery && type.contains(_selectedFilter.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bouton retour circulaire
              const DemeBackButton(),
              const SizedBox(height: 18),

              // Titre et sous-titre
              const Text(
                'Choisissez votre\norganisation partenaire',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.texte,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sélectionnez l\'organisation qui vous accompagne pour poursuivre votre inscription.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.texteSecondaire,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Barre de recherche
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.bordure),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: const InputDecoration(
                    hintText: 'Rechercher une organisation...',
                    hintStyle: TextStyle(color: AppColors.placeholder, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: AppColors.placeholder),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Titre filtres
              const Text(
                'ORGANISATIONS DISPONIBLES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.texteSecondaire,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),

              // Filtres chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.map((f) {
                    final isSel = f == _selectedFilter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(f),
                        selected: isSel,
                        onSelected: (val) {
                          if (val) setState(() => _selectedFilter = f);
                        },
                        selectedColor: AppColors.vert,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : AppColors.texte,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        side: BorderSide(
                          color: isSel ? AppColors.vert : AppColors.bordure,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Liste des organisations
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.vert),
                      )
                    : filtered.isEmpty
                        ? const Center(
                            child: Text(
                              'Aucune organisation disponible pour ce filtre.',
                              style: TextStyle(color: AppColors.texteSecondaire),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final org = filtered[index];
                              final id = org['id'] as int? ?? index + 1;
                              final isSelected = _selectedOrgId == id;
                              return _buildOrgSelectableCard(org, id, isSelected);
                            },
                          ),
              ),

              const SizedBox(height: 16),

              // Bouton Continuer / Finaliser
              SizedBox(
                width: double.infinity,
                child: DemeButton(
                  text: 'Continuer',
                  icon: Icons.arrow_forward,
                  isLoading: _isSubmitting,
                  onPressed: _finalizeRegistration,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrgSelectableCard(
    Map<String, dynamic> org,
    int id,
    bool isSelected,
  ) {
    final String name = (org['nom'] ?? org['nomStructure'] ?? 'Organisation').toString();
    final String type = (org['type'] ?? 'Association').toString();
    final String ville = (org['ville'] ?? 'Bamako').toString();
    final String domaine = (org['domaine'] ?? org['mission'] ?? 'Accompagnement social').toString();

    return GestureDetector(
      onTap: () => setState(() => _selectedOrgId = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.vert : AppColors.bordure,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.vert.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.vertClair : const Color(0xFFFBF4DF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.person_outline,
                color: isSelected ? AppColors.vert : AppColors.jaune,
                size: 28,
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
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.texte,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$type · $ville',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.texteSecondaire,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    domaine,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.texteSecondaire,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: 4),
                    const Text(
                      'Sélectionnée',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.vert,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.vert : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.vert : AppColors.placeholder,
                  width: 1.8,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
