import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/services/auth_service.dart';
import 'package:deme_mali_app/screens/donateur/choisir_cause_screen.dart';
import 'package:deme_mali_app/screens/donateur/choix_type_don_screen.dart';
import 'package:deme_mali_app/screens/beneficiaire/demandes_aide_screen.dart';
import 'package:deme_mali_app/screens/beneficiaire/details_aide_screen.dart';
import 'package:deme_mali_app/screens/donateur/donateur_mes_dons_screen.dart';
import 'package:deme_mali_app/screens/donateur/create_cagnotte_screen.dart';
import 'package:deme_mali_app/screens/beneficiaire/dashboard_screen.dart';
import 'package:deme_mali_app/widgets/bottom_nav_bar.dart';

/// ============================================================================
/// Écran : Tableau de bord DONATEUR (Dèmè Mali)
///
/// Interface dédiée aux donateurs :
/// - Suivi d'impact des dons réalisés
/// - Découverte des campagnes et urgences
/// - Dons rapides et parrainage de causes
/// - Barre de navigation dédiée au Donateur
/// - Bascule facile vers la vue Bénéficiaire pour tester les deux interfaces
/// ============================================================================

class DonateurDashboardScreen extends StatelessWidget {
  const DonateurDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color vertPrincipal = Color(0xFF137A4B);
    const Color fondBeige = Color(0xFFF6F4EB);
    const Color orangeAccent = Color(0xFFF7A821);

