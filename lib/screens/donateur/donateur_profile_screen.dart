import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/services/auth_service.dart';
import 'package:deme_mali_app/core/theme/app_colors.dart';
import 'package:deme_mali_app/screens/donateur/tous_les_badges_screen.dart';
import 'package:deme_mali_app/screens/onboarding/welcome_screen.dart';
import 'package:deme_mali_app/widgets/bottom_nav_bar.dart';

/// ============================================================================
/// Écran Profil DONATEUR avec Badges et Statistiques
/// Conforme à la maquette Figma "Donateur profil.png"
/// ============================================================================
class DonateurProfileScreen extends StatelessWidget {
  const DonateurProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String displayName = ((UserSession.currentUserPrenom != null && UserSession.currentUserNom != null)
        ? '${UserSession.currentUserPrenom} ${UserSession.currentUserNom}'
        : (UserSession.currentUserName ?? 'Donateur Solidaire'));

    final int donsEffectues = UserSession.userDons.isNotEmpty ? UserSession.userDons.length : 12;
    final int totalDonsAmount = UserSession.userDons.isNotEmpty
        ? UserSession.userDons.fold<int>(0, (sum, d) {
            final m = d['montant'];
            if (m is num) return sum + m.toInt();
            return sum + (int.tryParse(m?.toString() ?? '0') ?? 0);
          })
        : 150000;

    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Entête avec titre et bouton de déconnexion discret
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.texte,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _confirmLogout(context),
                    icon: const Icon(Icons.logout, color: AppColors.texteSecondaire),
                    tooltip: 'Se déconnecter',
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // En-tête profil : Avatar + Nom + Statistiques
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: AppColors.vertClair.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          size: 46,
                          color: AppColors.vert,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.texte,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dons effectués',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.texteSecondaire,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$donsEffectues',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.texte,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Total de dons',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.texteSecondaire,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$totalDonsAmount FCFA',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.vert,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),
              const Divider(color: AppColors.bordure, height: 1),
              const SizedBox(height: 24),

              // Section Mes Badges
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mes Badges',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.texte,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TousLesBadgesScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Voir tous',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.vert,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildBadgeCard(
                      badgeIcon: Icons.military_tech,
                      badgeColor: AppColors.orange,
                      title: 'Premier geste solidaire',
                      subtitle: '1200 - 1400 FCFA',
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildBadgeCard(
                      badgeIcon: Icons.workspace_premium,
                      badgeColor: AppColors.jaune,
                      title: "Donateur d'espoir",
                      subtitle: '1400 - 5000 FCFA',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Section Mon activité avec graphique barres
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mon activité',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.texte,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.vertClair,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Mois',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.vert,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '$totalDonsAmount FCFA',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.texte,
                ),
              ),
              const SizedBox(height: 20),

              // Graphique à barres stylisé
              _buildActivityChart(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const DonateurBottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildBadgeCard({
    required IconData badgeIcon,
    required Color badgeColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.bordure),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(badgeIcon, color: badgeColor, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.texte,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.texteSecondaire,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChart() {
    final List<Map<String, dynamic>> months = [
      {'label': 'Jan', 'ratio': 0.45, 'isHighlight': false},
      {'label': 'Févr', 'ratio': 0.90, 'isHighlight': false},
      {'label': 'Mar', 'ratio': 0.60, 'isHighlight': false},
      {'label': 'Avr', 'ratio': 0.95, 'isHighlight': false},
      {'label': 'Mai', 'ratio': 0.35, 'isHighlight': false},
      {'label': 'Juin', 'ratio': 0.80, 'isHighlight': true},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.bordure),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: months.map((m) {
                final double ratio = m['ratio'] as double;
                final bool isHighlight = m['isHighlight'] as bool;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 28,
                      height: 110 * ratio,
                      decoration: BoxDecoration(
                        color: isHighlight ? AppColors.vert : AppColors.jaune,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      m['label'].toString(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.texteSecondaire,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
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
        content: const Text('Souhaitez-vous vous déconnecter ?'),
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
