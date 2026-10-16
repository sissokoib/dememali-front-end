import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/theme/app_colors.dart';
import 'package:deme_mali_app/widgets/deme_components.dart';

/// ============================================================================
/// Écran : Mot de passe oublié (Demande + Code OTP)
/// Conforme aux maquettes Figma "Mot de passe oublier.png" et "mot de passe oublier-1.png"
/// ============================================================================
class ForgotPasswordScreen extends StatefulWidget {
  final String? prefilledPhone;

  const ForgotPasswordScreen({super.key, this.prefilledPhone});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool _codeSent = false;
  late final TextEditingController _phoneController;
  final List<TextEditingController> _codeControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.prefilledPhone ?? '');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    for (final c in _codeControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onCodeChanged(String value, int index) {
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _sendCode() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer votre numéro de téléphone.'),
          backgroundColor: AppColors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _codeSent = true;
    });
  }

  void _verifyCode() async {
    final code = _codeControllers.map((c) => c.text).join();
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir le code complet à 4 chiffres.'),
          backgroundColor: AppColors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isLoading = false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Code validé', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Un nouveau mot de passe temporaire vous a été envoyé par SMS.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.vert,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Retour à la connexion', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
              // Bouton retour circulaire en haut à gauche
              DemeBackButton(
                onPressed: () {
                  if (_codeSent) {
                    setState(() => _codeSent = false);
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Logo centré
              const Center(
                child: DemeLogo(
                  size: 80,
                  textSize: 26,
                  showText: true,
                ),
              ),
              const SizedBox(height: 36),

              if (!_codeSent) ...[
                // Étape 1 : Saisie du numéro de téléphone
                const Text(
                  'Mot de passe oublié ?',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.texte,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Entrez votre numéro de téléphone pour recevoir un code de vérification et réinitialiser votre mot de passe.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.texteSecondaire,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 30),

                DemeTextField(
                  label: 'Numéro téléphone',
                  hintText: 'Entrez votre numéro de téléphone',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 36),

                SizedBox(
                  width: double.infinity,
                  child: DemeButton(
                    text: 'Envoyer le code',
                    isLoading: _isLoading,
                    onPressed: _sendCode,
                  ),
                ),
              ] else ...[
                // Étape 2 : Saisie du code OTP à 4 chiffres
                const Text(
                  'Code de vérification',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.texte,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Un code de vérification à 4 chiffres a été envoyé au ${_phoneController.text.trim()}.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.texteSecondaire,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 36),

                // 4 cases de code
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    return SizedBox(
                      width: 60,
                      height: 60,
                      child: TextField(
                        controller: _codeControllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.texte,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColors.bordure, width: 1.4),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColors.bordure, width: 1.4),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColors.vert, width: 2),
                          ),
                        ),
                        onChanged: (val) => _onCodeChanged(val, index),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 28),

                Center(
                  child: TextButton(
                    onPressed: _sendCode,
                    child: const Text(
                      'Renvoyer le code',
                      style: TextStyle(
                        color: AppColors.vert,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: DemeButton(
                    text: 'Vérifier',
                    isLoading: _isLoading,
                    onPressed: _verifyCode,
                  ),
                ),
              ],

              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    'Retour à la connexion',
                    style: TextStyle(
                      color: AppColors.vert,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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
