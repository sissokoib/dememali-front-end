import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/services/auth_service.dart';
import 'package:deme_mali_app/core/theme/app_colors.dart';
import 'package:deme_mali_app/screens/donateur/donateur_mes_dons_screen.dart';
import 'package:deme_mali_app/widgets/deme_components.dart';

/// ============================================================================
/// Écran : Faire un don matériel (Espace Donateur)
/// Conforme à la maquette Figma "Don materiel.png"
///
/// Permet à un donateur de donner des biens en nature (vêtements, vivres, fournitures)
/// en renseignant la catégorie, la quantité, la valeur estimée, l'état et le lieu de retrait.
/// ============================================================================
class DonMaterielScreen extends StatefulWidget {
  final Map<String, dynamic>? cause;

  const DonMaterielScreen({super.key, this.cause});

  @override
  State<DonMaterielScreen> createState() => _DonMaterielScreenState();
}

class _DonMaterielScreenState extends State<DonMaterielScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _categorieController = TextEditingController();
  final TextEditingController _quantiteController = TextEditingController();
  final TextEditingController _valeurController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();

  String? _selectedUnite;
  String? _selectedEtat;
  bool _isAnonyme = false;
  bool _isSubmitting = false;

  final List<String> _unites = [
    'Pièces',
    'Cartons',
    'Sacs',
    'Kilogrammes (kg)',
    'Lots',
    'Paires',
  ];

  final List<String> _etats = [
    'Neuf',
    'Très bon état',
    'Bon état',
    'État d\'usage',
  ];

  @override
  void dispose() {
    _categorieController.dispose();
    _quantiteController.dispose();
    _valeurController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  void _confirmerDon() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedUnite == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez choisir une unité')),
      );
      return;
    }

    if (_selectedEtat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner l\'état du matériel')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final String categorie = _categorieController.text.trim();
    final String quantite = _quantiteController.text.trim();
    final String valeur = _valeurController.text.trim();
    final String adresse = _adresseController.text.trim();

    // Enregistrer dans la session utilisateur
    final double valeurDouble = double.tryParse(valeur.replaceAll(RegExp(r'[^0-9]'), '')) ?? 25000;
    UserSession.userDons.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch,
      'causeNom': widget.cause?['titre'] ?? 'Don matériel : $categorie',
      'montant': valeurDouble,
      'typeDon': 'MATÉRIEL',
      'categorie': categorie,
      'quantite': '$quantite $_selectedUnite',
      'etat': _selectedEtat,
      'adresse': adresse,
      'estAnonyme': _isAnonyme,
      'dateDon': 'Aujourd\'hui',
      'statut': 'En attente de récupération',
    });

    setState(() => _isSubmitting = false);

    // Dialogue de confirmation chaleureux
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.vertClair,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.vert,
                  size: 42,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Don matériel enregistré !',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.texte,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Merci pour votre générosité ! Notre équipe partenaire prendra contact avec vous à l\'adresse indiquée pour organiser la récupération de votre don.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.texteSecondaire,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DonateurMesDonsScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.vert,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Voir mes dons',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bouton retour circulaire blanc
                const DemeBackButton(),
                const SizedBox(height: 20),

                // Titre
                const Text(
                  'Faire un don matériel',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.texte,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 28),

                // 1. Catégorie
                _buildFieldLabel('Catégorie'),
                const SizedBox(height: 8),
                _buildTextInput(
                  controller: _categorieController,
                  hintText: 'Saisir la categorie',
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Veuillez saisir la catégorie'
                      : null,
                ),
                const SizedBox(height: 18),

                // 2. Quantité
                _buildFieldLabel('Quantité'),
                const SizedBox(height: 8),
                _buildTextInput(
                  controller: _quantiteController,
                  hintText: 'Saisir la quantité',
                  keyboardType: TextInputType.number,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Veuillez saisir la quantité'
                      : null,
                ),
                const SizedBox(height: 18),

                // 3. Valeur estimée
                _buildFieldLabel('Valeur estimée'),
                const SizedBox(height: 8),
                _buildTextInput(
                  controller: _valeurController,
                  hintText: 'Saisir la valeur estimée (ex: 50 000 FCFA)',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 18),

                // 4. Unité
                _buildFieldLabel('Unité'),
                const SizedBox(height: 8),
                _buildDropdown(
                  value: _selectedUnite,
                  hintText: 'Choisir une unité',
                  items: _unites,
                  onChanged: (val) => setState(() => _selectedUnite = val),
                ),
                const SizedBox(height: 18),

                // 5. État du matériel
                _buildFieldLabel('État du matériel'),
                const SizedBox(height: 8),
                _buildDropdown(
                  value: _selectedEtat,
                  hintText: 'Sélectionner l’état',
                  items: _etats,
                  onChanged: (val) => setState(() => _selectedEtat = val),
                ),
                const SizedBox(height: 18),

                // 6. Adresse de récupération
                _buildFieldLabel('Adresse de récupération'),
                const SizedBox(height: 8),
                _buildTextInput(
                  controller: _adresseController,
                  hintText: 'Indiquer le lieu où le matériel peut être récupéré',
                  maxLines: 2,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Veuillez indiquer l\'adresse de récupération'
                      : null,
                ),
                const SizedBox(height: 20),

                // 7. Case à cocher : Faire un don anonyme
                InkWell(
                  onTap: () => setState(() => _isAnonyme = !_isAnonyme),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: _isAnonyme ? AppColors.vert : Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _isAnonyme ? AppColors.vert : AppColors.placeholder,
                              width: 1.5,
                            ),
                          ),
                          child: _isAnonyme
                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Faire un don anonyme',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.texte,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // 8. Bouton Confirmer vert
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _confirmerDon,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.vert,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Confirmer',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.texte,
      ),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bordure),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(fontSize: 14, color: AppColors.texte),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 14,
            color: AppColors.placeholder,
            fontWeight: FontWeight.normal,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hintText,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bordure),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            hintText,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.placeholder,
              fontWeight: FontWeight.normal,
            ),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.vert,
          ),
          items: items.map((e) {
            return DropdownMenuItem<String>(
              value: e,
              child: Text(
                e,
                style: const TextStyle(fontSize: 14, color: AppColors.texte),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
