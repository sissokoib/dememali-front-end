import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/services/demande_service.dart';
import 'package:deme_mali_app/core/services/auth_service.dart';
import 'package:deme_mali_app/screens/donateur/faire_un_don_screen.dart';
import 'package:deme_mali_app/screens/donateur/choix_type_don_screen.dart';
import 'package:deme_mali_app/screens/beneficiaire/details_aide_screen.dart';
import 'package:deme_mali_app/widgets/bottom_nav_bar.dart';

/// ============================================================================
/// Écran : Demandes d'aide (Pour donateur / public)
/// Inspiré des maquettes : iPhone 16 - 16.png et iPhone 16 - 17.png
///
/// Ce code utilise des concepts Flutter simples :
/// - StatefulWidget pour gérer la catégorie sélectionnée et la recherche
/// - SingleChildScrollView et ListView pour le défilement
/// - Des widgets Container, Row, Column avec commentaires détaillés en français
/// ============================================================================

class DemandesAideScreen extends StatefulWidget {
  const DemandesAideScreen({super.key});

  @override
  State<DemandesAideScreen> createState() => _DemandesAideScreenState();
}

class _DemandesAideScreenState extends State<DemandesAideScreen> {
  // Catégorie actuellement sélectionnée ("Tous", "Urgent", "Médical", etc.)
  String _selectedCategory = "Tous";

  // Contrôleur pour la barre de recherche
  final TextEditingController _searchController = TextEditingController();

  // Service des demandes
  final DemandeService _demandeService = DemandeService();

  // Liste des catégories disponibles pour les filtres
  final List<String> _categories = [
    "Tous",
    "Urgent",
    "Médical",
    "Alimentaire",
    "Scolaire",
  ];

  @override
  void initState() {
    super.initState();
    _chargerDemandesLive();
  }

  Future<void> _chargerDemandesLive() async {
    final live = await _demandeService.fetchDemandesDisponibles();
    final List<Map<String, dynamic>> nouvelles = [];

    // Ajouter les demandes réelles créées en session
    for (final d in UserSession.userDemandes) {
      nouvelles.add({
        "titre": d["titre"] ?? "Besoin de soutien humanitaire",
        "description": d["descriptionSituation"] ?? d["description"] ?? "Dossier vérifié par notre ONG partenaire.",
        "categorie": d["categorieDemandeNom"] ?? "Médical",
        "typeBadge": (d["niveauUrgence"] == "FORTE") ? "Urgent" : "Actif",
        "montantActuel": (d["montantCollecte"] is num) ? (d["montantCollecte"] as num).toInt() : 0,
        "montantCible": (d["montantNecessaire"] is num) ? (d["montantNecessaire"] as num).toInt() : 150000,
        "donateurs": 2,
        "joursRestants": 12,
        "imageUrl": "https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?auto=format&fit=crop&w=600&q=80",
      });
    }

    // Ajouter les demandes renvoyées par le backend
    for (final d in live) {
      nouvelles.add({
        "titre": d["titre"] ?? "Demande de soutien",
        "description": d["descriptionSituation"] ?? "Prise en charge directe.",
        "categorie": d["categorieDemandeNom"] ?? "Urgent",
        "typeBadge": (d["niveauUrgence"] == "FORTE") ? "Urgent" : "Actif",
        "montantActuel": (d["montantCollecte"] is num) ? (d["montantCollecte"] as num).toInt() : 0,
        "montantCible": (d["montantNecessaire"] is num) ? (d["montantNecessaire"] as num).toInt() : 200000,
        "donateurs": 1,
        "joursRestants": 14,
        "imageUrl": "https://images.unsplash.com/photo-1516574187841-cb9cc2ca948b?auto=format&fit=crop&w=600&q=80",
      });
    }

    if (nouvelles.isNotEmpty && mounted) {
      setState(() {
        _allDemandes.insertAll(0, nouvelles);
      });
    }
  }

  // Liste des exemples de demandes d'aide avec leurs informations
  final List<Map<String, dynamic>> _allDemandes = [
    {
      "titre": "Frais d'hospitalisation pour Moussa",
      "description": "Prise en charge des soins intensifs suite à un grave accident.",
      "categorie": "Urgent",
      "typeBadge": "Urgent",
      "montantActuel": 450000,
      "montantCible": 600000,
      "donateurs": 38,
      "joursRestants": 8,
      "imageUrl": "https://images.unsplash.com/photo-1516574187841-cb9cc2ca948b?auto=format&fit=crop&w=600&q=80",
    },
    {
      "titre": "Aide médicale pour Fatou",
      "description": "Fatou doit subir une opération ophtalmologique urgente pour sauver sa vue.",
      "categorie": "Médical",
      "typeBadge": "Urgent",
      "montantActuel": 125000,
      "montantCible": 250000,
      "donateurs": 14,
      "joursRestants": 5,
      "imageUrl": "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=600&q=80",
    },
    {
      "titre": "Fournitures scolaires pour orphelins",
      "description": "Financement des kits scolaires et frais d'inscription pour 25 écoliers.",
      "categorie": "Scolaire",
      "typeBadge": "Scolaire",
      "montantActuel": 80000,
      "montantCible": 160000,
      "donateurs": 9,
      "joursRestants": 12,
      "imageUrl": "https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?auto=format&fit=crop&w=600&q=80",
    },
    {
      "titre": "Paniers alimentaires pour 15 familles",
      "description": "Aide d'urgence en denrées de première nécessité (riz, huile, lait, sucre).",
      "categorie": "Alimentaire",
      "typeBadge": "Alimentaire",
      "montantActuel": 320000,
      "montantCible": 400000,
      "donateurs": 22,
      "joursRestants": 4,
      "imageUrl": "https://images.unsplash.com/photo-1593113598332-cd288d649433?auto=format&fit=crop&w=600&q=80",
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Couleurs de la charte graphique Dèmè Mali
    const Color vertPrincipal = Color(0xFF137A4B);
    const Color fondBeige = Color(0xFFF7F4EB);
    const Color texteFonce = Color(0xFF1F1F1F);
    const Color texteGris = Color(0xFF6B7280);
    const Color badgeJaune = Color(0xFFF7A821);

    // Filtrer les demandes en fonction de la catégorie et du texte de recherche
    final filteredDemandes = _allDemandes.where((demande) {
      final matchesCategory = _selectedCategory == "Tous" ||
          demande["categorie"] == _selectedCategory ||
          demande["typeBadge"] == _selectedCategory;
      final query = _searchController.text.toLowerCase();
      final matchesQuery = demande["titre"].toString().toLowerCase().contains(query) ||
          demande["description"].toString().toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: fondBeige,
      body: SafeArea(
        child: Column(
          children: [
            // 1. En-tête : Bouton retour, Titre et Cloche de notifications
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Bouton retour arrondi
                  _buildCircleButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),

                  // Titre principal centré
                  const Text(
                    "Demandes d'aide",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: texteFonce,
                    ),
                  ),

                  // Bouton cloche avec point jaune de notification
                  _buildCircleButton(
                    icon: Icons.notifications_none,
                    hasBadge: true,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Vous n'avez pas de nouvelle notification")),
                      );
                    },
                  ),
                ],
              ),
            ),

