import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/theme/app_colors.dart';
import 'package:deme_mali_app/widgets/deme_components.dart';

/// ============================================================================
/// Écran : Nos actions (Organisation partenaire)
/// Conforme à la maquette Figma "action de l'organisation.png"
///
/// Affiche la liste des actions humanitaires et solidaires menées
/// sur le terrain par l'organisation, avec le taux d'accomplissement (100%)
/// et le montant total distribué.
/// ============================================================================
class OrganisationActionsScreen extends StatelessWidget {
  final String organisationNom;

  const OrganisationActionsScreen({
    super.key,
    this.organisationNom = 'Fondation Orange',
  });

  final List<Map<String, dynamic>> _actions = const [
    {
      'titre': 'Aide scolaire à Kayes',
      'description': 'Soutien aux enfants et familles de la région.',
      'pourcentage': '100%',
      'montant': '100000 FCFA',
      'imageUrl': 'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?q=80&w=400&auto=format&fit=crop',
    },
    {
      'titre': 'Accès à l’eau potable',
      'description': 'Aide aux communautés dans les zones rurales.',
      'pourcentage': '100%',
      'montant': '500000 FCFA',
      'imageUrl': 'https://images.unsplash.com/photo-1541544741938-0af808871cc0?q=80&w=400&auto=format&fit=crop',
    },
    {
      'titre': 'Campagne médicale à Sikasso',
      'description': 'Consultations gratuites et distribution de médicaments.',
      'pourcentage': '100%',
      'montant': '350000 FCFA',
      'imageUrl': 'https://images.unsplash.com/photo-1516574187841-cb9cc2ca948b?q=80&w=400&auto=format&fit=crop',
    },
    {
      'titre': 'Kits vivres pour orphelinat',
      'description': 'Denrées alimentaires et produits d’hygiène de première nécessité.',
      'pourcentage': '100%',
      'montant': '250000 FCFA',
      'imageUrl': 'https://images.unsplash.com/photo-1593113598332-cd288d649433?q=80&w=400&auto=format&fit=crop',
    },
  ];

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
              // Entête avec bouton retour et titre
              Row(
                children: [
                  const DemeBackButton(),
                  const SizedBox(width: 16),
                  const Text(
                    'Nos actions',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.texte,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Liste des actions
              Expanded(
                child: ListView.separated(
                  itemCount: _actions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 18),
                  itemBuilder: (context, index) {
                    final item = _actions[index];
                    return _buildActionCard(item);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(Map<String, dynamic> item) {
    return Container(
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Photo à gauche
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              item['imageUrl'],
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(
                width: 90,
                height: 90,
                color: AppColors.vertClair,
                child: const Icon(
                  Icons.volunteer_activism,
                  color: AppColors.vert,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // 2. Contenu textuel et progression
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['titre'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.texte,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['description'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.texteSecondaire,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),

                // Jauge de progression à 100%
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: const LinearProgressIndicator(
                          value: 1.0,
                          backgroundColor: Color(0xFFE5E7EB),
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.vert),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item['pourcentage'],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.texte,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Montant distribué
                Row(
                  children: [
                    const Text(
                      'Montant distribué ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.texte,
                      ),
                    ),
                    Text(
                      item['montant'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.texteSecondaire,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
