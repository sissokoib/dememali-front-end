import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/theme/app_colors.dart';
import 'package:deme_mali_app/screens/beneficiaire/dashboard_screen.dart';
import 'package:deme_mali_app/screens/beneficiaire/mes_demandes_screen.dart';
import 'package:deme_mali_app/screens/beneficiaire/mes_aides_recues_screen.dart';
import 'package:deme_mali_app/screens/beneficiaire/beneficiaire_profile_screen.dart';
import 'package:deme_mali_app/screens/donateur/donateur_dashboard_screen.dart';
import 'package:deme_mali_app/screens/donateur/donateur_organisations_screen.dart';
import 'package:deme_mali_app/screens/donateur/donateur_mes_dons_screen.dart';
import 'package:deme_mali_app/screens/donateur/donateur_profile_screen.dart';

/// Modèle d'item pour la barre de navigation incurvée
class DemeNavItem {
  final IconData icon;
  final String label;

  const DemeNavItem({required this.icon, required this.label});
}

/// ============================================================================
/// Barre de Navigation Incurvée Dèmè Mali avec encoche dynamique
/// Conforme aux maquettes Figma "Navigation_beneficiaire.png" et "Navigation_donateur.png"
/// ============================================================================
class DemeCurvedBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<DemeNavItem> items;
  final ValueChanged<int> onTap;

  const DemeCurvedBottomNav({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        const double barHeight = 68.0;
        const double totalHeight = 84.0;
        final int count = items.length;
        final double itemWidth = width / count;
        final double activeCenterX = (currentIndex + 0.5) * itemWidth;

        return SizedBox(
          width: width,
          height: totalHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Fond vert incurvé avec encoche fluide
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: barHeight,
                child: CustomPaint(
                  size: Size(width, barHeight),
                  painter: _CurvedBarPainter(
                    activeCenterX: activeCenterX,
                    color: AppColors.vert,
                    cutoutRadius: 36.0,
                  ),
                ),
              ),

              // 2. Bouton actif circulaire blanc qui flotte dans l'encoche
              Positioned(
                left: activeCenterX - 28,
                top: 4,
                child: GestureDetector(
                  onTap: () => onTap(currentIndex),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      items[currentIndex].icon,
                      color: AppColors.vert,
                      size: 26,
                    ),
                  ),
                ),
              ),

              // 3. Les boutons de navigation
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: barHeight,
                child: Row(
                  children: List.generate(count, (index) {
                    final item = items[index];
                    final bool isSelected = index == currentIndex;

                    return Expanded(
                      child: InkWell(
                        onTap: () => onTap(index),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Center(
                          child: isSelected
                              ? const SizedBox.shrink()
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      item.icon,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      item.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Dessine la forme incurvée de la barre de navigation
class _CurvedBarPainter extends CustomPainter {
  final double activeCenterX;
  final Color color;
  final double cutoutRadius;

  _CurvedBarPainter({
    required this.activeCenterX,
    required this.color,
    required this.cutoutRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final double w = size.width;
    final double h = size.height;
    final double cx = activeCenterX;
    final double dipWidth = cutoutRadius * 1.5;
    final double dipDepth = 30.0;

    path.moveTo(0, 0);

    // Ligne jusqu'au début de l'encoche
    final double startX = (cx - dipWidth).clamp(0.0, w);
    path.lineTo(startX, 0);

    // Courbe d'entrée vers le bas
    path.cubicTo(
      cx - dipWidth * 0.6, 0,
      cx - dipWidth * 0.5, dipDepth,
      cx, dipDepth,
    );

    // Courbe de sortie vers le haut
    final double endX = (cx + dipWidth).clamp(0.0, w);
    path.cubicTo(
      cx + dipWidth * 0.5, dipDepth,
      cx + dipWidth * 0.6, 0,
      endX, 0,
    );

    // Ligne vers la droite
    path.lineTo(w, 0);
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CurvedBarPainter oldDelegate) {
    return oldDelegate.activeCenterX != activeCenterX ||
        oldDelegate.color != color ||
        oldDelegate.cutoutRadius != cutoutRadius;
  }
}

/// ============================================================================
/// Barre de Navigation Inférieure pour l'espace BÉNÉFICIAIRE
/// ============================================================================
class BeneficiaireBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BeneficiaireBottomNavBar({super.key, required this.currentIndex});

  static const List<DemeNavItem> items = [
    DemeNavItem(icon: Icons.home, label: 'Home'),
    DemeNavItem(icon: Icons.description_outlined, label: 'Mes demandes'),
    DemeNavItem(icon: Icons.volunteer_activism_outlined, label: 'Mes dons'),
    DemeNavItem(icon: Icons.person_outline, label: 'Profil'),
  ];

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MesDemandesScreen()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MesAidesRecuesScreen()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BeneficiaireProfileScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DemeCurvedBottomNav(
      currentIndex: currentIndex,
      items: items,
      onTap: (index) => _onItemTapped(context, index),
    );
  }
}

/// ============================================================================
/// Barre de Navigation Inférieure pour l'espace DONATEUR
/// ============================================================================
class DonateurBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const DonateurBottomNavBar({super.key, required this.currentIndex});

  static const List<DemeNavItem> items = [
    DemeNavItem(icon: Icons.home, label: 'Home'),
    DemeNavItem(icon: Icons.account_balance_outlined, label: 'Organisations'),
    DemeNavItem(icon: Icons.volunteer_activism_outlined, label: 'Mes dons'),
    DemeNavItem(icon: Icons.person_outline, label: 'Profil'),
  ];

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DonateurDashboardScreen()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DonateurOrganisationsScreen()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DonateurMesDonsScreen()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DonateurProfileScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DemeCurvedBottomNav(
      currentIndex: currentIndex,
      items: items,
      onTap: (index) => _onItemTapped(context, index),
    );
  }
}

/// Alias rétrocompatible
class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BeneficiaireBottomNavBar(currentIndex: currentIndex);
  }
}
