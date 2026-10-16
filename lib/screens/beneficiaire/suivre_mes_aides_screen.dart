import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/services/auth_service.dart';
import 'package:deme_mali_app/core/services/demande_service.dart';
import 'package:deme_mali_app/core/theme/app_colors.dart';
import 'package:deme_mali_app/screens/beneficiaire/details_aide_screen.dart';
import 'package:deme_mali_app/widgets/deme_components.dart';

/// ============================================================================
/// Écran : Suivre mes aides (Bénéficiaire)
/// Conforme à la maquette Figma "Suivre mes aides.png"
///
/// Permet au bénéficiaire de suivre en temps réel la collecte de fonds
/// et l'avancement de ses demandes d'aide avec accès direct aux détails.
/// ============================================================================
class SuivreMesAidesScreen extends StatefulWidget {
  const SuivreMesAidesScreen({super.key});

  @override
  State<SuivreMesAidesScreen> createState() => _SuivreMesAidesScreenState();
}

class _SuivreMesAidesScreenState extends State<SuivreMesAidesScreen> {
  final DemandeService _demandeService = DemandeService();
  List<Map<String, dynamic>> _demandes = [];
  bool _isLoading = true;

  // Données par défaut conformes à la maquette Figma si aucune donnée n'est créée
  final List<Map<String, dynamic>> _defaultSuivis = [
    {
      'id': 1,
      'titre': 'Aide médicale',
      'motif': 'Besoin pour des soins médicaux',
      'description': 'Je demande une aide pour prendre en charge mes frais de traitement médical. Cette aide me permettra de financer mes soins et les médicaments nécessaires.',
      'montantCollecte': 350000,
      'montantNecessaire': 500000,
      'pourcentage': 70,
      'statut': 'Collecte en cours',
    },
    {
      'id': 2,
      'titre': 'Aide alimentaire',
      'motif': 'Besoin alimentaire pour ma famille',
      'description': 'Aide alimentaire d’urgence pour approvisionner en vivres et céréales une famille de 6 personnes.',
      'montantCollecte': 200000,
      'montantNecessaire': 500000,
      'pourcentage': 40,
      'statut': 'Collecte en cours',
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
        _demandes = combined.isNotEmpty ? combined.values.toList() : _defaultSuivis;
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
              // 1. Bouton retour circulaire blanc
              const DemeBackButton(),
              const SizedBox(height: 20),

              // 2. Titre et sous-titre
              const Text(
                'Suivre mes aides',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.texte,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Suivez l’avancement des collectes destinées à vos demandes d’aide.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.texteSecondaire,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // 3. Liste des cartes de suivi
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.vert),
                      )
                    : RefreshIndicator(
                        onRefresh: _chargerDemandes,
                        color: AppColors.vert,
                        child: ListView.separated(
                          itemCount: _demandes.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final item = _demandes[index];
                            return _buildSuiviCard(item);
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuiviCard(Map<String, dynamic> item) {
    final String titre = (item['titre'] ?? 'Aide solidaire').toString();
    final String motif = (item['motif'] ??
            item['descriptionSituation'] ??
            item['description'] ??
            'Besoin pour des soins médicaux')
        .toString();

    final int collecte = (item['montantCollecte'] is num)
        ? (item['montantCollecte'] as num).toInt()
        : 350000;
    final int necessaire = (item['montantNecessaire'] is num)
        ? (item['montantNecessaire'] as num).toInt()
        : 500000;

    final double progress = necessaire > 0 ? (collecte / necessaire).clamp(0.0, 1.0) : 0.7;
    final int pct = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          // Titre
          Text(
            titre,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.texte,
            ),
          ),
          const SizedBox(height: 4),

          // Sous-titre
          Text(
            motif,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.texteSecondaire,
            ),
          ),
          const SizedBox(height: 16),

          // Montant collecté en vert
          Text(
            '$collecte FCFA collectés',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.vert,
            ),
          ),
          const SizedBox(height: 6),

          // Ligne Montant nécessaire et pourcentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'sur $necessaire FCFA',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.texteSecondaire,
                ),
              ),
              Text(
                '$pct %',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.vert,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Barre de progression
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFEBE6D8),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.vert),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 18),

          // Badge "Collecte en cours" + Bouton "Voir les détails ->"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.jaune,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Collecte en cours',
                  style: TextStyle(
                    color: AppColors.texte,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailsAideScreen(demande: item),
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
                      Icons.arrow_forward,
                      size: 14,
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
