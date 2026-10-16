import 'package:flutter/material.dart';
import 'package:deme_mali_app/screens/beneficiaire/demande_aide_step2_screen.dart';

/// ============================================================================
/// Écran : Demander une aide - Étape 1 sur 3
///
/// Permet au demandeur de renseigner :
/// 1. Le titre de sa demande
/// 2. Le type d'aide (Alimentaire, Médicale, Scolaire, Logement, Autre)
/// 3. La description de son besoin
/// 4. Le niveau d'urgence (Faible, Moyenne, Urgente)
///
/// Conforme au design de la maquette (Image 1).
/// ============================================================================
class DemandeAideStep1Screen extends StatefulWidget {
  const DemandeAideStep1Screen({super.key});

  @override
  State<DemandeAideStep1Screen> createState() => _DemandeAideStep1ScreenState();
}

class _DemandeAideStep1ScreenState extends State<DemandeAideStep1Screen> {
  final TextEditingController _titreController = TextEditingController(text: "Aide alimentaire pour ma famille");
  final TextEditingController _descriptionController = TextEditingController();

  // Type d'aide sélectionné (par défaut "Alimentaire" comme sur la maquette)
  String _selectedType = "Alimentaire";

  // Niveau d'urgence ("Faible", "Moyenne", "Urgente" - Urgente par défaut comme sur la maquette)
  String _selectedUrgence = "Urgente";

  // Liste des options disponibles
  final List<Map<String, dynamic>> _typesDisponibles = [
    {"label": "Alimentaire", "icon": Icons.restaurant},
    {"label": "Médicale", "icon": Icons.medical_services_outlined},
    {"label": "Scolaire", "icon": Icons.school_outlined},
    {"label": "Logement", "icon": Icons.home_outlined},
    {"label": "Autre", "icon": Icons.category_outlined},
  ];

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    const Color vertPrincipal = Color(0xFF137A4B);
    const Color fondBeige = Color(0xFFF6F4EB);
    const Color bordureClaire = Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: fondBeige,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Demander une aide',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFF7A821)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  CircleAvatar(radius: 4, backgroundColor: Color(0xFFF7A821)),
                  SizedBox(width: 6),
                  Text(
                    '1 sur 3',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Stepper (Barres de progression) : 1 verte, 2 blanches
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: vertPrincipal,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Formulaire principal
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. TITRE DE LA DEMANDE
                      const Text(
                        'TITRE DE LA DEMANDE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _titreController,
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'Aide alimentaire pour ma famille',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: bordureClaire),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: vertPrincipal, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 2. TYPE D'AIDE
                      const Text(
                        'TYPE D’AIDE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Menu déroulant / sélecteur avec bordure verte
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: vertPrincipal, width: 1.5),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedType,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, color: vertPrincipal),
                            items: _typesDisponibles.map((type) {
                              final label = type["label"] as String;
                              final icon = type["icon"] as IconData;
                              return DropdownMenuItem<String>(
                                value: label,
                                child: Row(
                                  children: [
                                    Icon(icon, color: vertPrincipal, size: 20),
                                    const SizedBox(width: 12),
                                    Text(
                                      label,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedType = val);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Autres options disponibles (chips rapides)
                      const Text(
                        'Autres options disponibles :',
                        style: TextStyle(fontSize: 12, color: Colors.black45),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          'Médicale',
                          'Scolaire',
                          'Logement',
                          'Autre',
                        ].map((option) {
                          final isSelected = _selectedType.toLowerCase() == option.toLowerCase();
                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedType = option);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? vertPrincipal.withOpacity(0.12) : const Color(0xFFF6F4EB),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? vertPrincipal : Colors.grey.shade300,
                                ),
                              ),
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? vertPrincipal : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // 3. DESCRIPTION DU BESOIN
                      const Text(
                        'DESCRIPTION DU BESOIN',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 4,
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'Expliquez votre besoin...',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                          contentPadding: const EdgeInsets.all(16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: bordureClaire),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: vertPrincipal, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 4. URGENCE
                      const Text(
                        'URGENCE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildUrgenceButton('Faible', vertPrincipal),
                          const SizedBox(width: 8),
                          _buildUrgenceButton('Moyenne', vertPrincipal),
                          const SizedBox(width: 8),
                          _buildUrgenceButton('Urgente', vertPrincipal),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bouton d'action Continuer en bas
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final titre = _titreController.text.trim();
                    final desc = _descriptionController.text.trim();

                    if (titre.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Veuillez renseigner le titre de la demande'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    // Navigation vers l'Étape 2 avec passage des données
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DemandeAideStep2Screen(
                          titre: titre,
                          typeAide: _selectedType,
                          description: desc.isNotEmpty ? desc : "Besoin d'aide : $titre",
                          urgence: _selectedUrgence,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: vertPrincipal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Continuer',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrgenceButton(String label, Color vertPrincipal) {
    final bool isSelected = _selectedUrgence.toLowerCase() == label.toLowerCase();

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedUrgence = label);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? vertPrincipal : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? vertPrincipal : Colors.grey.shade300,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}