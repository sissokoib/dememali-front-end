import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/services/auth_service.dart';
import 'package:deme_mali_app/core/theme/app_colors.dart';
import 'package:deme_mali_app/screens/donateur/detail_don_screen.dart';
import 'package:deme_mali_app/screens/donateur/choix_type_don_screen.dart';
import 'package:deme_mali_app/widgets/bottom_nav_bar.dart';

/// ============================================================================
/// Écran : Mes dons (Espace Donateur)
/// Conforme à la maquette Figma "Mes dons – iPhone 16.png"
///
/// Présente l'historique complet des dons réalisés par le donateur
/// avec bouton de filtrage, aperçus en images et bouton direct vers le détail.
/// ============================================================================
class DonateurMesDonsScreen extends StatefulWidget {
  const DonateurMesDonsScreen({super.key});

  @override
  State<DonateurMesDonsScreen> createState() => _DonateurMesDonsScreenState();
}

class _DonateurMesDonsScreenState extends State<DonateurMesDonsScreen> {
  String _selectedFilter = 'Tous';

  // Dons par défaut conformes à la maquette si la session est nouvelle
  final List<Map<String, dynamic>> _mockDons = [
    {
      'id': 1,
      'causeNom': 'Soutien scolaire pour les enfants de Bamako',
      'titre': 'Soutien scolaire pour les enfants de Bamako',
      'categorie': 'Éducation',
      'dateDon': '12 oct. 2026',
      'montant': 25000,
      'moyenPaiement': 'Orange Money',
      'reference': 'DON-2026-001',
      'statut': 'Distribuée',
      'imageUrl': 'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?q=80&w=400&auto=format&fit=crop',
    },
    {
      'id': 2,
      'causeNom': 'Aide alimentaire aux familles vulnérables',
      'titre': 'Aide alimentaire aux familles vulnérables',
      'categorie': 'Alimentation',
      'dateDon': '28 sept. 2026',
      'montant': 50000,
      'moyenPaiement': 'Moov Money',
      'reference': 'DON-2026-002',
      'statut': 'Distribuée',
      'imageUrl': 'https://images.unsplash.com/photo-1593113598332-cd288d649433?q=80&w=400&auto=format&fit=crop',
    },
    {
      'id': 3,
      'causeNom': 'Soins médicaux pour les enfants malades',
      'titre': 'Soins médicaux pour les enfants malades',
      'categorie': 'Santé',
      'dateDon': '15 sept. 2026',
      'montant': 100000,
      'moyenPaiement': 'Wave Mali',
      'reference': 'DON-2026-003',
      'statut': 'Distribuée',
      'imageUrl': 'https://images.unsplash.com/photo-1516574187841-cb9cc2ca948b?q=80&w=400&auto=format&fit=crop',
    },
    {
      'id': 4,
      'causeNom': 'Accès à l’eau potable en zone rurale',
      'titre': 'Accès à l’eau potable en zone rurale',
      'categorie': 'Santé',
      'dateDon': '02 sept. 2026',
      'montant': 30000,
      'moyenPaiement': 'Carte Bancaire',
      'reference': 'DON-2026-004',
      'statut': 'Distribuée',
      'imageUrl': 'https://images.unsplash.com/photo-1541544741938-0af808871cc0?q=80&w=400&auto=format&fit=crop',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Combiner les dons en session avec les données mock pour un affichage toujours riche
    final List<Map<String, dynamic>> allDons = [];
    allDons.addAll(UserSession.userDons);
    for (final d in _mockDons) {
      if (!allDons.any((item) => item['id'] == d['id'])) {
        allDons.add(d);
      }
    }

    final filteredDons = allDons.where((d) {
      if (_selectedFilter == 'Tous') return true;
      final cat = (d['categorie'] ?? '').toString().toLowerCase();
      return cat.contains(_selectedFilter.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Entête : Titre "Mes dons" + Bouton "Filtrer"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mes dons',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.texte,
                      letterSpacing: -0.5,
                    ),
                  ),
                  _buildFilterButton(),
                ],
              ),
              const SizedBox(height: 6),

              // 2. Sous-titre
              const Text(
                'Retrouvez la liste de tous vos dons effectués',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.texteSecondaire,
                ),
              ),
              const SizedBox(height: 14),

              // 3. Compteur de dons
              Text(
                '${filteredDons.length} dons effectués',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.texteSecondaire,
                ),
              ),
              const SizedBox(height: 18),

              // 4. Liste des cartes de dons
              Expanded(
                child: filteredDons.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: const BoxDecoration(
                                color: AppColors.vertClair,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.volunteer_activism_outlined,
                                color: AppColors.vert,
                                size: 34,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Aucun don trouvé',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.texte,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ChoixTypeDonScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.vert,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Faire un don',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: filteredDons.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final don = filteredDons[index];
                          return _buildDonCard(don);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const DonateurBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildFilterButton() {
    return PopupMenuButton<String>(
      onSelected: (val) {
        setState(() => _selectedFilter = val);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'Tous', child: Text('Tous les dons')),
        const PopupMenuItem(value: 'Éducation', child: Text('Éducation')),
        const PopupMenuItem(value: 'Alimentation', child: Text('Alimentation')),
        const PopupMenuItem(value: 'Santé', child: Text('Santé')),
        const PopupMenuItem(value: 'MATÉRIEL', child: Text('Dons matériels')),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.bordure),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.tune,
              size: 16,
              color: AppColors.vert,
            ),
            const SizedBox(width: 6),
            Text(
              _selectedFilter == 'Tous' ? 'Filtrer' : _selectedFilter,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.vert,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonCard(Map<String, dynamic> don) {
    final String categorie = (don['categorie'] ?? 'Solidaire').toString();
    final String titre = (don['causeNom'] ?? don['titre'] ?? 'Don solidaire').toString();
    final String date = (don['dateDon'] ?? '12 oct. 2026').toString();
    final String montant = don['montant'] != null
        ? '${(don['montant'] is num ? (don['montant'] as num).toInt() : don['montant'])} FCFA'
        : '25 000 FCFA';
    final String imageUrl = (don['imageUrl'] ??
            'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?q=80&w=400&auto=format&fit=crop')
        .toString();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailDonScreen(donData: don),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
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
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Image miniature arrondie à gauche
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    imageUrl,
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      width: 76,
                      height: 76,
                      color: AppColors.vertClair,
                      child: const Icon(
                        Icons.volunteer_activism,
                        color: AppColors.vert,
                        size: 32,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // 2. Catégorie, Titre et Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Catégorie en vert
                      Text(
                        categorie,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.vert,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Titre
                      Text(
                        titre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.texte,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Date
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.texteSecondaire,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 3. Ligne Montant en vert gras + Bouton "Voir ->"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  montant,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.vert,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.vertClair,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'Voir',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.vert,
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
      ),
    );
  }
}
