import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:deme_mali_app/core/services/auth_service.dart';

/// ============================================================================
/// Service : Gestion des demandes d'aide et synchronisation Backend
///
/// Fait le pont entre l'application Flutter et les APIs Spring Boot :
/// - /api/demandes-aide
/// - /api/organisations-partenaires
/// - /api/dons
/// ============================================================================
class DemandeService {
  static String get baseUrl => AuthService.baseUrl;

  Map<String, String> _headers() {
    final headers = {'Content-Type': 'application/json'};
    if (UserSession.token != null) {
      headers['Authorization'] = 'Bearer ${UserSession.token}';
    }
    return headers;
  }

  /// Récupère toutes les demandes d'aide depuis le backend
  Future<List<Map<String, dynamic>>> fetchDemandes() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/demandes-aide'), headers: _headers())
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(response.bodyBytes));
        return list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Récupère les demandes disponibles pour un don (statut PUBLIEE)
  Future<List<Map<String, dynamic>>> fetchDemandesDisponibles() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/demandes-aide/disponibles-pour-don'), headers: _headers())
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(response.bodyBytes));
        if (list.isNotEmpty) {
          return list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
        }
      }
    } catch (_) {}

    // Si indisponible ou vide, tenter toutes les demandes
    return fetchDemandes();
  }

  /// Récupère les demandes d'un bénéficiaire précis
  Future<List<Map<String, dynamic>>> fetchDemandesBeneficiaire(int beneficiaireId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/demandes-aide/beneficiaire/$beneficiaireId'), headers: _headers())
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(response.bodyBytes));
        return list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Récupère la liste des organisations partenaires réelles de la base de données
  Future<List<Map<String, dynamic>>> fetchOrganisations() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/organisations-partenaires'), headers: _headers())
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(response.bodyBytes));
        return list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Crée une nouvelle demande d'aide sur le serveur Spring Boot et l'ajoute à la session
  Future<Map<String, dynamic>?> creerDemande({
    required String titre,
    required String description,
    required String niveauUrgence, // 'FAIBLE', 'MOYENNE', 'FORTE'
    required String motif,
    required int nombrePersonne,
    required double montantNecessaire,
    int? organisationPartenaireId,
    String? organisationNom,
    String? categorieNom,
  }) async {
    int beneficiaireId = UserSession.currentUserId ?? 0;
    if (beneficiaireId <= 0) {
      try {
        final res = await http.get(Uri.parse('$baseUrl/beneficiaires/particuliers'), headers: _headers());
        if (res.statusCode == 200) {
          final list = jsonDecode(utf8.decode(res.bodyBytes)) as List;
          if (list.isNotEmpty) beneficiaireId = list.first['id'] as int;
        }
      } catch (_) {}
    }
    if (beneficiaireId <= 0) beneficiaireId = 111;

    final int orgId = (organisationPartenaireId != null && organisationPartenaireId > 0)
        ? organisationPartenaireId
        : 8;

    // Déterminer la catégorie (1=Logement, 2=Santé, 3=Alimentation, 4=Éducation, 5=Urgence Sociale)
    int catId = 2; // Santé par défaut
    final motifLower = ('$motif ${categorieNom ?? ''}').toLowerCase();
    if (motifLower.contains('alim') || motifLower.contains('nourr')) {
      catId = 3;
    } else if (motifLower.contains('educ') || motifLower.contains('scol')) {
      catId = 4;
    } else if (motifLower.contains('log') || motifLower.contains('habit')) {
      catId = 1;
    } else if (motifLower.contains('urg') || motifLower.contains('soc')) {
      catId = 5;
    }

    final payload = {
      'titre': titre,
      'descriptionSituation': description,
      'niveauUrgence': niveauUrgence,
      'motif': motif,
      'nombrePersonne': nombrePersonne,
      'montantNecessaire': montantNecessaire,
      'beneficiaireId': beneficiaireId,
      'organisationPartenaireId': orgId,
      'categorieDemandeId': catId,
      'typeDemande': 'INDIVIDUEL',
    };

    // Objet local mémorisé dans la session
    final localDemande = {
      'id': DateTime.now().millisecondsSinceEpoch % 100000,
      'titre': titre,
      'descriptionSituation': description,
      'statut': 'EN_ATTENTE',
      'statutTexte': 'En cours de vérification',
      'niveauUrgence': niveauUrgence,
      'motif': motif,
      'nombrePersonne': nombrePersonne,
      'montantNecessaire': montantNecessaire,
      'organisationPartenaireId': orgId,
      'organisationPartenaireNom': organisationNom ?? 'Fondation Orange',
      'categorieDemandeNom': categorieNom ?? 'Aide générale',
      'dateCreation': DateTime.now().toIso8601String().split('T').first,
    };

    // Mémoriser localement en premier
    UserSession.addDemande(localDemande);

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/demandes-aide'),
            headers: _headers(),
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final created = jsonDecode(utf8.decode(response.bodyBytes));
        if (created is Map<String, dynamic>) {
          localDemande['id'] = created['id'] ?? localDemande['id'];
          localDemande['statut'] = created['statut'] ?? localDemande['statut'];
        }
        return Map<String, dynamic>.from(localDemande);
      }
    } catch (_) {}

    return localDemande;
  }

  /// Récupère l'historique des dons
  Future<List<Map<String, dynamic>>> fetchDons() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/dons'), headers: _headers())
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(response.bodyBytes));
        return list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Enregistre un don
  Future<bool> creerDon({
    required double montant,
    required String typeDon, // 'FINANCIER' ou 'MATERIEL'
    String? modePaiement,
    bool anonyme = false,
    int? demandeAideId,
  }) async {
    int donateurId = UserSession.currentUserId ?? 0;
    if (donateurId <= 0) {
      try {
        final res = await http.get(Uri.parse('$baseUrl/donateurs'), headers: _headers());
        if (res.statusCode == 200) {
          final list = jsonDecode(utf8.decode(res.bodyBytes)) as List;
          if (list.isNotEmpty) {
            donateurId = list.first['id'] as int;
          }
        }
      } catch (_) {}
    }

    String mappedMode = 'ORANGE_MONEY';
    if (modePaiement != null) {
      final p = modePaiement.toLowerCase();
      if (p.contains('wave')) {
        mappedMode = 'WAVE';
      } else if (p.contains('moov') || p.contains('move')) {
        mappedMode = 'MOVE_MONEY';
      } else if (p.contains('espece')) {
        mappedMode = 'ESPECES';
      }
    }

    final endpoint = typeDon.toUpperCase() == 'FINANCIER'
        ? '$baseUrl/dons-financiers'
        : '$baseUrl/dons-materiels';

    final payload = {
      'montant': montant,
      'modePaiement': mappedMode,
      'typeDon': 'FINANCIER',
      'anonyme': anonyme,
      'donateurId': donateurId > 0 ? donateurId : 101,
      if (demandeAideId != null) 'demandeAideId': demandeAideId,
    };

    final localDon = {
      'id': DateTime.now().millisecondsSinceEpoch % 100000,
      'montant': montant,
      'typeDon': typeDon,
      'modePaiement': mappedMode,
      'dateDon': DateTime.now().toIso8601String().split('T').first,
      'statut': 'VALIDE',
    };
    UserSession.addDon(localDon);

    try {
      final response = await http
          .post(
            Uri.parse(endpoint),
            headers: _headers(),
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 4));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return true; // Conservé localement en cas d'indisponibilité
    }
  }
}
