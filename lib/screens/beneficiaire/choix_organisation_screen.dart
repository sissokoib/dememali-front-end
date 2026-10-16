import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/services/demande_service.dart';
import 'package:deme_mali_app/screens/beneficiaire/dashboard_screen.dart';

/// ============================================================================
/// Écran : Choisir une organisation partenaire
///
/// Permet au bénéficiaire de sélectionner l'ONG ou l'association qui
/// valide et supervise sa demande d'aide.
/// Synchronisé avec les organisations partenaires du backend Spring Boot.
/// ============================================================================

class ChoixOrganisationScreen extends StatefulWidget {
  final double? montantDemande;
  final String? typeBesoin;

  const ChoixOrganisationScreen({
    super.key,
    this.montantDemande,
    this.typeBesoin,
  });

  @override
  State<ChoixOrganisationScreen> createState() => _ChoixOrganisationScreenState();
}

class _ChoixOrganisationScreenState extends State<ChoixOrganisationScreen> {
  final DemandeService _demandeService = DemandeService();
  String _selectedOrgId = "1";
  bool _isLoading = true;
  bool _isSubmitting = false;

  // Liste des organisations partenaires disponibles
  List<Map<String, dynamic>> _organisations = [];

  @override
  void initState() {
    super.initState();
    _chargerOrganisations();
  }

  Future<void> _chargerOrganisations() async {
    final backendOrgs = await _demandeService.fetchOrganisations();

    if (backendOrgs.isNotEmpty) {
      _organisations = backendOrgs.map((org) {
        return {
          "id": org["id"].toString(),
          "nom": org["nomOrganisation"] ?? org["nom"] ?? "Organisation partenaire",
          "ville": org["ville"] ?? "Bamako",
          "couleur": const Color(0xFF137A4B),
          "icone": Icons.account_balance,
        };
      }).toList();
    } else {
      // Liste de secours
      _organisations = [
        {
          "id": "1",
          "nom": "ONG Espoir Mali",
          "ville": "Bamako",
          "couleur": const Color(0xFF0F764D),
          "icone": Icons.favorite,
        },
        {
          "id": "2",
          "nom": "Association Dèmè",
          "ville": "Bamako",
          "couleur": const Color(0xFFF7A821),
          "icone": Icons.people,
        },
        {
          "id": "3",
          "nom": "Solidarité Mali",
          "ville": "Ségou",
          "couleur": const Color(0xFF0F764D),
          "icone": Icons.home,
        },
        {
          "id": "4",
          "nom": "Aide et Développement",
          "ville": "Kayes",
          "couleur": const Color(0xFFF7A821),
          "icone": Icons.eco,
        },
      ];
    }

    if (_organisations.isNotEmpty) {
      _selectedOrgId = _organisations.first["id"].toString();
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _soumettreDemande(Color vertPrincipal) async {
    setState(() => _isSubmitting = true);

    final selectedOrg = _organisations.firstWhere(
      (o) => o["id"].toString() == _selectedOrgId.toString(),
      orElse: () => _organisations.first,
    );
    final orgNom = selectedOrg["nom"]?.toString() ?? "Organisation partenaire";
    final orgId = int.tryParse(selectedOrg["id"].toString());

    final montant = widget.montantDemande ?? 150000.0;
    final titre = widget.typeBesoin != null ? "Demande : ${widget.typeBesoin}" : "Demande d'aide d'urgence";

    await _demandeService.creerDemande(
      titre: titre,
      description: "Dossier d'aide déposé auprès de $orgNom.",
      niveauUrgence: "MOYENNE",
      motif: "Besoin d'assistance directe et supervision humanitaire.",
      nombrePersonne: 1,
      montantNecessaire: montant,
      organisationPartenaireId: orgId,
      organisationNom: orgNom,
      categorieNom: widget.typeBesoin ?? "Aide humanitaire",
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Demande d'aide transmise à $orgNom avec succès !"),
        backgroundColor: vertPrincipal,
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
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

              const SizedBox(height: 16),

              // 2. Titre et description
              const Text(
                "Sélectionnez l'organisation\nqui vous accompagne",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: texteFonce,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Choisissez l'ONG ou l'association qui vous accompagne dans votre demande d'aide.",
                style: TextStyle(
                  fontSize: 14,
                  color: texteGris,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 24),

              // 3. Liste des cartes d'organisations partenaires
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: vertPrincipal))
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _organisations.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final org = _organisations[index];
                          final isSelected = _selectedOrgId == org["id"].toString();

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedOrgId = org["id"].toString();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: isSelected ? Border.all(color: vertPrincipal, width: 2) : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: org["couleur"] as Color,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      org["icone"] as IconData,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          org["nom"] as String,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: texteFonce,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          org["ville"] as String,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: texteGris,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE2F0E9),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.check_circle, size: 12, color: vertPrincipal),
                                              SizedBox(width: 4),
                                              Text(
                                                "Organisation partenaire",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: vertPrincipal,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 24,
                                    height: 24,
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
              ),

              // 4. Encadré d'aide
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF5F0),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.account_balance_outlined, color: vertPrincipal, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "L'organisation sélectionnée vérifiera vos justificatifs avant publication.",
                        style: TextStyle(fontSize: 12, color: texteFonce),
                      ),
                    ),
                  ],
                ),
              ),

              // 5. Bouton "Continuer" / "Valider la demande"
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: vertPrincipal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    elevation: 0,
                  ),
                  onPressed: _isSubmitting ? null : () => _soumettreDemande(vertPrincipal),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          "Transmettre ma demande",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
