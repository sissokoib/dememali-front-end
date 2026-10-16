import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/theme/app_colors.dart';
import 'package:deme_mali_app/screens/donateur/choix_type_don_screen.dart';
import 'package:deme_mali_app/screens/donateur/organisation_actions_screen.dart';
import 'package:deme_mali_app/widgets/deme_components.dart';

/// ============================================================================
/// Écran : Profil de l'organisation (Espace Donateur)
/// Conforme à la maquette Figma "Profil organisation donateur.png"
///
/// Permet au donateur d'en savoir plus sur une organisation partenaire,
/// de consulter ses galeries d'actions et de la soutenir directement.
/// ============================================================================
class OrganisationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> organisation;

  const OrganisationDetailScreen({
    super.key,
    required this.organisation,
  });

  @override
  Widget build(BuildContext context) {
    final String nom = (organisation['nom'] ?? organisation['nomStructure'] ?? 'Fondation Orange').toString();
    final String ville = (organisation['ville'] ?? 'Bamako').toString();
    final String description = (organisation['mission'] ??
            'La Fondation Orange Mali mène des actions de solidarité et contribue au développement social, notamment dans l’éducation, la santé et l’inclusion numérique.')
        .toString();

    final List<String> actionImages = [
      'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?q=80&w=400&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1516574187841-cb9cc2ca948b?q=80&w=400&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1541544741938-0af808871cc0?q=80&w=400&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1593113598332-cd288d649433?q=80&w=400&auto=format&fit=crop',
    ];

    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Entête : Bouton retour et Titre
              Row(
                children: [
                  const DemeBackButton(),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Profil de l\'organisation',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.texte,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. Carte de présentation de l'organisation
              Container(
                width: double.infinity,
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
                child: Row(
                  children: [
                    // Icône institution dans carré menthe arrondi
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: AppColors.vertClair,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.account_balance,
                        color: AppColors.vert,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nom,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.texte,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ville,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.texteSecondaire,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Bouton vert large : Soutenir cette organisation
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChoixTypeDonScreen(cause: {
                          'titre': 'Soutien à $nom',
                          'partenaire': nom,
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
                  child: const Text(
                    'Soutenir cette organisation',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // 4. Onglet / Titre souligné "À propos"
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'À propos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.texte,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 70,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.vert,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Texte de présentation
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.texteSecondaire,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),

              // 5. Section "Images de nos actions" avec lien "Voir tout"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Images de nos actions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.texte,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrganisationActionsScreen(
                            organisationNom: nom,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Voir tout',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.vert,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 6. Rangée d'images d'actions
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: actionImages.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final img = actionImages[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrganisationActionsScreen(
                              organisationNom: nom,
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          img,
                          width: 130,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => Container(
                            width: 130,
                            height: 100,
                            color: AppColors.vertClair,
                            child: const Icon(
                              Icons.photo,
                              color: AppColors.vert,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
