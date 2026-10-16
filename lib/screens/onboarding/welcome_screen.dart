import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/theme/app_colors.dart';
import 'package:deme_mali_app/screens/auth/account_type_selection_screen.dart';
import 'package:deme_mali_app/screens/auth/login_screen.dart';
import 'package:deme_mali_app/widgets/deme_components.dart';

/// L'écran d'accueil/Bienvenue (iPhone 16 - 4)
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              // 1. Logo officiel et nom
              const Center(
                child: DemeLogo(
                  size: 90,
                  textSize: 30,
                  showText: true,
                ),
              ),
              const SizedBox(height: 48),

              // 2. Titre de bienvenue
              const Text(
                'Bienvenue sur\nDèmè Mali',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: AppColors.texte,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),

              // 3. Texte d'accroche
              const Text(
                "Ensemble, facilitons les dons et l'accès à l'aide en toute transparence et solidarité.",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.texteSecondaire,
                  height: 1.5,
                ),
              ),
              const Spacer(),

              // 4. Bouton principal : Créer un compte
              SizedBox(
                width: double.infinity,
                child: DemeButton(
                  text: 'Créer un compte',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AccountTypeSelectionScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),

              // 5. Bouton secondaire : Se connecter
              SizedBox(
                width: double.infinity,
                child: DemeButton(
                  text: 'Se connecter',
                  isOutlined: true,
                  textColor: AppColors.vert,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
