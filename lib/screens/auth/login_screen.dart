import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/services/auth_service.dart';
import 'package:deme_mali_app/core/theme/app_colors.dart';
import 'package:deme_mali_app/screens/beneficiaire/dashboard_screen.dart';
import 'package:deme_mali_app/screens/donateur/donateur_dashboard_screen.dart';
import 'package:deme_mali_app/screens/organisation/organisation_dashboard_screen.dart';
import 'package:deme_mali_app/screens/auth/forgot_password_screen.dart';
import 'package:deme_mali_app/screens/auth/account_type_selection_screen.dart';
import 'package:deme_mali_app/widgets/deme_components.dart';

/// ============================================================================
/// Écran : Connexion à Dèmè Mali
/// Conforme à la maquette Figma "Connection.png"
/// ============================================================================
class LoginScreen extends StatefulWidget {
  final String? prefilledIdentifier;

  const LoginScreen({
    super.key,
    this.prefilledIdentifier,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _phoneController;
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(
      text: widget.prefilledIdentifier ??
          (UserSession.currentUserPhone ?? UserSession.currentUserEmail ?? ''),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateToDashboard() {
    final roleUser = UserSession.currentUserRole?.toUpperCase() ?? '';
    final bool isOrganisation =
        roleUser.contains('ORGANIS') || roleUser.contains('PARTENAIRE');
    final bool isDonateur = roleUser.contains('DONAT');

    if (isOrganisation) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OrganisationDashboardScreen()),
      );
    } else if (isDonateur) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DonateurDashboardScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  void _handleLogin() async {
    final identifier = _phoneController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez renseigner votre numéro de téléphone et votre mot de passe.'),
          backgroundColor: AppColors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.login(identifier, password);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      _navigateToDashboard();
    } else {
      final String msg = result['message']?.toString() ?? 'Échec de connexion.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivoire,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Logo centré
              const Center(
                child: DemeLogo(
                  size: 90,
                  textSize: 28,
                  showText: true,
                ),
              ),
              const SizedBox(height: 36),

              // Titre et sous-titre
              const Text(
                'Connexion',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.texte,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Connectez-vous à votre compte Dèmè Mali.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.texteSecondaire,
                ),
              ),
              const SizedBox(height: 28),

              // Champ Téléphone
              DemeTextField(
                label: 'Téléphone',
                hintText: 'Entrez votre numéro de téléphone',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 18),

              // Champ Mot de passe
              DemeTextField(
                label: 'Mot de passe',
                hintText: 'Entrez votre mot de passe',
                controller: _passwordController,
                isPassword: true,
                obscureText: _obscurePassword,
                onTogglePassword: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              const SizedBox(height: 12),

              // Mot de passe oublié ?
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ForgotPasswordScreen(
                          prefilledPhone: _phoneController.text.trim(),
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Mot de passe oublié ?',
                    style: TextStyle(
                      color: AppColors.vert,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Bouton Se connecter
              SizedBox(
                width: double.infinity,
                child: DemeButton(
                  text: 'Se connecter',
                  isLoading: _isLoading,
                  onPressed: _handleLogin,
                ),
              ),
              const SizedBox(height: 28),

              // Lien S'inscrire
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AccountTypeSelectionScreen(),
                      ),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 14, color: AppColors.texte),
                      children: [
                        TextSpan(text: "Vous n'avez pas encore de compte ? "),
                        TextSpan(
                          text: "S'inscrire",
                          style: TextStyle(
                            color: AppColors.vert,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
