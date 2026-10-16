import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/services/auth_service.dart';
import 'package:deme_mali_app/core/theme/app_colors.dart';
import 'package:deme_mali_app/screens/auth/login_screen.dart';

/// ============================================================================
/// Écran : Profil de l'Organisation Partenaire
/// ============================================================================
class OrganisationProfileScreen extends StatelessWidget {
  const OrganisationProfileScreen({super.key});

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Souhaitez-vous vraiment vous déconnecter de votre espace organisation ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              UserSession.clear();
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Déconnexion', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nomStructure = UserSession.currentUserNomStructure ?? 'Organisation Partenaire';
    final nomResp = UserSession.currentUserName ?? 'Responsable de mission';
    final tel = UserSession.currentUserPhone ?? 'Non renseigné';
    final email = UserSession.currentUserEmail ?? 'contact@partenaire.org';

    return Scaffold(
      backgroundColor: AppColors.ivoire,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Profil Organisation',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.texte,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            children: [
              // 1. Carte en-tête du profil
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE2F0E9),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.verified_user_outlined,
                          size: 38,
                          color: AppColors.vert,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      nomStructure,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.texte,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Partenaire de terrain certifié',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF166534),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Responsable : $nomResp',
                      style: const TextStyle(fontSize: 13, color: AppColors.texteSecondaire),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Informations de contact & accréditation
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations officielles',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.texte),
                    ),
                    const SizedBox(height: 14),
                    _buildInfoRow(Icons.phone_outlined, 'Téléphone', tel),
                    const Divider(height: 18, color: Color(0xFFF3F4F6)),
                    _buildInfoRow(Icons.email_outlined, 'Email', email),
                    const Divider(height: 18, color: Color(0xFFF3F4F6)),
                    _buildInfoRow(Icons.location_on_outlined, 'Zone d\'intervention', 'Bamako & Régions'),
                    const Divider(height: 18, color: Color(0xFFF3F4F6)),
                    _buildInfoRow(Icons.assignment_turned_in_outlined, 'Missions', 'Visites de terrain, rapports de besoin & devis'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Bouton Déconnexion
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                  ),
                  title: const Text(
                    'Se déconnecter',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                      fontSize: 14,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () => _handleLogout(context),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.vert),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.texteSecondaire)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.texte)),
          ],
        ),
      ],
    );
  }
}