            // 2. Contenu déroulant
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sous-titre explicatif
                    const Text(
                      "Découvrez les personnes et familles qui ont besoin de votre soutien.",
                      style: TextStyle(
                        fontSize: 14,
                        color: texteGris,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Barre de recherche
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: texteGris, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                hintText: "Rechercher une demande...",
                                hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear, size: 18, color: texteGris),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Filtres horizontaux (Tous, Urgent, Médical, etc.)
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final isSelected = category == _selectedCategory;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? vertPrincipal : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? vertPrincipal : const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? Colors.white : texteFonce,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Nombre de demandes trouvées
                    Text(
                      "${filteredDemandes.length} demandes trouvées",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: texteFonce,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Liste des cartes de demandes d'aide
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredDemandes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final item = filteredDemandes[index];
                        return _buildDemandeCard(item, vertPrincipal, texteFonce, texteGris, badgeJaune);
                      },
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const DonateurBottomNavBar(currentIndex: 1),
    );
  }

  /// Bouton circulaire blanc pour l'en-tête
  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    bool hasBadge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: const Color(0xFF1F1F1F), size: 22),
            if (hasBadge)
              Positioned(
                top: 10,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF7A821),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Carte complète d'une demande d'aide avec photo, jauge et bouton
  Widget _buildDemandeCard(
    Map<String, dynamic> item,
    Color vertPrincipal,
    Color texteFonce,
    Color texteGris,
    Color badgeJaune,
  ) {
    final double progression = (item["montantActuel"] as int) / (item["montantCible"] as int);
    final int pourcentage = (progression * 100).toInt();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailsAideScreen(
              demande: item,
              showDonationButton: true,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image avec badge superposé
          Stack(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                color: Colors.grey.shade200,
                child: Image.network(
                  item["imageUrl"],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFE2F0E9),
                      child: const Center(
                        child: Icon(Icons.image, size: 50, color: Color(0xFF137A4B)),
                      ),
                    );
                  },
                ),
              ),
              // Badge en haut à gauche (ex : Urgent ou Scolaire)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: item["typeBadge"] == "Urgent" ? badgeJaune : vertPrincipal,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item["typeBadge"] == "Urgent") ...[
                        const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.black),
                        const SizedBox(width: 4),
                        const Text(
                          "Urgent",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ] else ...[
                        Text(
                          item["typeBadge"],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Contenu texte de la carte
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre de l'aide
                Text(
                  item["titre"],
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: texteFonce,
                  ),
                ),

                const SizedBox(height: 6),

                // Description
                Text(
                  item["description"],
                  style: TextStyle(
                    fontSize: 13,
                    color: texteGris,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 14),

                // Barre de progression
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progression.clamp(0.0, 1.0),
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: AlwaysStoppedAnimation<Color>(vertPrincipal),
                    minHeight: 6,
                  ),
                ),

                const SizedBox(height: 10),

                // Ligne des montants et du pourcentage
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "${item["montantActuel"]} ",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: texteFonce,
                            ),
                          ),
                          TextSpan(
                            text: "/ ${item["montantCible"]} FCFA",
                            style: TextStyle(
                              fontSize: 13,
                              color: texteGris,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "$pourcentage%",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: vertPrincipal,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Informations sur les donateurs et jours restants
                Row(
                  children: [
                    Icon(Icons.people_outline, size: 16, color: texteGris),
                    const SizedBox(width: 4),
                    Text(
                      "${item["donateurs"]} donateurs",
                      style: TextStyle(fontSize: 12, color: texteGris),
                    ),
                    const Spacer(),
                    Icon(Icons.access_time, size: 16, color: texteGris),
                    const SizedBox(width: 4),
                    Text(
                      "Il reste ${item["joursRestants"]} jours",
                      style: TextStyle(fontSize: 12, color: texteGris),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Bouton "Faire un don"
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: vertPrincipal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChoixTypeDonScreen(cause: item),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border, size: 18),
                        SizedBox(width: 8),
                        Text(
                          "Faire un don",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}
