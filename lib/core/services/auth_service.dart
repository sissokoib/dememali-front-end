import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;

/// ============================================================================
/// Session utilisateur globale en mémoire pour l'application Dèmè Mali
///
/// Mémorise l'état et les données de l'utilisateur connecté ou inscrit :
/// identifiants, profil, demandes créées, dons effectués.
/// Permet de synchroniser dynamiquement l'application avec le backend Spring Boot.
/// ============================================================================
class UserSession {
  static int? currentUserId;
  static String? currentUserName;
  static String? currentUserNom;
  static String? currentUserPrenom;
  static String? currentUserEmail;
  static String? currentUserRole; // 'Bénéficiaire', 'Donateur' ou 'Organisation'
  static int? currentUserOrganisationId;
  static String? currentUserPhone;
  static String? currentUserCity;
  static String? currentUserGender;
  static String? currentUserSituationMatrimoniale;
  static String? currentUserTypeBeneficiaire;
  static String? currentUserTypeBeneficiaireParticulier;
  static String? currentUserHandicap;
  static int? currentUserNbEnfants;
  static String? currentUserBesoins;
  static String? currentUserNomStructure;
  static String? currentUserNina;
  static String? currentUserNif;
  static String? currentUserAddress;
  static String? currentUserDateNaissance;
  static String? tempPassword;
  static String? token;

  // Demandes d'aide de l'utilisateur (en mémoire & synchronisées avec le backend)
  static List<Map<String, dynamic>> userDemandes = [];

  // Dons effectués par l'utilisateur
  static List<Map<String, dynamic>> userDons = [];

  static void setUser({
    int? id,
    required String name,
    required String email,
    required String role,
    String? phone,
    String? city,
    String? jwtToken,
    String? nom,
    String? prenom,
    String? gender,
    String? situationMatrimoniale,
    String? typeBeneficiaire,
    String? handicap,
    int? nbEnfants,
    String? besoins,
  }) {
    currentUserId = id;
    currentUserName = name;
    currentUserNom = nom;
    currentUserPrenom = prenom;
    currentUserEmail = email;
    currentUserRole = role;
    currentUserPhone = phone;
    currentUserCity = city;
    currentUserGender = gender;
    currentUserSituationMatrimoniale = situationMatrimoniale;
    currentUserTypeBeneficiaire = typeBeneficiaire;
    currentUserHandicap = handicap;
    currentUserNbEnfants = nbEnfants;
    currentUserBesoins = besoins;
    token = jwtToken;
  }

  static void addDemande(Map<String, dynamic> demande) {
    userDemandes.insert(0, demande);
  }

  static void addDon(Map<String, dynamic> don) {
    userDons.insert(0, don);
  }

  static void clear() {
    currentUserId = null;
    currentUserName = null;
    currentUserNom = null;
    currentUserPrenom = null;
    currentUserEmail = null;
    currentUserRole = null;
    currentUserOrganisationId = null;
    currentUserPhone = null;
    currentUserCity = null;
    currentUserGender = null;
    currentUserSituationMatrimoniale = null;
    currentUserTypeBeneficiaire = null;
    currentUserHandicap = null;
    currentUserNbEnfants = null;
    currentUserBesoins = null;
    currentUserAddress = null;
    currentUserDateNaissance = null;
    tempPassword = null;
    token = null;
    userDemandes.clear();
    userDons.clear();
  }
}

class AuthService {
  static String? _resolvedBaseUrl;

  // 1. Localhost via adb reverse (idéal en débogage USB/Wi-Fi adb)
  static const String _localhostUrl = 'http://localhost:8080/api';
  static const String _loopbackUrl = 'http://127.0.0.1:8080/api';
  // 2. IP Wi-Fi locale réelle du PC sur le réseau 192.168.10.x
  static const String _pcWifiUrl = 'http://192.168.10.90:8080/api';
  static const String _pcWifiOldUrl = 'http://192.168.100.82:8080/api';
  // 3. Émulateur Android
  static const String _emulatorUrl = 'http://10.0.2.2:8080/api';

  static List<String> get candidateUrls {
    if (kIsWeb) return [_localhostUrl];
    if (Platform.isAndroid) {
      return [_localhostUrl, _pcWifiUrl, _loopbackUrl, _emulatorUrl, _pcWifiOldUrl];
    }
    return [_localhostUrl, _pcWifiUrl, _pcWifiOldUrl];
  }

  // URL active par défaut
  static String get baseUrl => _resolvedBaseUrl ?? _localhostUrl;

