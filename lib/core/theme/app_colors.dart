import 'package:flutter/material.dart';

/// ============================================================================
/// Charte graphique Dèmè Mali (issue de la maquette Figma "Charte graphique")
///
/// - Vert principal   : #0F7A4B  (solidarité, confiance)
/// - Jaune accent     : #F7B500  (espoir, générosité)
/// - Gris foncé       : #1F1F1F  (titres, paragraphes)
/// - Ivoire crème     : #F7F3EA  (arrière-plan de l'application)
/// ============================================================================
class AppColors {
  AppColors._();

  static const Color vert = Color(0xFF0F7A4B);
  static const Color jaune = Color(0xFFF7B500);
  static const Color texte = Color(0xFF1F1F1F);
  static const Color ivoire = Color(0xFFF7F3EA);

  // Couleurs secondaires dérivées
  static const Color texteSecondaire = Color(0xFF6B6B6B);
  static const Color vertClair = Color(0xFFE5F1EA);
  static const Color jauneClair = Color(0xFFFFF1C7);
  static const Color bordure = Color(0xFFE9E3D3);
  static const Color placeholder = Color(0xFF9A9AA5);
  static const Color vertDesactive = Color(0xFFA7C9B8);
  static const Color orange = Color(0xFFF08A1C);
}
