import 'package:flutter/material.dart';
import 'package:deme_mali_app/screens/donateur/choix_type_don_screen.dart';
import 'package:deme_mali_app/widgets/bottom_nav_bar.dart';

/// ============================================================================
/// Écran : Choisissez une cause
/// Inspiré des maquettes : iPhone 16 - 19.png et iPhone 16 - 20.png
///
/// Ce code présente une grille interactive permettant de sélectionner
/// la cause solidaire à soutenir avant de faire un don.
/// Conçu pour être limpide pour un débutant avec des commentaires en français.
/// ============================================================================

class ChoisirCauseScreen extends StatefulWidget {
  const ChoisirCauseScreen({super.key});

  @override
  State<ChoisirCauseScreen> createState() => _ChoisirCauseScreenState();
}

class _ChoisirCauseScreenState extends State<ChoisirCauseScreen> {
  // Variable pour mémoriser l'identifiant de la cause sélectionnée
  String? _selectedCauseId = "urgence"; // Par défaut "urgence" comme sur la maquette 20

  // Liste des 12 causes disponibles selon la maquette
  final List<Map<String, dynamic>> _causes = [
    {
      "id": "education",
      "titre": "Éducation",
      "icon": Icons.school,
    },
    {
      "id": "handicap",
      "titre": "Personnes\nhandicapées",
      "icon": Icons.accessible_forward,
    },
    {
      "id": "immigres",
      "titre": "Immigrés",
      "icon": Icons.groups,
    },
    {
      "id": "enfants",
      "titre": "Enfants\nmalades",
      "icon": Icons.child_care,
    },
    {
      "id": "sante",
      "titre": "Santé",
      "icon": Icons.medical_services_outlined,
    },
    {
      "id": "infrastructure",
      "titre": "Infrastructure",
      "icon": Icons.apartment,
    },
    {
      "id": "alimentaire",
      "titre": "Alimentaire",
      "icon": Icons.rice_bowl_outlined,
    },
    {
      "id": "logement",
      "titre": "Logement",
      "icon": Icons.home_outlined,
    },
    {
      "id": "eau",
      "titre": "Eaux & hygiène",
      "icon": Icons.water_drop_outlined,
    },
    {
      "id": "urgence",
      "titre": "Urgence",
      "icon": Icons.warning_amber_rounded,
    },
    {
      "id": "deplaces",
      "titre": "Personnes\ndéplacées",
      "icon": Icons.diversity_3,
    },
    {
      "id": "autres",
      "titre": "Autres",
      "icon": Icons.view_headline_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Couleurs de la charte Dèmè Mali
    const Color vertPrincipal = Color(0xFF137A4B);
    const Color vertDesactive = Color(0xFFA1C6B4);
    const Color fondBeige = Color(0xFFF7F4EB);
    const Color texteFonce = Color(0xFF1F1F1F);
    const Color texteGris = Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: fondBeige,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Barre d'action supérieure
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Bouton retour
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: texteFonce, size: 22),
                    ),
                  ),

                  // Bouton cloche
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.notifications_none, color: texteFonce, size: 22),
                        Positioned(
                          top: 10,
                          right: 12,
                          child: CircleAvatar(
                            radius: 4,
                            backgroundColor: Color(0xFFF7A821),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Titre et description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Choisissez une cause",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: texteFonce,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Choisissez le domaine que vous souhaitez soutenir.",
                    style: TextStyle(
                      fontSize: 14,
                      color: texteGris,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 3. Grille des causes (3 colonnes)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.95,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _causes.length,
                  itemBuilder: (context, index) {
                    final cause = _causes[index];
                    final bool isSelected = _selectedCauseId == cause["id"];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCauseId = cause["id"];
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? vertPrincipal : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? vertPrincipal : const Color(0xFFE5E7EB),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icône de la cause
                            Icon(
                              cause["icon"] as IconData,
                              size: 32,
                              color: isSelected ? Colors.white : vertPrincipal,
                            ),
                            const SizedBox(height: 8),
                            // Nom de la cause
                            Text(
                              cause["titre"],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : texteFonce,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // 4. Bouton "Continuer" au bas de l'écran
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedCauseId != null ? vertPrincipal : vertDesactive,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _selectedCauseId != null
                      ? () {
                          final selected = _causes.firstWhere(
                            (c) => c["id"] == _selectedCauseId,
                            orElse: () => _causes.first,
                          );
                          // Navigation vers le choix du type de don (financier ou matériel)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChoixTypeDonScreen(cause: selected),
                            ),
                          );
                        }
                      : null,
                  child: const Text(
                    "Continuer",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const DonateurBottomNavBar(currentIndex: 2),
    );
  }
}
