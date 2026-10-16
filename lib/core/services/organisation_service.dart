import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:deme_mali_app/core/services/auth_service.dart';

/// ============================================================================
/// Service : Espace Organisation Partenaire (ONG / Association)
///
/// Gère les opérations de terrain de l'organisation :
/// 1. Tableau de bord & indicateurs (/api/dashboard/organisation/{id})
/// 2. Demandes d'aide assignées (/api/demandes-aide/organisation/{id})
/// 3. Visites / Études de terrain (/api/etudes-terrain)
/// 4. Rapports de besoin (/api/rapports-besoin)
/// 5. Rapports techniques (/api/rapports-techniques)
/// 6. Vérification / Validation des demandes (/api/demandes-aide/{id}/valider /verifier /rejeter)
/// 7. Bénéficiaires suivis et enregistrés (/api/beneficiaires/organisation/{id})
/// ============================================================================
class OrganisationService {
  static String get baseUrl => AuthService.baseUrl;

  Map<String, String> _headers() {
    final headers = {'Content-Type': 'application/json'};
    if (UserSession.token != null) {
      headers['Authorization'] = 'Bearer ${UserSession.token}';
    }
    return headers;
  }

  int get currentOrgId {
    if (UserSession.currentUserOrganisationId != null &&
        UserSession.currentUserOrganisationId! > 0) {
      return UserSession.currentUserOrganisationId!;
    }
    if (UserSession.currentUserId != null && UserSession.currentUserId! > 0) {
      return UserSession.currentUserId!;
    }
    return 8; // ID de fallback pour la Fondation Orange / Organisation active
  }

