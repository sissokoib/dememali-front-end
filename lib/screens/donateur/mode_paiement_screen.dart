import 'package:flutter/material.dart';
import 'package:deme_mali_app/screens/donateur/entrer_pin_screen.dart';

/// ============================================================================
/// Écran : Mode de paiement (Payement)
/// Inspiré de la maquette : iPhone 16 - 23.png
///
/// Permet à l'utilisateur de choisir entre :
/// - Orange Money
/// - Wave
/// - Moov Money
/// - Paypal
///
/// Conçu pour être très facile à comprendre et modifier.
/// ============================================================================

class ModePaiementScreen extends StatefulWidget {
  final int montant;
  final bool estAnonyme;

  const ModePaiementScreen({
    super.key,
    this.montant = 500,
    this.estAnonyme = false,
  });

  @override
  State<ModePaiementScreen> createState() => _ModePaiementScreenState();
}

class _ModePaiementScreenState extends State<ModePaiementScreen> {
  // Moyen de paiement sélectionné par défaut
  String _selectedPaymentMethod = "Orange Money";

  // Liste des moyens de paiement supportés
  final List<Map<String, dynamic>> _modesDePaiement = [
    {
      "id": "Orange Money",
      "nom": "Orange Money",
      "couleurLogo": Color(0xFFFF6600),
      "icone": Icons.arrow_upward_rounded,
      "lettre": "OM",
    },
    {
      "id": "Wave",
      "nom": "Wave",
      "couleurLogo": Color(0xFF1EA6EE),
      "icone": Icons.waves,
      "lettre": "W",
    },
    {
      "id": "Moov Money",
      "nom": "Moov Money",
      "couleurLogo": Color(0xFFEA5A0B),
      "icone": Icons.phone_android,
      "lettre": "M",
    },
    {
      "id": "Paypal",
      "nom": "Paypal",
      "couleurLogo": Color(0xFF003087),
      "icone": Icons.payment,
      "lettre": "P",
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Couleurs du design system Dèmè Mali
    const Color vertPrincipal = Color(0xFF137A4B);
    const Color fondBeige = Color(0xFFF7F4EB);
    const Color texteFonce = Color(0xFF1F1F1F);
    const Color texteGris = Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: fondBeige,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Bouton retour arrondi
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

              const SizedBox(height: 20),

              // 2. Titre et sous-titre
              const Center(
                child: Column(
                  children: [
                    Text(
                      "Payement",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: texteFonce,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Choisissez votre mode de payement",
                      style: TextStyle(
                        fontSize: 14,
                        color: texteGris,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // 3. Liste des options de paiement
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _modesDePaiement.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final mode = _modesDePaiement[index];
                  final isSelected = _selectedPaymentMethod == mode["id"];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPaymentMethod = mode["id"];
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? vertPrincipal : const Color(0xFFE5E7EB),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Badge ou logo visuel du service de paiement
                          _buildPaymentLogo(mode),

                          const SizedBox(width: 14),

                          // Nom du mode de paiement
                          Text(
                            mode["nom"],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: texteFonce,
                            ),
                          ),

                          const Spacer(),

                          // Indicateur Radio
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? vertPrincipal : Colors.grey.shade400,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? Center(
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(
                                        color: vertPrincipal,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const Spacer(),

              // 4. Bouton Continuer
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: vertPrincipal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    // Navigation vers la saisie du PIN
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EntrerPinScreen(
                          montant: widget.montant,
                          modePaiement: _selectedPaymentMethod,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Continuer",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Construit un badge coloré stylisé pour chaque fournisseur de paiement
  Widget _buildPaymentLogo(Map<String, dynamic> mode) {
    final String nom = mode["nom"];

    if (nom == "Orange Money") {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3EB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFF6600), width: 1),
        ),
        child: const Center(
          child: Icon(Icons.call_made, color: Color(0xFFFF6600), size: 20),
        ),
      );
    } else if (nom == "Wave") {
      return Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: Color(0xFF1EA6EE),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(Icons.water, color: Colors.white, size: 20),
        ),
      );
    } else if (nom == "Moov Money") {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFEA5A0B),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            "MOOV",
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } else {
      // Paypal
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFEAF2FF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            "P",
            style: TextStyle(
              color: Color(0xFF003087),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }
  }
}
