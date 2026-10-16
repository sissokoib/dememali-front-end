import 'package:flutter/material.dart';
import 'package:deme_mali_app/screens/onboarding/welcome_screen.dart';

// Cet écran représente la deuxième page de l'onboarding (tutoriel de démarrage).
// Il est conçu de manière très simple avec un Scaffold (la base de tout écran).
class OnboardingPage2 extends StatelessWidget {
  const OnboardingPage2({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold fournit la structure de base (fond, barre de navigation, etc.)
    return Scaffold(
      // Couleur de fond légèrement beige pour respecter le design
      backgroundColor: const Color(0xFFF6F4EB),
      // SafeArea permet d'éviter que le contenu ne passe sous l'encoche de la caméra
      body: SafeArea(
        child: Padding(
          // On ajoute de l'espace (marges) autour de tout le contenu
          padding: const EdgeInsets.all(24.0),
          child: Column(
            // On aligne les éléments au centre verticalement
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Le Logo central
              const Icon(
                Icons.volunteer_activism, // Icône de mains avec un coeur
                size: 100,
                color: Color(0xFF137A4B), // Vert principal
              ),
              const SizedBox(height: 16), // Espace vide de 16 pixels
              
              // 2. Le texte du nom de l'application
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(text: 'Dème ', style: TextStyle(color: Color(0xFF137A4B))),
                    TextSpan(text: 'Mali', style: TextStyle(color: Color(0xFFF7A821))), // Jaune/Orange
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // 3. Le gros titre
              const Text(
                'Un petit geste peut changer une vie',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF137A4B),
                  height: 1.2, // Espacement entre les lignes
                ),
              ),
              const SizedBox(height: 20),

              // 4. Le paragraphe explicatif
              const Text(
                'Chaque don contribue à répondre à un besoin réel : santé, éducation, alimentation etc.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // 5. Les icônes illustratives au centre (Don -> Besoin réel)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Cercle gauche : Don
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE2F0E9), // Vert très clair
                          shape: BoxShape.circle, // Forme ronde
                        ),
                        child: const Icon(Icons.volunteer_activism, color: Color(0xFF137A4B), size: 40),
                      ),
                      const SizedBox(height: 12),
                      const Text('Don', style: TextStyle(color: Color(0xFF137A4B), fontSize: 16)),
                    ],
                  ),
                  
                  // Flèche au milieu
                  const Icon(Icons.arrow_forward, color: Color(0xFF137A4B)),
                  
                  // Cercle droit : Besoin réel
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE2F0E9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.groups, color: Color(0xFF137A4B), size: 40),
                      ),
                      const SizedBox(height: 12),
                      const Text('Besoin réel', style: TextStyle(color: Color(0xFF137A4B), fontSize: 16)),
                    ],
                  ),
                ],
              ),
              
              const Spacer(), // Prend tout l'espace vide restant pour pousser les éléments suivants vers le bas

              // 6. Les petits points de navigation (indicateur de page)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF137A4B), shape: BoxShape.circle)), // Le 2ème point est vert car on est sur la page 2
                ],
              ),
              const SizedBox(height: 20),

              // 7. Le bouton "Suivant"
              SizedBox(
                width: double.infinity, // Prend toute la largeur disponible
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF137A4B), // Couleur de fond du bouton
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Bords arrondis
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