  /// Détecte et mémorise automatiquement l'URL qui répond
  static Future<String> getValidBaseUrl({bool force = false}) async {
    if (_resolvedBaseUrl != null && !force) return _resolvedBaseUrl!;

    for (final url in candidateUrls) {
      try {
        final res = await http
            .get(Uri.parse('$url/utilisateurs'))
            .timeout(const Duration(milliseconds: 2000));
        if (res.statusCode >= 200 && res.statusCode < 500) {
          _resolvedBaseUrl = url;
          debugPrint('[Dèmè Mali] Backend connecté avec succès sur : $url');
          return url;
        }
      } catch (_) {}
    }

    _resolvedBaseUrl = _localhostUrl;
    return _resolvedBaseUrl!;
  }

  /// Connexion utilisateur via /api/auth/login
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    await getValidBaseUrl();
    try {
      String telephoneToUse = identifier.trim();

      // Si l'identifiant saisi contient un @ ou des lettres alphabétiques (email ou nom),
      // on recherche le numéro de téléphone correspondant dans la base du backend (/api/utilisateurs)
      final hasAlphaOrAt = identifier.contains('@') || RegExp(r'[a-zA-Z]').hasMatch(identifier);
      if (hasAlphaOrAt) {
        try {
          final usersResponse = await http
              .get(Uri.parse('$baseUrl/utilisateurs'))
              .timeout(const Duration(seconds: 4));

          if (usersResponse.statusCode == 200) {
            final List<dynamic> users = jsonDecode(utf8.decode(usersResponse.bodyBytes));
            final cleanId = identifier.toLowerCase().trim();

            for (final u in users) {
              if (u is Map<String, dynamic>) {
                final email = (u['email'] ?? '').toString().toLowerCase();
                final nom = (u['nom'] ?? '').toString().toLowerCase();
                final prenom = (u['prenom'] ?? '').toString().toLowerCase();
                final fullName = '$prenom $nom'.trim();
                final fullNameRev = '$nom $prenom'.trim();
                final userPhone = (u['telephone'] ?? '').toString();

                if (email == cleanId ||
                    (nom.isNotEmpty && cleanId.contains(nom) && prenom.isNotEmpty && cleanId.contains(prenom)) ||
                    fullName == cleanId ||
                    fullNameRev == cleanId) {
                  if (userPhone.isNotEmpty) {
                    telephoneToUse = userPhone;
                    break;
                  }
                }
              }
            }
          }
        } catch (_) {
          // Continuer avec telephoneToUse
        }
      }

      // Nettoyer les espaces et le préfixe pays (+223 ou 00223)
      telephoneToUse = telephoneToUse.replaceAll(RegExp(r'[\s\-\.]'), '');
      if (telephoneToUse.startsWith('+223')) {
        telephoneToUse = telephoneToUse.substring(4);
      } else if (telephoneToUse.startsWith('00223')) {
        telephoneToUse = telephoneToUse.substring(5);
      }

      http.Response response;
      try {
        response = await http
            .post(
              Uri.parse('$baseUrl/auth/login'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'telephone': telephoneToUse,
                'motDePasse': password,
              }),
            )
            .timeout(const Duration(seconds: 5));
      } catch (_) {
        // En cas d'échec sur l'URL par défaut, tente la détection dynamique d'URL de secours
        await getValidBaseUrl(force: true);
        response = await http
            .post(
              Uri.parse('$baseUrl/auth/login'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'telephone': telephoneToUse,
                'motDePasse': password,
              }),
            )
            .timeout(const Duration(seconds: 7));
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data is Map<String, dynamic>) {
          final user = data['user'];
          if (user != null && user is Map<String, dynamic>) {
            final prenom = user['prenom'] ?? '';
            final nom = user['nom'] ?? '';
            final nomComplet = '$prenom $nom'.trim();
            final roleRaw = user['role']?.toString().toUpperCase() ?? '';
            String role;
            if (roleRaw.contains('ORGANIS') || roleRaw.contains('PARTENAIRE')) {
              role = 'Organisation';
            } else if (roleRaw.contains('DONAT')) {
              role = 'Donateur';
            } else {
              role = 'Bénéficiaire';
            }

            final orgId = user['organisationPartenaireId'] ??
                (role == 'Organisation' ? user['id'] : null);
            final nomStructure = user['nomOrganisation'] ?? user['nomStructure'];

            UserSession.currentUserOrganisationId = orgId as int?;
            if (nomStructure != null) {
              UserSession.currentUserNomStructure = nomStructure.toString();
            }

            UserSession.setUser(
              id: user['id'] as int?,
              name: nomComplet.isNotEmpty ? nomComplet : (nomStructure?.toString() ?? identifier),
              email: (user['email'] ?? identifier).toString(),
              role: role,
              phone: user['telephone']?.toString() ?? telephoneToUse,
              jwtToken: data['accessToken']?.toString(),
              nom: nom.toString(),
              prenom: prenom.toString(),
            );
          }
        }
        return {'success': true, 'data': data};
      } else {
        String errorMessage = 'Téléphone ou mot de passe incorrect.';
        try {
          final errBody = jsonDecode(utf8.decode(response.bodyBytes));
          if (errBody is Map<String, dynamic>) {
            if (errBody['message'] != null && errBody['message'].toString().isNotEmpty) {
              errorMessage = errBody['message'].toString();
            } else if (errBody['error'] != null && errBody['error'].toString().isNotEmpty) {
              errorMessage = errBody['error'].toString();
            }
          }
        } catch (_) {}

        if (response.statusCode == 401 || response.statusCode == 403) {
          if (errorMessage.toLowerCase().contains('attente') ||
              errorMessage.toLowerCase().contains('validation')) {
            errorMessage = "Votre compte est en cours de validation par un administrateur.";
          } else if (errorMessage.toLowerCase().contains('rejet') ||
              errorMessage.toLowerCase().contains('refus')) {
            errorMessage = "Votre demande d'inscription a été refusée par l'administrateur.";
          } else {
            errorMessage = "Numéro de téléphone ou mot de passe incorrect.";
          }
        }

        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Impossible de joindre le serveur ($baseUrl). Vérifiez votre connexion au backend.',
      };
    }
  }

  Future<http.Response> _postJson(String endpoint, Map<String, dynamic> dto) async {
    await getValidBaseUrl();
    try {
      return await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(dto),
          )
          .timeout(const Duration(seconds: 4));
    } catch (_) {
      // Basculement automatique vers l'IP Wi-Fi ou localhost
      await getValidBaseUrl(force: true);
      return await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(dto),
          )
          .timeout(const Duration(seconds: 7));
    }
  }

  /// Inscription d'un bénéficiaire particulier via /api/beneficiaires/particuliers
  Future<Map<String, dynamic>> registerBeneficiaireParticulier(
      Map<String, dynamic> dto) async {
    try {
      final response = await _postJson('/beneficiaires/particuliers', dto);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(utf8.decode(response.bodyBytes))};
      } else {
        String msg = 'Erreur lors de l\'enregistrement (${response.statusCode})';
        try {
          final errBody = jsonDecode(utf8.decode(response.bodyBytes));
          if (errBody is Map<String, dynamic>) {
            if (errBody['message'] != null && errBody['message'].toString().isNotEmpty) {
              msg = errBody['message'].toString();
            } else if (errBody['error'] != null && errBody['error'].toString().isNotEmpty) {
              msg = errBody['error'].toString();
            }
          }
        } catch (_) {}
        return {'success': false, 'message': msg};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connexion au serveur impossible. Vérifiez votre Wi-Fi ou connectez votre téléphone via USB.',
      };
    }
  }

  /// Inscription d'un bénéficiaire structure via /api/beneficiaires/structures
  Future<Map<String, dynamic>> registerBeneficiaireStructure(
      Map<String, dynamic> dto) async {
    try {
      final response = await _postJson('/beneficiaires/structures', dto);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(utf8.decode(response.bodyBytes))};
      } else {
        String msg = 'Erreur lors de l\'enregistrement (${response.statusCode})';
        try {
          final errBody = jsonDecode(utf8.decode(response.bodyBytes));
          if (errBody is Map<String, dynamic>) {
            if (errBody['message'] != null && errBody['message'].toString().isNotEmpty) {
              msg = errBody['message'].toString();
            } else if (errBody['error'] != null && errBody['error'].toString().isNotEmpty) {
              msg = errBody['error'].toString();
            }
          }
        } catch (_) {}
        return {'success': false, 'message': msg};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connexion au serveur impossible. Vérifiez votre Wi-Fi ou connectez votre téléphone via USB.',
      };
    }
  }

  /// Inscription d'un donateur via /api/donateurs
  Future<Map<String, dynamic>> registerDonateur(
      Map<String, dynamic> dto) async {
    try {
      final response = await _postJson('/donateurs', dto);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(utf8.decode(response.bodyBytes))};
      } else {
        String msg = 'Erreur lors de l\'enregistrement (${response.statusCode})';
        try {
          final errBody = jsonDecode(utf8.decode(response.bodyBytes));
          if (errBody is Map<String, dynamic>) {
            if (errBody['message'] != null && errBody['message'].toString().isNotEmpty) {
              msg = errBody['message'].toString();
            } else if (errBody['error'] != null && errBody['error'].toString().isNotEmpty) {
              msg = errBody['error'].toString();
            }
          }
        } catch (_) {}
        return {'success': false, 'message': msg};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connexion au serveur backend impossible. Assurez-vous que votre téléphone et votre ordinateur sont sur le même réseau Wi-Fi.',
      };
    }
  }

  /// Méthode d'inscription générique (rétrocompatibilité)
  Future<Map<String, dynamic>> register({
    required String email,
    required String phone,
    required String password,
    required String managerName,
  }) async {
    return registerBeneficiaireParticulier({
      'email': email,
      'telephone': phone,
      'motDePasse': password,
      'nom': managerName,
      'prenom': managerName,
    });
  }
}
