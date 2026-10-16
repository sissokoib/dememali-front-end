import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/services/auth_service.dart';
import 'package:deme_mali_app/core/theme/app_colors.dart';
import 'package:deme_mali_app/screens/onboarding/welcome_screen.dart';
import 'package:deme_mali_app/widgets/bottom_nav_bar.dart';

/// ============================================================================
/// Écran : Profil BÉNÉFICIAIRE (Particulier & Structure)
/// Conforme aux maquettes Figma :
/// - "DetailsActivites admin.png" (Particulier / Individuel)
/// - "Profil beneficiciare structure.png" (Structure / Établissement)
/// ============================================================================
class BeneficiaireProfileScreen extends StatelessWidget {
  const BeneficiaireProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isStructure = UserSession.currentUserNomStructure != null &&
        UserSession.currentUserNomStructure!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: isStructure
              ? _buildStructureProfile(context)
              : _buildParticulierProfile(context),
        ),
      ),
      bottomNavigationBar: const BeneficiaireBottomNavBar(currentIndex: 3),
    );
  }

  /// ==========================================================================
  /// VUE 1 : Bénéficiaire Particulier (Figma: DetailsActivites admin.png)
  /// ==========================================================================
  Widget _buildParticulierProfile(BuildContext context) {
    final String displayName = ((UserSession.currentUserPrenom != null && UserSession.currentUserNom != null)
        ? '${UserSession.currentUserPrenom} ${UserSession.currentUserNom}'
        : (UserSession.currentUserName ?? 'Awa Traoré'));
    final String email = UserSession.currentUserEmail ?? 'awa@gmail.com';
    final String phone = UserSession.currentUserPhone ?? '+223 73 39 43 23';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 8),

        // Titre centré "Mon profil"
        const Text(
          'Mon profil',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.texte,
          ),
        ),
        const SizedBox(height: 24),

        // Avatar avec badge appareil photo
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E9EE),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_outline,
                  size: 52,
                  color: Color(0xFF8C98A4),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: AppColors.vert,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Nom et Rôle
        Text(
          displayName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.texte,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Bénéficiaire',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.texteSecondaire,
          ),
        ),
        const SizedBox(height: 18),

        // Bouton contour jaune : "Modifier mon profil"
        SizedBox(
          height: 44,
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Modification du profil')),
              );
            },
            icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.jaune),
            label: const Text(
              'Modifier mon profil',
              style: TextStyle(
                color: AppColors.jaune,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.jaune, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24),
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Section : Informations personnelles
        Align(
          alignment: Alignment.centerLeft,
          child: const Text(
            'Informations personnelles',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.texte,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Carte Informations personnelles
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.bordure),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildParticulierRow(
                icon: Icons.person,
                label: 'Nom',
                value: displayName,
              ),
              const SizedBox(height: 16),
              _buildParticulierRow(
                icon: Icons.alternate_email,
                label: 'Email',
                value: email,
              ),
              const SizedBox(height: 16),
              _buildParticulierRow(
                icon: Icons.phone,
                label: 'Téléphone',
                value: phone,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Section : Mon accompagnement
        Align(
          alignment: Alignment.centerLeft,
          child: const Text(
            'Mon accompagnement',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.texte,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Carte Association accompagnatrice
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.bordure),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Color(0xFF4B5563),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Association',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.texte,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Association Espoir',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.texteSecondaire,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Bouton Se Déconnecter
        _buildLogoutButton(context),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildParticulierRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.vert, size: 20),
        const SizedBox(width: 14),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.texte,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.texte,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// ==========================================================================
  /// VUE 2 : Structure / Établissement (Figma: Profil beneficiciare structure.png)
  /// ==========================================================================
  Widget _buildStructureProfile(BuildContext context) {
    final String structureName = UserSession.currentUserNomStructure?.isNotEmpty == true
        ? UserSession.currentUserNomStructure!
        : 'École Espoir';
    final String type = UserSession.currentUserTypeBeneficiaire?.isNotEmpty == true
        ? UserSession.currentUserTypeBeneficiaire!
        : 'Établissement scolaire';
    final String responsable = (UserSession.currentUserPrenom != null && UserSession.currentUserNom != null)
        ? '${UserSession.currentUserPrenom} ${UserSession.currentUserNom}'
        : 'Mamadou Diallo';
    final String phone = UserSession.currentUserPhone ?? '+223 70 00 00 00';
    final String localisation = UserSession.currentUserCity ?? 'Bamako, Mali';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),

        // Titre
        const Text(
          'Mon établissement',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.texte,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Les informations de votre structure.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.texteSecondaire,
          ),
        ),
        const SizedBox(height: 24),

        // Carte d'entête Établissement
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
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.vertClair,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.apartment,
                  color: AppColors.vert,
                  size: 32,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      structureName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.texte,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.texteSecondaire,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Informations générales
        const Text(
          'Informations générales',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.texte,
          ),
        ),
        const SizedBox(height: 14),

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
          child: Column(
            children: [
              _buildStructureItem(
                icon: Icons.apartment,
                title: 'Nom de l’établissement',
                value: structureName,
              ),
              const SizedBox(height: 18),
              _buildStructureItem(
                icon: Icons.person_outline,
                title: 'Responsable',
                value: responsable,
              ),
              const SizedBox(height: 18),
              _buildStructureItem(
                icon: Icons.phone_outlined,
                title: 'Téléphone',
                value: phone,
              ),
              const SizedBox(height: 18),
              _buildStructureItem(
                icon: Icons.location_on_outlined,
                title: 'Localisation',
                value: localisation,
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),

        // Bouton Se Déconnecter
        _buildLogoutButton(context),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStructureItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.vertClair,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.vert, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.texte,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.texteSecondaire,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => _confirmLogout(context),
        icon: const Icon(Icons.logout, color: AppColors.orange, size: 20),
        label: const Text(
          'Se déconnecter',
          style: TextStyle(
            color: AppColors.orange,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.jaune, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Déconnexion'),
        content: const Text('Souhaitez-vous vous déconnecter de votre compte ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler', style: TextStyle(color: AppColors.texteSecondaire)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              UserSession.clear();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Déconnexion', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
