import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/theme/app_colors.dart';
import 'package:deme_mali_app/screens/donateur/choix_type_don_screen.dart';
import 'package:deme_mali_app/widgets/deme_components.dart';

/// ============================================================================
/// Écran : Détail de l'aide (Bénéficiaire / Donateur)
/// Conforme aux maquettes Figma :
/// - "Detail  suivre aide.png"
/// - "Detail demande aide.png"
/// - "Détails de l’aide recus.png"
/// ============================================================================
class DetailsAideScreen extends StatelessWidget {
  final Map<String, dynamic>? demande;
  final bool isCompleted;
  final bool showDonationButton;

  const DetailsAideScreen({
    super.key,
    this.demande,
    this.isCompleted = false,
    this.showDonationButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final String titre = (demande?['titre'] ?? 'Aide médicale').toString();
    final String motif = (demande?['motif'] ??
            demande?['descriptionSituation'] ??
            demande?['description'] ??
            'Besoin pour des soins médicaux')
        .toString();
    final String descriptionDetail = (demande?['descriptionDetail'] ??
            demande?['descriptionSituation'] ??
            demande?['description'] ??
            'Je demande une aide pour prendre en charge mes frais de traitement médical. Cette aide me permettra de financer mes soins et les médicaments nécessaires.')
        .toString();

    final bool termine = isCompleted ||
        (demande?['statut'] != null &&
            demande!['statut'].toString().toUpperCase().contains('TERM'));

    final int montantCollecte = (demande?['montantCollecte'] is num)
        ? (demande!['montantCollecte'] as num).toInt()
        : (demande?['montant'] is num
            ? (demande!['montant'] as num).toInt()
            : (termine ? 150000 : 350000));

    final int montantNecessaire = (demande?['montantNecessaire'] is num)
        ? (demande!['montantNecessaire'] as num).toInt()
        : (termine ? 150000 : 500000);

    final double progress = montantNecessaire > 0
        ? (montantCollecte / montantNecessaire).clamp(0.0, 1.0)
        : 1.0;
    final int percentage = termine ? 100 : (progress * 100).toInt();

    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bouton retour circulaire blanc
              const DemeBackButton(),
              const SizedBox(height: 20),

              // Titre principal
              const Text(
                'Détail de l’ aide',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.texte,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),

              // Carte 1 : Description de cette demande
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
                      'Description de cette demande',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.texte,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      descriptionDetail,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.texteSecondaire,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Carte 2 : Progression et détails de collecte
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
                    // Badge de statut (Collecte en cours ou Collecte terminée)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: termine ? AppColors.vert : AppColors.jaune,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        termine ? 'Collecte  terminée' : 'Collecte en cours',
                        style: TextStyle(
                          color: termine ? Colors.white : AppColors.texte,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Titre
                    Text(
                      titre,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.texte,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Sous-titre motif
                    Text(
                      motif,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.texteSecondaire,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: AppColors.bordure, height: 1),
                    const SizedBox(height: 18),

                    // Montant collecté et pourcentage
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$montantCollecte FCFA',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: AppColors.vert,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'collectés',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.texteSecondaire,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1EDE2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$percentage %',
                            style: const TextStyle(
                              color: AppColors.vert,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    if (!termine) ...[
                      Text(
                        'sur $montantNecessaire FCFA nécessaires',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.texteSecondaire,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Barre de progression
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: const Color(0xFFEBE6D8),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.vert),
                        minHeight: 10,
                      ),
                    ),

                    if (!termine) ...[
                      const SizedBox(height: 12),
                      Text(
                        '$percentage % de l’objectif atteint',
                        style: const TextStyle(
                          color: AppColors.vert,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              if (showDonationButton) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChoixTypeDonScreen(cause: {
                            'titre': titre,
                            'montantCible': montantNecessaire,
                          }),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.vert,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.favorite, color: Colors.white, size: 18),
                    label: const Text(
                      'Faire un don pour cette aide',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
