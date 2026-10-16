import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/theme/app_colors.dart';
import 'package:deme_mali_app/screens/donateur/faire_un_don_screen.dart';
import 'package:deme_mali_app/screens/donateur/don_materiel_screen.dart';
import 'package:deme_mali_app/widgets/deme_components.dart';

/// ============================================================================
/// Écran : Choix du type de don (Espace Donateur)
/// Conforme à la maquette Figma "Choix de dons.png"
///
/// Permet au donateur de choisir entre :
/// 1. Don financier (contribution monétaire via Orange Money, Wave, etc.)
/// 2. Don matériel (biens en nature : vêtements, vivres, fournitures, etc.)
/// ============================================================================
class ChoixTypeDonScreen extends StatelessWidget {
  final Map<String, dynamic>? cause;

  const ChoixTypeDonScreen({super.key, this.cause});

  @override
  Widget build(BuildContext context) {
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
                'Faire un don',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.texte,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),

              // Sous-titre descriptif
              const Text(
                'Choisissez le type de don que vous souhaitez offrir pour soutenir ceux qui en ont besoin.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.texteSecondaire,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),

              // Option 1 : Don financier
              _buildOptionCard(
                context,
                icon: Icons.account_balance_wallet_outlined,
                iconBgColor: AppColors.vertClair,
                iconColor: AppColors.vert,
                title: 'Don financier',
                description:
                    'Offrez une contribution financière pour soutenir les besoins des bénéficiaires.',
                buttonLabel: 'Choisir ce don',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FaireUnDonScreen(cause: cause),
                    ),
                  );
                },
              ),

              const SizedBox(height: 18),

              // Option 2 : Don matériel
              _buildOptionCard(
                context,
                icon: Icons.inventory_2_outlined,
                iconBgColor: const Color(0xFFF1EDE2),
                iconColor: const Color(0xFF137A4B),
                title: 'Don matériel',
                description:
                    'Offrez des biens utiles : vêtements, nourriture, fournitures scolaires et autres équipements.',
                buttonLabel: 'Choisir ce don',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DonMaterielScreen(cause: cause),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String description,
    required String buttonLabel,
    required VoidCallback onTap,
  }) {
    return Container(
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
          // Icône dans son conteneur arrondi
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 26,
            ),
          ),
          const SizedBox(height: 18),

          // Titre de l'option
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.texte,
            ),
          ),
          const SizedBox(height: 10),

          // Description de l'option
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.texteSecondaire,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 22),

          // Bouton vert plein avec flèche
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.vert,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    buttonLabel,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward,
                    size: 18,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