  /// 1. Récupère les statistiques du tableau de bord de l'organisation
  Future<Map<String, dynamic>> fetchDashboard([int? orgId]) async {
    final id = orgId ?? currentOrgId;
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/dashboard/organisation/$id'), headers: _headers())
          .timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(utf8.decode(res.bodyBytes)));
      }
    } catch (e) {
      debugPrint('[OrganisationService] Erreur fetchDashboard: $e');
    }
    return {
      'totalBeneficiaires': 4,
      'totalDemandesAide': 2,
      'demandesEnAttente': 2,
      'demandesValidees': 0,
      'demandesRefusees': 0,
      'montantTotalCollecte': 0,
    };
  }

  /// 2. Récupère les demandes d'aide assignées à l'organisation
  Future<List<Map<String, dynamic>>> fetchDemandesOrganisation([int? orgId]) async {
    final id = orgId ?? currentOrgId;
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/demandes-aide/organisation/$id'), headers: _headers())
          .timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(res.bodyBytes));
        return list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      }
    } catch (e) {
      debugPrint('[OrganisationService] Erreur fetchDemandesOrganisation: $e');
    }
    return [];
  }

  /// 3. Récupère les bénéficiaires suivis par cette organisation
  Future<List<Map<String, dynamic>>> fetchBeneficiairesOrganisation([int? orgId]) async {
    final id = orgId ?? currentOrgId;
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/beneficiaires/organisation/$id'), headers: _headers())
          .timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(res.bodyBytes));
        return list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      }
    } catch (e) {
      debugPrint('[OrganisationService] Erreur fetchBeneficiairesOrganisation: $e');
    }
    return [];
  }

  /// 4. Récupère toutes les études de terrain de l'organisation
  Future<List<Map<String, dynamic>>> fetchEtudesTerrain([int? orgId]) async {
    final id = orgId ?? currentOrgId;
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/etudes-terrain/organisation/$id'), headers: _headers())
          .timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(res.bodyBytes));
        return list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      }
    } catch (e) {
      debugPrint('[OrganisationService] Erreur fetchEtudesTerrain: $e');
    }
    return [];
  }

  /// 5. Récupère les études de terrain pour une demande précise
  Future<List<Map<String, dynamic>>> fetchEtudesTerrainDemande(int demandeAideId) async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/etudes-terrain/demande/$demandeAideId'), headers: _headers())
          .timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(res.bodyBytes));
        return list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      }
    } catch (e) {
      debugPrint('[OrganisationService] Erreur fetchEtudesTerrainDemande: $e');
    }
    return [];
  }

  /// 6. Crée une nouvelle étude / visite de terrain
  Future<Map<String, dynamic>?> creerEtudeTerrain({
    required int demandeAideId,
    int? organisationPartenaireId,
    required String datePlanification,
    required String dateRealisation,
    required String heure,
    required String lieu,
    required String objectif,
    required String observation,
    required String resultat, // 'CONFORME', 'BESOIN_REAJUSTE', 'NON_CONFORME'
    String status = 'TERMINEE', // 'EN_ATTENTE', 'PLANIFIEE', 'TERMINEE'
  }) async {
    final orgId = organisationPartenaireId ?? currentOrgId;

    // Normaliser l'heure au format ISO complet si nécessaire
    String formattedHeure = heure;
    if (!heure.contains('T')) {
      final datePart = dateRealisation.isNotEmpty ? dateRealisation : datePlanification;
      formattedHeure = '${datePart}T${heure.padLeft(5, '0')}:00';
    }

    final payload = {
      'demandeAideId': demandeAideId,
      'organisationPartenaireId': orgId,
      'datePlanification': datePlanification,
      'dateRealisation': dateRealisation,
      'heure': formattedHeure,
      'lieu': lieu,
      'objectif': objectif,
      'observation': observation,
      'resultat': resultat,
      'status': status,
    };

    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/etudes-terrain'),
            headers: _headers(),
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 5));

      if (res.statusCode == 200 || res.statusCode == 201) {
        return Map<String, dynamic>.from(jsonDecode(utf8.decode(res.bodyBytes)));
      } else {
        debugPrint('[OrganisationService] Échec creerEtudeTerrain (${res.statusCode}): ${res.body}');
      }
    } catch (e) {
      debugPrint('[OrganisationService] Erreur creerEtudeTerrain: $e');
    }
    return null;
  }

  /// 7. Crée un rapport de besoin lié à une étude de terrain
  Future<Map<String, dynamic>?> creerRapportBesoin({
    required int etudeTerrainId,
    required String titre,
    required String besoinIdentifie,
    required String descriptionSituation,
    required String solutionProposee,
    required double montantEstime,
  }) async {
    final payload = {
      'etudeTerrainId': etudeTerrainId,
      'titre': titre,
      'besoinIdentifie': besoinIdentifie,
      'descriptionSituation': descriptionSituation,
      'solutionProposee': solutionProposee,
      'montantEstime': montantEstime,
    };

    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/rapports-besoin'),
            headers: _headers(),
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 5));

      if (res.statusCode == 200 || res.statusCode == 201) {
        return Map<String, dynamic>.from(jsonDecode(utf8.decode(res.bodyBytes)));
      } else {
        debugPrint('[OrganisationService] Échec creerRapportBesoin (${res.statusCode}): ${res.body}');
      }
    } catch (e) {
      debugPrint('[OrganisationService] Erreur creerRapportBesoin: $e');
    }
    return null;
  }

  /// 8. Récupère le rapport de besoin associé à une étude de terrain
  Future<Map<String, dynamic>?> fetchRapportBesoinByEtude(int etudeTerrainId) async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/rapports-besoin/etude-terrain/$etudeTerrainId'), headers: _headers())
          .timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(utf8.decode(res.bodyBytes)));
      }
    } catch (e) {
      debugPrint('[OrganisationService] Erreur fetchRapportBesoinByEtude: $e');
    }
    return null;
  }

  /// 9. Crée un rapport technique chiffré lié à un rapport de besoin
  Future<Map<String, dynamic>?> creerRapportTechnique({
    required int rapportBesoinId,
    required String descriptionTechnique,
    required List<Map<String, dynamic>> details, // [{ designation, quantite, unite, prixUnitaire }]
  }) async {
    final payload = {
      'rapportBesoinId': rapportBesoinId,
      'descriptionTechnique': descriptionTechnique,
      'details': details,
    };

    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/rapports-techniques'),
            headers: _headers(),
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 5));

      if (res.statusCode == 200 || res.statusCode == 201) {
        return Map<String, dynamic>.from(jsonDecode(utf8.decode(res.bodyBytes)));
      } else {
        debugPrint('[OrganisationService] Échec creerRapportTechnique (${res.statusCode}): ${res.body}');
      }
    } catch (e) {
      debugPrint('[OrganisationService] Erreur creerRapportTechnique: $e');
    }
    return null;
  }

  /// 10. Récupère le rapport technique associé à un rapport de besoin
  Future<Map<String, dynamic>?> fetchRapportTechniqueByBesoin(int rapportBesoinId) async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/rapports-techniques/rapport-besoin/$rapportBesoinId'), headers: _headers())
          .timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(utf8.decode(res.bodyBytes)));
      }
    } catch (e) {
      debugPrint('[OrganisationService] Erreur fetchRapportTechniqueByBesoin: $e');
    }
    return null;
  }

  /// 11. Valider et certifier la demande après vérification terrain
  Future<bool> validerDemande(int demandeId) async {
    try {
      final res = await http
          .patch(Uri.parse('$baseUrl/demandes-aide/$demandeId/valider'), headers: _headers())
          .timeout(const Duration(seconds: 5));

      return res.statusCode == 200 || res.statusCode == 204;
    } catch (e) {
      debugPrint('[OrganisationService] Erreur validerDemande: $e');
    }
    return false;
  }

  /// 12. Rejeter la demande si le constat terrain est défavorable
  Future<bool> rejeterDemande(int demandeId) async {
    try {
      final res = await http
          .patch(Uri.parse('$baseUrl/demandes-aide/$demandeId/rejeter'), headers: _headers())
          .timeout(const Duration(seconds: 5));

      return res.statusCode == 200 || res.statusCode == 204;
    } catch (e) {
      debugPrint('[OrganisationService] Erreur rejeterDemande: $e');
    }
    return false;
  }

  /// 13. Marquer comme vérifiée
  Future<bool> verifierDemande(int demandeId) async {
    try {
      final res = await http
          .patch(Uri.parse('$baseUrl/demandes-aide/$demandeId/verifier'), headers: _headers())
          .timeout(const Duration(seconds: 5));

      return res.statusCode == 200 || res.statusCode == 204;
    } catch (e) {
      debugPrint('[OrganisationService] Erreur verifierDemande: $e');
    }
    return false;
  }

  /// 14. Enregistrer un bénéficiaire particulier rencontré sur le terrain
  Future<Map<String, dynamic>?> enregistrerBeneficiaire({
    int? organisationId,
    required String nom,
    required String prenom,
    required String telephone,
    required String ville,
    required String adresse,
    String? situationMatrimoniale,
    int? nbEnfants,
    String? dateNaissance,
    String? handicap,
    String? besoins,
  }) async {
    final orgId = organisationId ?? currentOrgId;
    final payload = {
      'nom': nom,
      'prenom': prenom,
      'telephone': telephone,
      'ville': ville,
      'adresse': adresse,
      'situationMatrimoniale': situationMatrimoniale ?? 'CELIBATAIRE',
      'nbEnfants': nbEnfants ?? 0,
      'dateNaissance': dateNaissance ?? '1990-01-01',
      'handicap': handicap ?? 'AUCUN',
      'besoins': besoins ?? 'Aide d\'urgence',
      'organisationPartenaireId': orgId,
      'motDePasse': 'Pass@1234',
    };

    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/organisations-partenaires/$orgId/beneficiaires/particuliers'),
            headers: _headers(),
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 5));

      if (res.statusCode == 200 || res.statusCode == 201) {
        return Map<String, dynamic>.from(jsonDecode(utf8.decode(res.bodyBytes)));
      }
    } catch (e) {
      debugPrint('[OrganisationService] Erreur enregistrerBeneficiaire: $e');
    }
    return null;
  }

  /// 15. Inscription d'une nouvelle organisation partenaire
  Future<Map<String, dynamic>> inscrireOrganisation({
    required String nomOrganisation,
    required String typeOrganisation, // 'ONG', 'ASSOCIATION', 'FONDATION'
    required String nif,
    required String adresse,
    required String ville,
    required String email,
    required String telephoneOrganisation,
    required String nomResponsable,
    required String prenomResponsable,
    required String telephoneResponsable,
    required String motDePasse,
  }) async {
    await AuthService.getValidBaseUrl();
    final payload = {
      'nom': nomResponsable,
      'prenom': prenomResponsable,
      'telephone': telephoneResponsable,
      'motDePasse': motDePasse,
      'nomOrganisation': nomOrganisation,
      'typeOrganisation': typeOrganisation,
      'nif': nif,
      'adresse': adresse,
      'ville': ville,
      'email': email,
      'telephoneOrganisation': telephoneOrganisation,
    };

    http.Response res;
    try {
      res = await http
          .post(
            Uri.parse('$baseUrl/organisations-partenaires'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      try {
        await AuthService.getValidBaseUrl(force: true);
        res = await http
            .post(
              Uri.parse('$baseUrl/organisations-partenaires'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(payload),
            )
            .timeout(const Duration(seconds: 7));
      } catch (e) {
        return {
          'success': false,
          'message': 'Connexion au serveur backend impossible. Assurez-vous d\'être sur le même réseau Wi-Fi que votre ordinateur.',
        };
      }
    }

    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      return {'success': true, 'data': data};
    } else {
      String msg = 'Erreur lors de l\'inscription de l\'organisation.';
      try {
        final err = jsonDecode(utf8.decode(res.bodyBytes));
        if (err is Map && err['message'] != null) msg = err['message'].toString();
      } catch (_) {}
      return {'success': false, 'message': msg};
    }
  }
}
