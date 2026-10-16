import 'package:flutter/material.dart';
import 'package:deme_mali_app/screens/onboarding/welcome_screen.dart';

// Cet écran représente la troisième page de l'onboarding (iPhone 16 - 3).
// Le code est très similaire à la page 2, ce qui permet à un débutant de s'y retrouver facilement.
class OnboardingPage3 extends StatelessWidget {
  const OnboardingPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4EB), // Fond beige clair
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start, // Aligne les textes sur la gauche
            children: [
              const Spacer(), // Pousse le contenu vers le centre/bas
              
              // 1. Le titre principal
              const Text(
                'Chaque personne mérite une aide',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF137A4B),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 24), // Espacement

              // 2. Le texte explicatif
              const Text(
                'Dème Mali met en relation les personnes en difficulté avec les aides dont elles ont réelement besoin',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 60),

              // 3. Les trois icônes (Besoin -> Vérification -> Aide) alignées horizontalement
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // --- Élément 1 : Besoin ---
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE2F0E9), // Vert très clair pour le fond de l'icône
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, color: Color(0xFF137A4B), size: 30),
                      ),
                      const SizedBox(height: 12),
                      const Text('Besoin', style: TextStyle(color: Color(0xFF137A4B), fontSize: 14)),
                    ],
                  ),
                  
                  // Flèche
                  const Icon(Icons.arrow_forward, color: Color(0xFF137A4B)),
                  
                  // --- Élément 2 : Vérification ---
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE2F0E9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle, color: Color(0xFF137A4B), size: 30),
                      ),
                      const SizedBox(height: 12),
                      const Text('Vérification', style: TextStyle(color: Color(0xFF137A4B), fontSize: 14)),
                    ],
                  ),
                  
                  // Flèche
                  const Icon(Icons.arrow_forward, color: Color(0xFF137A4B)),
                  
                  // --- Élément 3 : Aide ---
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE2F0E9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.volunteer_activism, color: Color(0xFF137A4B), size: 30),
                      ),
                      const SizedBox(height: 12),
                      const Text('Aide', style: TextStyle(color: Color(0xFF137A4B), fontSize: 14)),
                    ],
                  ),
                ],
              ),
              
              const Spacer(), // Pousse la suite tout en bas de l'écran

              // 4. Les indicateurs de page (les petits points)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF137A4B), shape: BoxShape.circle)), // Le 3ème point est vert
                ],
              ),
              const SizedBox(height: 20),

              // 5. Le bouton "Suivant"
              SizedBox(
                width: double.infinity, // Le bouton prend toute la largeur
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF137A4B),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Suivant', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
