import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/theme/app_colors.dart';
import 'package:deme_mali_app/widgets/deme_components.dart';

/// ============================================================================
/// Écran : Détail d'un don effectué (Espace Donateur)
/// Conforme à la maquette Figma "Détail du don scolaire.png"
///
/// Affiche la cause soutenue, le montant versé, le moyen de paiement,
/// la référence unique et le statut de distribution.
/// ============================================================================
class DetailDonScreen extends StatelessWidget {
  final Map<String, dynamic>? donData;

  const DetailDonScreen({super.key, this.donData});

  @override
  Widget build(BuildContext context) {
    final String categorie = (donData?['categorie'] ?? 'SCOLAIRE').toString().toUpperCase();
    final String titre = (donData?['causeNom'] ?? donData?['titre'] ?? 'Soutien scolaire pour les enfants de Bamako').toString();
    final String description = (donData?['description'] ??
            'Votre générosité contribue à améliorer l’accès à l’éducation et à offrir aux enfants de meilleures conditions d’apprentissage.')
        .toString();
    final String partenaire = (donData?['partenaire'] ?? 'Association partenaire').toString();
    final String localisation = (donData?['localisation'] ?? 'Bamako, Mali').toString();
    final String montant = donData?['montant'] != null
        ? '${(donData!['montant'] is num ? (donData!['montant'] as num).toInt() : donData!['montant'])} FCFA'
        : '25 000 FCFA';
    final String date = (donData?['dateDon'] ?? '12 octobre 2026').toString();
    final String moyenPaiement = (donData?['moyenPaiement'] ?? 'Orange Money').toString();
    final String reference = (donData?['reference'] ?? 'DON-2026-001').toString();
    final String statut = (donData?['statut'] ?? 'Distribuée').toString();
    final String imageUrl = (donData?['imageUrl'] ??
            'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?q=80&w=600&auto=format&fit=crop')
        .toString();

    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Bouton retour et titre
              Row(
                children: [
                  const DemeBackButton(),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Détail du don',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.texte,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 44), // Pour équilibrer le bouton retour
                ],
              ),
              const SizedBox(height: 24),

              // 2. Photo de la cause
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.network(
                  imageUrl,
                  height: 190,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    height: 190,
                    width: double.infinity,
                    color: AppColors.vertClair,
                    child: const Icon(
                      Icons.school,
                      size: 64,
                      color: AppColors.vert,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // 3. Badge catégorie en vert
              Text(
                categorie,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.vert,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),

              // 4. Titre de la cause
              Text(
                titre,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.texte,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 10),

              // 5. Description
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.texteSecondaire,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),

              // 6. Association partenaire
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.vertClair,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.bordure),
                    ),
                    child: const Icon(
                      Icons.people_outline,
                      color: AppColors.vert,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        partenaire,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.texte,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: AppColors.texteSecondaire,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            localisation,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.texteSecondaire,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 7. Carte d'informations du don
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
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
                    const Text(
                      'Montant donné',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.texteSecondaire,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      montant,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.vert,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Divider(color: AppColors.bordure, height: 1),
                    const SizedBox(height: 16),

                    // Ligne Date du don
                    _buildDetailRow('Date du don', date),
                    const SizedBox(height: 14),

                    // Ligne Moyen de paiement
                    _buildDetailRow('Moyen de paiement', moyenPaiement),
                    const SizedBox(height: 14),

                    // Ligne Référence
                    _buildDetailRow('Référence', reference),
                    const SizedBox(height: 14),

                    // Ligne Statut
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Statut',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.texteSecondaire,
                          ),
                        ),
                        Text(
                          statut,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.vert,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.texteSecondaire,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.texte,
          ),
        ),
      ],
    );
  }
}
