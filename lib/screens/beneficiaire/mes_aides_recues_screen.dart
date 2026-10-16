import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/services/auth_service.dart';
import 'package:deme_mali_app/core/services/demande_service.dart';
import 'package:deme_mali_app/core/theme/app_colors.dart';
import 'package:deme_mali_app/screens/beneficiaire/details_aide_screen.dart';
import 'package:deme_mali_app/widgets/bottom_nav_bar.dart';
import 'package:deme_mali_app/widgets/deme_components.dart';

/// ============================================================================
/// Écran : Mes aides reçues (Bénéficiaire)
/// Conforme à la maquette Figma "mes-aides-recues.png"
///
/// Permet au bénéficiaire de visualiser toutes les aides financières ou matérielles
/// effectivement reçues, avec la date, le montant et l'accès aux détails.
/// ============================================================================
class MesAidesRecuesScreen extends StatefulWidget {
  const MesAidesRecuesScreen({super.key});

  @override
  State<MesAidesRecuesScreen> createState() => _MesAidesRecuesScreenState();
}

class _MesAidesRecuesScreenState extends State<MesAidesRecuesScreen> {
  final DemandeService _demandeService = DemandeService();
  List<Map<String, dynamic>> _aidesRecues = [];
  bool _isLoading = true;

  // Données de démonstration conformes à la maquette
  final List<Map<String, dynamic>> _defaultAides = [
    {
      'id': 1,
      'titre': 'Aide médicale',
      'motif': 'Besoin pour des soins médicaux',
      'montant': 150000,
      'date': 'Reçue le 15 septembre 2026',
      'statut': 'Collecte  terminée',
    },
    {
      'id': 2,
      'titre': 'Aide alimentaire',
      'motif': 'Besoin alimentaire pour ma famille',
      'montant': 75000,
      'date': 'Reçue le 01 septembre 2026',
      'statut': 'Collecte  terminée',
    },
    {
      'id': 3,
      'ref': 'AR-2026-0820',
      'titre': 'Aide scolaire',
      'motif': 'Fournitures scolaires et inscription',
      'montant': 50000,
      'date': 'Reçue le 20 août 2026',
      'statut': 'Collecte  terminée',
    },
  ];

  @override
  void initState() {
    super.initState();
    _chargerAides();
  }

  Future<void> _chargerAides() async {
    setState(() => _isLoading = true);

    List<Map<String, dynamic>> allDemandes = [];
    if (UserSession.currentUserId != null) {
      allDemandes = await _demandeService.fetchDemandesBeneficiaire(UserSession.currentUserId!);
    } else {
      allDemandes = await _demandeService.fetchDemandes();
    }

    final Map<dynamic, Map<String, dynamic>> combined = {};
    for (final d in UserSession.userDemandes) {
      final id = d['id'] ?? d.hashCode;
      combined[id] = d;
    }
    for (final d in allDemandes) {
      final id = d['id'] ?? d.hashCode;
      combined[id] = d;
    }

    final recues = combined.values.where((d) {
      final st = (d['statut'] ?? '').toString().toUpperCase();
      final coll = (d['montantCollecte'] is num) ? (d['montantCollecte'] as num).toDouble() : 0.0;
      return st.contains('VALID') || st.contains('PUBLI') || st.contains('TERM') || coll > 0;
    }).toList();

    if (mounted) {
      setState(() {
        _aidesRecues = recues.isNotEmpty ? recues : _defaultAides;
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
                'Mes aides reçues',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.texte,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Historique des aides que vous avez reçues.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.texteSecondaire,
                ),
              ),
              const SizedBox(height: 24),

              // 3. Liste des cartes d'aides reçues
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.vert),
                      )
                    : RefreshIndicator(
                        onRefresh: _chargerAides,
                        color: AppColors.vert,
                        child: ListView.separated(
                          itemCount: _aidesRecues.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final item = _aidesRecues[index];
                            return _buildAideRecueCard(item);
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BeneficiaireBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildAideRecueCard(Map<String, dynamic> item) {
    final String titre = (item['titre'] ?? 'Aide octroyée').toString();
    final String? ref = item['ref'] != null ? item['ref'].toString() : null;
    final int montant = (item['montant'] is num)
        ? (item['montant'] as num).toInt()
        : ((item['montantCollecte'] is num)
            ? (item['montantCollecte'] as num).toInt()
            : 150000);
    final String date = (item['date'] ??
            (item['dateCreation'] != null ? 'Reçue le ${item['dateCreation']}' : 'Reçue le 15 septembre 2026'))
        .toString();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailsAideScreen(
              demande: item,
              isCompleted: true,
            ),
          ),
        );
      },
      child: Container(
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
            if (ref != null) ...[
              Text(
                'RÉF : $ref',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.texteSecondaire,
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Titre de l'aide
            Text(
              titre,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.texte,
              ),
            ),
            const SizedBox(height: 6),

            // Montant vert gras
            Text(
              '$montant FCFA',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.vert,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.bordure, height: 1),
            const SizedBox(height: 14),

            // Date et lien "Voir les détails >"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 15,
                      color: AppColors.texteSecondaire,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.texteSecondaire,
                      ),
                    ),
                  ],
                ),
                const Row(
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
                      Icons.chevron_right,
                      size: 16,
                      color: AppColors.vert,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
