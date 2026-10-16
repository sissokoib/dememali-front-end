import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/theme/app_colors.dart';
import 'package:deme_mali_app/screens/auth/fill_profile_screen.dart';
import 'package:deme_mali_app/screens/auth/inscription_structure_screen.dart';
import 'package:deme_mali_app/screens/auth/inscription_donateur_screen.dart';
import 'package:deme_mali_app/screens/auth/inscription_organisation_screen.dart';
import 'package:deme_mali_app/widgets/deme_components.dart';

/// ============================================================================
/// Écran : Sélection du type de compte (Bénéficiaire / Donateur / Organisation Partenaire)
/// ============================================================================
class AccountTypeSelectionScreen extends StatefulWidget {
  const AccountTypeSelectionScreen({super.key});

  @override
  State<AccountTypeSelectionScreen> createState() =>
      _AccountTypeSelectionScreenState();
}

class _AccountTypeSelectionScreenState
    extends State<AccountTypeSelectionScreen> {
  int? _selectedIndex = 0; // 0 = Bénéficiaire Particulier par défaut

  final List<Map<String, dynamic>> _options = [
    {
      'title': 'Bénéficiaire Particulier',
      'subtitle':
          'Je souhaite demander une aide (médicale, alimentaire, scolaire) pour moi ou ma famille.',
      'icon': Icons.front_hand_outlined,
      'color': AppColors.vert,
    },
    {
      'title': 'Bénéficiaire Structure',
      'subtitle':
          'Je représente une école, un orphelinat ou un centre de santé et sollicite un appui.',
      'icon': Icons.apartment_outlined,
      'color': AppColors.jaune,
    },
    {
      'title': 'Donateur Particulier',
      'subtitle':
          'Je souhaite financer des causes, parrainer des enfants et suivre mon impact solidaire.',
      'icon': Icons.volunteer_activism_outlined,
      'color': AppColors.vert,
    },
    {
      'title': 'Donateur Organisation',
      'subtitle':
          'Entreprise, fondation ou ONG souhaitant lancer des initiatives solidaires.',
      'icon': Icons.business_outlined,
      'color': AppColors.jaune,
    },
    {
      'title': 'Organisation Partenaire',
      'subtitle':
          'ONG ou association chargée d\'effectuer des visites de terrain et fournir des rapports techniques.',
      'icon': Icons.assignment_turned_in_outlined,
      'color': AppColors.vert,
    },
  ];

  void _onContinue() {
    if (_selectedIndex == 0) {
      // Bénéficiaire Particulier
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FillProfileScreen()),
      );
    } else if (_selectedIndex == 1) {
      // Bénéficiaire Structure
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const InscriptionStructureScreen()),
      );
    } else if (_selectedIndex == 2 || _selectedIndex == 3) {
      // Donateur (Particulier ou Organisation)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => InscriptionDonateurScreen(
            initialIsOrganisation: _selectedIndex == 3,
          ),
        ),
      );
    } else if (_selectedIndex == 4) {
      // Organisation Partenaire
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const InscriptionOrganisationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bouton retour
              const DemeBackButton(),
              const SizedBox(height: 20),

              // Grand titre
              const Text(
                'Créer votre compte',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.texte,
                ),
              ),
              const SizedBox(height: 8),

              // Sous-titre
              const Text(
                'Choisissez le profil qui correspond à vos besoins.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.texteSecondaire,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // Liste des options
              Expanded(
                child: ListView.separated(
                  itemCount: _options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final item = _options[index];
                    final isSelected = _selectedIndex == index;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppColors.vert : AppColors.bordure,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? AppColors.vert.withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: (item['color'] as Color).withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                color: item['color'] as Color,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'] as String,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.texte,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['subtitle'] as String,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.texteSecondaire,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? AppColors.vert : Colors.transparent,
                                border: Border.all(
                                  color: isSelected ? AppColors.vert : AppColors.placeholder,
                                  width: 1.8,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white, size: 15)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Bouton Continuer
              SizedBox(
                width: double.infinity,
                child: DemeButton(
                  text: 'Continuer',
                  icon: Icons.arrow_forward,
                  onPressed: _selectedIndex != null ? _onContinue : null,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