    return Scaffold(
      backgroundColor: fondBeige,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: IconButton(
              icon: const Icon(Icons.volunteer_activism, color: vertPrincipal, size: 20),
              onPressed: () {},
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(text: 'Dème ', style: TextStyle(color: vertPrincipal)),
                  TextSpan(text: 'Mali', style: TextStyle(color: orangeAccent)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: vertPrincipal.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Donateur',
                style: TextStyle(color: vertPrincipal, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.black, size: 20),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Salutation et badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                'Bonjour ${(UserSession.currentUserPrenom?.trim().isNotEmpty == true) ? UserSession.currentUserPrenom!.trim() : (UserSession.currentUserName != null && UserSession.currentUserName!.trim().isNotEmpty ? (UserSession.currentUserName!.trim().length <= 16 ? UserSession.currentUserName!.trim() : UserSession.currentUserName!.trim().split(' ').first) : "Donateur")} ',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Text('👋', style: TextStyle(fontSize: 22)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: orangeAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: orangeAccent, size: 14),
                            SizedBox(width: 4),
                            Text(
                              "Donateur Solidaire",
                              style: TextStyle(color: orangeAccent, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Merci de contribuer à une solidarité plus forte au Mali.',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),

                  // CARTE D'IMPACT DU DONATEUR
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF137A4B), Color(0xFF0F5A38)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: vertPrincipal.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Votre impact solidaire",
                              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const DonateurMesDonsScreen()),
                                );
                              },
                              child: const Row(
                                children: [
                                  Text(
                                    "Voir l'historique",
                                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  Icon(Icons.chevron_right, color: Colors.white, size: 16),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "${UserSession.userDons.fold(0.0, (acc, item) => acc + ((item['montant'] as num?)?.toDouble() ?? 0.0)).toInt()} FCFA",
                          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMiniImpact("${UserSession.userDons.length}", "Causes soutenues", Icons.favorite_border),
                            _buildMiniImpact(UserSession.userDons.isNotEmpty ? "+${UserSession.userDons.length * 3}" : "0", "Vies impactées", Icons.people_outline),
                            _buildMiniImpact("100%", "Direct aux bénéficiaires", Icons.verified_outlined),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 4 RACCOURCIS CLÉS DU DONATEUR
                  const Text(
                    'Actions rapides',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildActionShortcut(
                          icon: Icons.favorite,
                          color: const Color(0xFFE53935),
                          bgColor: const Color(0xFFFFEBEE),
                          title: 'Faire un don',
                          subtitle: 'Causes urgentes',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ChoixTypeDonScreen()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionShortcut(
                          icon: Icons.search,
                          color: vertPrincipal,
                          bgColor: const Color(0xFFE2F0E9),
                          title: 'Explorer',
                          subtitle: 'Toutes les aides',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const DemandesAideScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionShortcut(
                          icon: Icons.card_giftcard,
                          color: orangeAccent,
                          bgColor: const Color(0xFFFEF3E2),
                          title: 'Mes dons',
                          subtitle: 'Reçus & historique',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const DonateurMesDonsScreen()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionShortcut(
                          icon: Icons.add_circle_outline,
                          color: const Color(0xFF1E88E5),
                          bgColor: const Color(0xFFE3F2FD),
                          title: 'Créer cagnotte',
                          subtitle: 'Lancer un projet',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CreateCagnotteScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Hero Banner : "Faites la différence aujourd'hui"
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: Image.network(
                            'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?q=80&w=600&auto=format&fit=crop',
                            height: 130,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.volunteer_activism, color: vertPrincipal, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    "Faites la différence aujourd'hui",
                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Votre don permet d'acheter des médicaments vitaux ou des kits scolaires pour des enfants défavorisés.",
                                style: TextStyle(color: Colors.black54, height: 1.4, fontSize: 13),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const ChoixTypeDonScreen()),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: vertPrincipal,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Faire un don direct', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward, color: Colors.white, size: 18),
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
                ],
              ),
            ),

            // SECTION CAMPAGNES EN COURS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Campagnes prioritaires',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DemandesAideScreen()),
                      );
                    },
                    child: const Row(
                      children: [
                        Text('Voir tout', style: TextStyle(color: vertPrincipal, fontWeight: FontWeight.bold)),
                        Icon(Icons.chevron_right, color: vertPrincipal, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal List of campaigns
            SizedBox(
              height: 310,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCampaignCard(
                    context,
                    tag: 'SANTÉ',
                    title: 'Soutien Dialyse Bamako',
                    subtitle: "Aide au financement d'équipements médicaux vitaux pour les patients de l'hôpital Point G.",
                    collected: '450 000 F',
                    objective: '1 200 000 F',
                    progress: 0.37,
                  ),
                  _buildCampaignCard(
                    context,
                    tag: 'ÉDUCATION',
                    title: 'Kits scolaires pour 100 enfants',
                    subtitle: "Financement des cahiers, sacs et stylos pour la rentrée scolaire en zone rurale.",
                    collected: '450 000 F',
                    objective: '1 000 000 F',
                    progress: 0.45,
                  ),
                  _buildCampaignCard(
                    context,
                    tag: 'ALIMENTATION',
                    title: 'Banque Alimentaire Mopti',
                    subtitle: "Distribution de vivres d'urgence pour les familles déplacées du centre du Mali.",
                    collected: '800 000 F',
                    objective: '1 500 000 F',
                    progress: 0.53,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: const DonateurBottomNavBar(currentIndex: 0),
    );
  }

  static Widget _buildMiniImpact(String valeur, String libelle, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(height: 4),
        Text(valeur, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        Text(libelle, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  static Widget _buildActionShortcut({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Colors.black45, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignCard(
    BuildContext context, {
    required String tag,
    required String title,
    required String subtitle,
    required String collected,
    required String objective,
    required double progress,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailsAideScreen(
              demande: {
                'titre': title,
                'motif': subtitle,
                'description': subtitle,
                'descriptionDetail': subtitle,
                'montantCollecte': int.tryParse(collected.replaceAll(RegExp(r'[^0-9]'), '')) ?? 450000,
                'montantNecessaire': int.tryParse(objective.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1200000,
                'statut': 'Collecte en cours',
              },
              showDonationButton: true,
            ),
          ),
        );
      },
      child: Container(
        width: 270,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1532629345422-7515f3d16bb6?q=80&w=400&auto=format&fit=crop',
                    height: 115,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7A821),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 11, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF137A4B)),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Collecté', style: TextStyle(color: Colors.black45, fontSize: 10)),
                          Text(collected, style: const TextStyle(color: Color(0xFF137A4B), fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Objectif', style: TextStyle(color: Colors.black45, fontSize: 10)),
                          Text(objective, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
                        ],
                      ),
                    ],
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
