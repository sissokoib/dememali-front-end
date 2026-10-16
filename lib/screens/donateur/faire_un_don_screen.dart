import 'package:flutter/material.dart';
import 'package:deme_mali_app/screens/donateur/mode_paiement_screen.dart';

/// ============================================================================
/// Écran : Faire un don (Choix ou saisie du montant)
/// Inspiré des maquettes : iPhone 16 - 21.png et iPhone 16 - 22.png
///
/// Permet à un utilisateur de :
/// 1. Choisir un montant rapide (200F, 300F, 400F, 500F, 600F, 700F) ou saisir manuellement
/// 2. Cocher l'option "Faire un don anonyme"
/// 3. Cliquer sur "Continuer" pour choisir son mode de paiement
/// ============================================================================

class FaireUnDonScreen extends StatefulWidget {
  final Map<String, dynamic>? cause;
  final int? montantInitial;

  const FaireUnDonScreen({super.key, this.cause, this.montantInitial});

  @override
  State<FaireUnDonScreen> createState() => _FaireUnDonScreenState();
}

class _FaireUnDonScreenState extends State<FaireUnDonScreen> {
  // Montant actuellement sélectionné (en FCFA)
  late int _montant;

  // Option pour le don anonyme
  bool _estAnonyme = false;

  @override
  void initState() {
    super.initState();
    _montant = widget.montantInitial ?? 500;
  }

  // Liste des montants prédéfinis affichés sous forme de boutons
  final List<int> _montantsPredefinis = [200, 300, 400, 500, 600, 700];

  @override
  Widget build(BuildContext context) {
    // Couleurs de la charte graphique Dèmè Mali
    const Color vertPrincipal = Color(0xFF137A4B);
    const Color fondBeige = Color(0xFFF7F4EB);
    const Color texteFonce = Color(0xFF1F1F1F);
    const Color texteGris = Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: fondBeige,
      body: SafeArea(
        child: SingleChildScrollView(
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
                      "Faire un don",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: texteFonce,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Choisissez ou Saisisez un montant",
                      style: TextStyle(
                        fontSize: 14,
                        color: texteGris,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // 3. Grande carte affichant le montant choisi
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: vertPrincipal, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    "$_montant FCFA",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: vertPrincipal,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 4. Grille des montants prédéfinis (2 lignes de 3 colonnes)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _montantsPredefinis.length,
                itemBuilder: (context, index) {
                  final montant = _montantsPredefinis[index];
                  final isSelected = _montant == montant;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _montant = montant;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? vertPrincipal : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: vertPrincipal,
                          width: 1.2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "$montant F",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : vertPrincipal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // 5. Case à cocher : "Faire un don anonyme"
              GestureDetector(
                onTap: () {
                  setState(() {
                    _estAnonyme = !_estAnonyme;
                  });
                },
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: _estAnonyme ? vertPrincipal : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: vertPrincipal,
                          width: 1.5,
                        ),
                      ),
                      child: _estAnonyme
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Faire un don anonyme",
                      style: TextStyle(
                        fontSize: 14,
                        color: texteFonce,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 6. Bouton "Continuer"
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
                    // Navigation vers l'écran de sélection du moyen de paiement
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ModePaiementScreen(
                          montant: _montant,
                          estAnonyme: _estAnonyme,
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
}
