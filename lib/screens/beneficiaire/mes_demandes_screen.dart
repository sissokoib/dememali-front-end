import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/services/auth_service.dart';
import 'package:deme_mali_app/core/services/demande_service.dart';
import 'package:deme_mali_app/core/theme/app_colors.dart';
import 'package:deme_mali_app/screens/beneficiaire/details_aide_screen.dart';
import 'package:deme_mali_app/screens/beneficiaire/demande_aide_step1_screen.dart';
import 'package:deme_mali_app/widgets/bottom_nav_bar.dart';
import 'package:deme_mali_app/widgets/deme_components.dart';

/// ============================================================================
/// Écran : Mes demandes (Bénéficiaire)
/// Conforme à la maquette Figma "mes-demandes.png"
/// ============================================================================
class MesDemandesScreen extends StatefulWidget {
  const MesDemandesScreen({super.key});

  @override
  State<MesDemandesScreen> createState() => _MesDemandesScreenState();
}

class _MesDemandesScreenState extends State<MesDemandesScreen> {
  final DemandeService _demandeService = DemandeService();
  List<Map<String, dynamic>> _demandes = [];
  bool _isLoading = true;

  final List<Map<String, dynamic>> _defaultDemandes = [
    {
      'id': 101,
      'titre': 'Aide médicale',
      'motif': 'Demande d\'aide pour des soins médicaux',
      'statut': 'EN_ATTENTE',
      'statutLabel': 'En cours de vérification',
      'date': '18 septembre 2026',
      'montant': 150000,
    },
    {
      'id': 102,
      'titre': 'Aide alimentaire',
      'motif': 'Demande d\'aide alimentaire pour ma famille',
      'statut': 'ACCEPTEE',
      'statutLabel': 'Acceptée',
      'date': '12 septembre 2026',
      'montant': 75000,
    },
    {
      'id': 103,
      'titre': 'Aide scolaire',
      'motif': 'Demande d\'aide pour les fournitures scolaires',
      'statut': 'REFUSEE',
      'statutLabel': 'Refusée',
      'date': '05 septembre 2026',
      'montant': 45000,
    },
  ];

  @override
  void initState() {
    super.initState();
    _chargerDemandes();
  }

  Future<void> _chargerDemandes() async {
    setState(() => _isLoading = true);

    List<Map<String, dynamic>> backendList = [];
    if (UserSession.currentUserId != null) {
      backendList = await _demandeService.fetchDemandesBeneficiaire(UserSession.currentUserId!);
    } else {
      backendList = await _demandeService.fetchDemandes();
    }

    final Map<dynamic, Map<String, dynamic>> combined = {};
    for (final d in UserSession.userDemandes) {
      final id = d['id'] ?? d.hashCode;
      combined[id] = d;
    }
    for (final d in backendList) {
      final id = d['id'] ?? d.hashCode;
      combined[id] = d;
    }

    if (mounted) {
      setState(() {
        _demandes = combined.isNotEmpty ? combined.values.toList() : _defaultDemandes;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bouton retour circulaire
              const DemeBackButton(),
              const SizedBox(height: 18),

              // Titre et sous-titre
              const Text(
                'Mes demandes',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.texte,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Retrouvez toutes les demandes d\'aide que vous avez envoyées.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.texteSecondaire,
                ),
              ),
              const SizedBox(height: 22),

              // Liste des demandes
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.vert),
                      )
                    : _demandes.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.description_outlined,
                                  size: 64,
                                  color: AppColors.placeholder,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Aucune demande en cours',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.texte,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                DemeButton(
                                  text: 'Faire une demande',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const DemandeAideStep1Screen(),
                                      ),
                                    ).then((_) => _chargerDemandes());
                                  },
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: _demandes.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final demande = _demandes[index];
                              return _buildDemandeCard(demande);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BeneficiaireBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildDemandeCard(Map<String, dynamic> demande) {
    final String titre = (demande['titre'] ?? 'Aide d\'urgence').toString();
    final String motif = (demande['motif'] ?? demande['description'] ?? 'Demande d\'aide communautaire').toString();
    final String date = (demande['date'] ?? demande['dateCreation'] ?? '18 septembre 2026').toString();
    final String statutRaw = (demande['statut'] ?? 'EN_ATTENTE').toString().toUpperCase();

    String badgeLabel;
    Color badgeColor;
    Color badgeTextColor = Colors.white;

    if (statutRaw.contains('ACCEPT') || statutRaw.contains('APPROUV') || statutRaw.contains('VALID')) {
      badgeLabel = 'Acceptée';
      badgeColor = AppColors.vert;
    } else if (statutRaw.contains('REFUS') || statutRaw.contains('REJET')) {
      badgeLabel = 'Refusée';
      badgeColor = AppColors.texte;
    } else {
      badgeLabel = 'En cours de vérification';
      badgeColor = AppColors.jaune;
      badgeTextColor = AppColors.texte;
    }

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
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre et badge de statut
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  titre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.texte,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                    color: badgeTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Motif / Description
          Text(
            motif,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.texteSecondaire,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.bordure, height: 1),
          const SizedBox(height: 14),

          // Date et lien Détails
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppColors.texteSecondaire,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.texteSecondaire,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailsAideScreen(demande: demande),
                    ),
                  );
                },
                child: const Row(
                  children: [
                    Text(
                      'Voir les détails',
                      style: TextStyle(
                        color: AppColors.vert,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: AppColors.vert,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
