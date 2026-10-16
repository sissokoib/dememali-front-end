import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/services/auth_service.dart';
import 'package:deme_mali_app/core/services/demande_service.dart';
import 'package:deme_mali_app/core/theme/app_colors.dart';
import 'package:deme_mali_app/screens/beneficiaire/demande_aide_step1_screen.dart';
import 'package:deme_mali_app/screens/beneficiaire/mes_demandes_screen.dart';
import 'package:deme_mali_app/screens/beneficiaire/suivre_mes_aides_screen.dart';
import 'package:deme_mali_app/screens/beneficiaire/mes_aides_recues_screen.dart';
import 'package:deme_mali_app/widgets/bottom_nav_bar.dart';
import 'package:deme_mali_app/widgets/deme_components.dart';

/// ============================================================================
/// Écran : Accueil / Tableau de bord BÉNÉFICIAIRE
/// Conforme à la maquette Figma "Accueil beneficiare.png"
/// ============================================================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DemandeService _demandeService = DemandeService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshDemandes();
  }

  Future<void> _refreshDemandes() async {
    setState(() => _isLoading = true);
    if (UserSession.currentUserId != null) {
      final list = await _demandeService.fetchDemandesBeneficiaire(UserSession.currentUserId!);
      if (mounted && list.isNotEmpty) {
        UserSession.userDemandes = list;
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final String nomAffiche = (UserSession.currentUserPrenom?.trim().isNotEmpty == true)
        ? UserSession.currentUserPrenom!.trim()
        : ((UserSession.currentUserNomStructure?.trim().isNotEmpty == true)
            ? UserSession.currentUserNomStructure!.trim()
            : ((UserSession.currentUserName?.trim().isNotEmpty == true)
                ? UserSession.currentUserName!.trim().split(' ').first
                : 'Mariam'));

    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Entête Dèmè Mali + Cloche de notification
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const DemeLogo(
                    size: 34,
                    textSize: 20,
                    isHorizontal: true,
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.bordure),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.notifications_none_outlined,
                          color: AppColors.texte,
                          size: 22,
                        ),
                        Positioned(
                          top: 10,
                          right: 12,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.jaune,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. Salutation et message d'accueil
              Text(
                'Bonjour $nomAffiche',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.texte,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Bienvenue dans votre espace bénéficiaire.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.texteSecondaire,
                ),
              ),
              const SizedBox(height: 24),

              // 3. Grand bouton vert d'action "+ Faire une demande d'aide"
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DemandeAideStep1Screen(),
                    ),
                  ).then((_) => _refreshDemandes());
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: AppColors.vert,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.vert.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Faire une demande d’aide',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // 4. Section "Que souhaitez-vous faire ?"
              const Text(
                'Que souhaitez-vous faire ?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.texte,
                ),
              ),
              const SizedBox(height: 16),

              // 5. Grille 2x2 des 4 cartes d'actions
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.volunteer_activism_outlined,
                      iconBgColor: AppColors.vertClair,
                      iconColor: AppColors.vert,
                      title: 'Demander une aide',
                      subtitle: 'Faire une demande',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DemandeAideStep1Screen(),
                          ),
                        ).then((_) => _refreshDemandes());
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.description_outlined,
                      iconBgColor: AppColors.jaune,
                      iconColor: Colors.white,
                      title: 'Mes demandes',
                      subtitle: 'La liste de tes demandes aides',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MesDemandesScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.search,
                      iconBgColor: AppColors.vertClair,
                      iconColor: AppColors.vert,
                      title: 'Suivre mes aides',
                      subtitle: 'Voir l’avancement',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SuivreMesAidesScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.card_giftcard_outlined,
                      iconBgColor: AppColors.jaune,
                      iconColor: Colors.white,
                      title: 'Mes aides reçus',
                      subtitle: 'Retrouvez vos aides déjà reçues.',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MesAidesRecuesScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BeneficiaireBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 175,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.texte,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.texteSecondaire,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
