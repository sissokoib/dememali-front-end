import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:deme_mali_app/core/services/demande_service.dart';
import 'package:deme_mali_app/screens/beneficiaire/dashboard_screen.dart';

/// ============================================================================
/// Écran : Demander une aide - Étape 3 sur 3 (Justificatifs)
///
/// Permet au demandeur de :
/// - Choisir le type de justificatif (Certificat médical, etc.)
/// - Téléverser ses preuves et documents (PDF, JPG, PNG)
/// - Visualiser la liste des justificatifs attachés
/// - Envoyer définitivement sa demande d'aide synchronisée avec le backend
///
/// Conforme au design de la maquette (Image 3).
/// ============================================================================
class DemandeAideStep3Screen extends StatefulWidget {
  final String titre;
  final String typeAide;
  final String description;
  final String urgence;
  final double montant;

  const DemandeAideStep3Screen({
    super.key,
    this.titre = "Demande d'aide",
    this.typeAide = "Alimentaire",
    this.description = "",
    this.urgence = "Urgente",
    this.montant = 150000.0,
  });

  @override
  State<DemandeAideStep3Screen> createState() => _DemandeAideStep3ScreenState();
}

class _DemandeAideStep3ScreenState extends State<DemandeAideStep3Screen> {
  final DemandeService _demandeService = DemandeService();
  bool _isSubmitting = false;

  // Type de justificatif sélectionné
  String _selectedTypeJustificatif = "Certificat médical";

  final List<String> _typesJustificatif = [
    "Certificat médical",
    "Facture / Devis",
    "Attestation de revenus",
    "Certificat de scolarité",
    "Pièce d'identité",
    "Autre document",
  ];

  // Liste des fichiers justificatifs attachés par l'utilisateur
  final List<Map<String, String>> _fichiers = [];

  /// Permet à l'utilisateur de choisir un ou plusieurs fichiers réels depuis son téléphone/appareil
  Future<void> _choisirFichier() async {
    try {
      final List<PlatformFile> files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (files.isNotEmpty) {
        for (final file in files) {
          final fileName = file.name;
          final ext = (file.extension ?? 'PDF').toUpperCase();
          int sizeInBytes = 0;
          try {
            sizeInBytes = await file.xFile.length();
          } catch (_) {}
          final sizeStr = sizeInBytes > 1024 * 1024
              ? '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB • Terminé'
              : sizeInBytes > 0
                  ? '${(sizeInBytes / 1024).toStringAsFixed(1)} KB • Terminé'
                  : 'Prêt';

          _fichiers.add({
            "nom": fileName,
            "taille": sizeStr,
            "ext": ext,
            if (file.path != null) "path": file.path!,
            "typeJustificatif": _selectedTypeJustificatif,
          });
        }
        setState(() {});

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${files.length} fichier(s) sélectionné(s) avec succès !'),
            backgroundColor: const Color(0xFF137A4B),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible d\'accéder aux fichiers : $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  void _supprimerFichier(int index) {
    setState(() {
      _fichiers.removeAt(index);
    });
  }

  Future<void> _soumettreDemande(Color vertPrincipal) async {
    setState(() => _isSubmitting = true);

    // Mappage du niveau d'urgence pour le backend
    String niveauUrgenceBackend = "FORTE";
    if (widget.urgence.toLowerCase().contains("faible")) {
      niveauUrgenceBackend = "FAIBLE";
    } else if (widget.urgence.toLowerCase().contains("moyen")) {
      niveauUrgenceBackend = "MOYENNE";
    }

    try {
      // Création et enregistrement de la demande d'aide
      await _demandeService.creerDemande(
        titre: widget.titre,
        description: widget.description.isNotEmpty
            ? widget.description
            : "Demande d'aide pour ${widget.titre}",
        niveauUrgence: niveauUrgenceBackend,
        motif: widget.typeAide,
        nombrePersonne: 1,
        montantNecessaire: widget.montant,
        categorieNom: widget.typeAide,
      );

      if (!mounted) return;

      setState(() => _isSubmitting = false);

      // Boîte de dialogue de succès
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFE2F0E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Color(0xFF137A4B), size: 48),
              ),
              const SizedBox(height: 20),
              const Text(
                'Demande transmise avec succès !',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Votre demande pour "${widget.titre}" d\'un montant de ${widget.montant.toStringAsFixed(0)} FCFA a bien été enregistrée et sera examinée par nos équipes.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx); // fermer dialogue
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const DashboardScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: vertPrincipal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Voir mon tableau de bord', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la soumission : $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color vertPrincipal = Color(0xFF137A4B);
    const Color fondBeige = Color(0xFFF6F4EB);

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
          'Justificatifs',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
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
                  Text('3 sur 3', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar (3 barres vertes)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(color: vertPrincipal, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(color: vertPrincipal, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(color: vertPrincipal, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Justifiez votre demande',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ajoutez les documents nécessaires pour nous aider à vérifier votre situation.',
                      style: TextStyle(fontSize: 13, color: Colors.black.withOpacity(0.6), height: 1.4),
                    ),
                    const SizedBox(height: 20),

                    // Carte principale blanche
                    Container(
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
                          const Text(
                            'TYPE DE JUSTIFICATIF',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Dropdown Type de Justificatif
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: vertPrincipal, width: 1.5),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedTypeJustificatif,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down, color: vertPrincipal),
                                items: _typesJustificatif.map((t) {
                                  return DropdownMenuItem<String>(
                                    value: t,
                                    child: Row(
                                      children: [
                                        const Icon(Icons.description_outlined, color: vertPrincipal, size: 20),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            t,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedTypeJustificatif = val);
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Zone de dépôt de justificatif (Dashed upload box)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FBF9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: vertPrincipal.withOpacity(0.6),
                                width: 1.2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.description_outlined, color: vertPrincipal, size: 28),
                                    ),
                                    Positioned(
                                      bottom: -4,
                                      right: -4,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: vertPrincipal,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(2),
                                        child: const Icon(Icons.add, color: Colors.white, size: 14),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                const Text(
                                  'Ajouter un justificatif',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'PDF, JPG ou PNG',
                                  style: TextStyle(color: Colors.black45, fontSize: 12),
                                ),
                                const SizedBox(height: 14),
                                ElevatedButton(
                                  onPressed: _choisirFichier,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: vertPrincipal,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Choisir un fichier',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Fichiers attachés
                          ..._fichiers.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final f = entry.value;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6F4EB),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: vertPrincipal),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: vertPrincipal,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      f["ext"] ?? "PDF",
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          f["nom"] ?? "fichier.pdf",
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          f["taille"] ?? "1.0 MB • Terminé",
                                          style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.black87),
                                    onPressed: () => _supprimerFichier(idx),
                                  ),
                                ],
                              ),
                            );
                          }),

                          const SizedBox(height: 8),

                          Center(
                            child: TextButton.icon(
                              onPressed: _choisirFichier,
                              icon: const Icon(Icons.add, color: vertPrincipal, size: 18),
                              label: const Text(
                                'Ajouter un autre justificatif',
                                style: TextStyle(
                                  color: vertPrincipal,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Boutons d'action en bas : Retour & Envoyer ma demande
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        backgroundColor: Colors.white,
                        elevation: 0,
                      ),
                      child: const Text(
                        'Retour',
                        style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : () => _soumettreDemande(vertPrincipal),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: vertPrincipal,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Envoyer ma demande',
                              style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
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