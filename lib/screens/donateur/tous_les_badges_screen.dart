import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class TousLesBadgesScreen extends StatelessWidget {
  const TousLesBadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final badges = [
      _BadgeData(
        title: 'Kind Starter',
        range: '1200 - 1400 FCFA',
        isUnlocked: true,
        medalColor: const Color(0xFFD4A017),
        ribbonColor: Colors.red.shade700,
      ),
      _BadgeData(
        title: 'Hope Giver',
        range: '1400 - 5000 FCFA',
        isUnlocked: true,
        medalColor: const Color(0xFFE5A91E),
        ribbonColor: Colors.blue.shade700,
      ),
      _BadgeData(
        title: 'Acteur du changement',
        range: '5000 - 30000 FCFA',
        isUnlocked: false,
        medalColor: const Color(0xFF9E9E9E),
        ribbonColor: const Color(0xFF757575),
      ),
      _BadgeData(
        title: 'Bâtisseur de solidarité',
        range: '3000 - 50000 FCFA',
        isUnlocked: false,
        medalColor: const Color(0xFF9E9E9E),
        ribbonColor: const Color(0xFF757575),
      ),
      _BadgeData(
        title: 'Héros de la communauté',
        range: '50000 - 100000 FCFA',
        isUnlocked: false,
        medalColor: const Color(0xFF9E9E9E),
        ribbonColor: const Color(0xFF757575),
      ),
      _BadgeData(
        title: 'Bienfaiteur engagé',
        range: '100000 - 200000 FCFA',
        isUnlocked: false,
        medalColor: const Color(0xFF9E9E9E),
        ribbonColor: const Color(0xFF757575),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.ivoire,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.texte),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tous les badges',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.vert,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: GridView.builder(
            itemCount: badges.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.88,
            ),
            itemBuilder: (context, index) {
              final badge = badges[index];
              return _buildBadgeCard(badge);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeCard(_BadgeData badge) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2E7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: badge.isUnlocked
              ? AppColors.jaune.withOpacity(0.5)
              : Colors.black.withOpacity(0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.military_tech_rounded,
                size: 48,
                color: badge.medalColor,
              ),
              Positioned(
                top: 4,
                child: Container(
                  width: 14,
                  height: 10,
                  decoration: BoxDecoration(
                    color: badge.ribbonColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            badge.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.texte,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            badge.range,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: badge.isUnlocked
                  ? AppColors.texteSecondaire
                  : AppColors.texteSecondaire.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeData {
  final String title;
  final String range;
  final bool isUnlocked;
  final Color medalColor;
  final Color ribbonColor;

  _BadgeData({
    required this.title,
    required this.range,
    required this.isUnlocked,
    required this.medalColor,
    required this.ribbonColor,
  });
}
