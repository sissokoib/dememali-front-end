import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/services/auth_service.dart';
import 'package:deme_mali_app/core/services/demande_service.dart';
import 'package:deme_mali_app/screens/donateur/donateur_mes_dons_screen.dart';

/// ============================================================================
/// Écran : Saisie du code PIN & Confirmation de don
/// Inspiré de : iPhone 16 - 24.png, iPhone 16 - 25.png et Frame 394.png
///
/// Ce code implémente :
/// - Une rangée de 6 indicateurs ronds (gris quand vide, verts quand remplis)
/// - Un clavier numérique virtuel intuitif pour saisir le code
/// - Le passage dynamique d'un bouton "Continuer" aux boutons "Annuler" / "Confirmer"
/// - Une boîte de dialogue modale de succès "Don réussi !" fidèle à la maquette
/// ============================================================================

class EntrerPinScreen extends StatefulWidget {
  final int montant;
  final String modePaiement;

  const EntrerPinScreen({
    super.key,
    this.montant = 500,
    this.modePaiement = "Orange Money",
  });

  @override
  State<EntrerPinScreen> createState() => _EntrerPinScreenState();
}

class _EntrerPinScreenState extends State<EntrerPinScreen> {
  // Chaîne de caractères pour stocker les chiffres du PIN saisis
  String _pin = "";

  // Fonction pour ajouter un chiffre au PIN
  void _onNumberTap(int number) {
    if (_pin.length < 6) {
      setState(() {
        _pin += number.toString();
      });
    }
  }

  // Fonction pour effacer le dernier chiffre
  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  // Afficher la boîte de dialogue de succès "Don réussi !" (Frame 394.png)
  void _showSuccessDialog(BuildContext context) {
    const Color vertPrincipal = Color(0xFF137A4B);

    final double montantDon = widget.montant.toDouble();
    UserSession.addDon({
      'id': DateTime.now().millisecondsSinceEpoch % 100000,
      'montant': montantDon,
      'typeDon': 'FINANCIER',
      'dateDon': DateTime.now().toIso8601String().split('T').first,
      'causeNom': 'Don par ${widget.modePaiement}',
    });
    DemandeService().creerDon(
      montant: montantDon,
      typeDon: 'FINANCIER',
      modePaiement: widget.modePaiement,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Grand cercle vert avec coche blanche
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: vertPrincipal,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.check, color: Colors.white, size: 40),
                  ),
                ),

                const SizedBox(height: 20),

                // Titre
                const Text(
                  "Don réussi !",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: vertPrincipal,
                  ),
                ),

                const SizedBox(height: 12),

                // Messages de remerciement
                const Text(
                  "Merci pour votre générosité.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4B5563),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                const Text(
                  "Votre don a bien été enregistré.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 28),

                // Bouton Terminer
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: vertPrincipal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(dialogContext); // Fermer la modale
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const DonateurMesDonsScreen()),
                      );
                    },
                    child: const Text(
                      "Terminer",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Couleurs Dèmè Mali
    const Color vertPrincipal = Color(0xFF137A4B);
    const Color fondBeige = Color(0xFFF7F4EB);
    const Color texteFonce = Color(0xFF1F1F1F);
    const Color texteGris = Color(0xFF6B7280);

    final bool isPinComplet = _pin.length == 6;

    return Scaffold(
      backgroundColor: fondBeige,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Bouton retour circulaire
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
                      "Entrer votre PIN",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: texteFonce,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Veuillez saisir votre code PIN",
                      style: TextStyle(
                        fontSize: 14,
                        color: texteGris,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 44),

              // 3. Rangée des 6 indicateurs de PIN (cercles gris ou verts)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  final bool estRempli = index < _pin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: estRempli ? vertPrincipal : const Color(0xFFD1D5DB),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),

              const SizedBox(height: 32),

              // 4. Clavier numérique virtuel pour saisir le PIN
              Expanded(
                child: _buildNumericKeypad(vertPrincipal, texteFonce),
              ),

              // 5. Boutons du bas (Continuer OU Annuler + Confirmer selon l'état du PIN)
              if (!isPinComplet)
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
                      // Si l'utilisateur clique sans avoir fini, on peut l'inviter à continuer
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Veuillez saisir vos 6 chiffres")),
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
                )
              else
                Row(
                  children: [
                    // Bouton Annuler
                    Expanded(
                      child: SizedBox(
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
                            setState(() {
                              _pin = "";
                            });
                          },
                          child: const Text(
                            "Annuler",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Bouton Confirmer
                    Expanded(
                      child: SizedBox(
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
                            _showSuccessDialog(context);
                          },
                          child: const Text(
                            "Confirmer",
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

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Clavier numérique virtuel de 1 à 9, avec 0 et la touche d'effacement
  Widget _buildNumericKeypad(Color vertPrincipal, Color texteFonce) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildKeypadRow(["1", "2", "3"]),
        const SizedBox(height: 14),
        _buildKeypadRow(["4", "5", "6"]),
        const SizedBox(height: 14),
        _buildKeypadRow(["7", "8", "9"]),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Case vide pour équilibrer
            const SizedBox(width: 65, height: 65),
            _buildKeypadButton("0"),
            // Bouton retour arrière (effacer)
            GestureDetector(
              onTap: _onBackspace,
              child: Container(
                width: 65,
                height: 65,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.backspace_outlined, color: Color(0xFF1F1F1F), size: 24),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Ligne de 3 touches du clavier numérique
  Widget _buildKeypadRow(List<String> values) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: values.map((val) => _buildKeypadButton(val)).toList(),
    );
  }

  /// Bouton individuel circulaire du clavier numérique
  Widget _buildKeypadButton(String label) {
    return GestureDetector(
      onTap: () => _onNumberTap(int.parse(label)),
      child: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F1F1F),
            ),
          ),
        ),
      ),
    );
  }
}
