import 'package:flutter/material.dart';
import 'package:deme_mali_app/core/services/organisation_service.dart';
import 'package:deme_mali_app/core/services/auth_service.dart';
import 'package:deme_mali_app/screens/organisation/organisation_demandes_screen.dart';
import 'package:deme_mali_app/screens/organisation/organisation_visites_screen.dart';
import 'package:deme_mali_app/screens/organisation/organisation_beneficiaires_screen.dart';
import 'package:deme_mali_app/screens/organisation/organisation_profile_screen.dart';
import 'package:deme_mali_app/screens/organisation/demande_verification_detail_screen.dart';
import 'package:deme_mali_app/screens/organisation/enregistrer_beneficiaire_terrain_screen.dart';

/// ============================================================================
/// Écran : Tableau de bord Organisation Partenaire / Association
/// Inspiré des maquettes Figma : download 10.png, Frame-1.png, Frame-2.png
///
/// Comprend :
/// 1. Navigation fluide à 5 onglets fonctionnels (Accueil, Demandes, Visites, Bénéficiaires, Profil)
/// 2. Métriques synchronisées en direct avec le backend Spring Boot
/// 3. Section "À traiter maintenant" interactive avec badges d'urgence
/// 4. Actions rapides opérationnelles (Visites, Demandes, Bénéficiaires)
/// ============================================================================
class OrganisationDashboardScreen extends StatefulWidget {
  final int initialTabIndex;

  const OrganisationDashboardScreen({super.key, this.initialTabIndex = 0});

  @override
  State<OrganisationDashboardScreen> createState() =>
      _OrganisationDashboardScreenState();
}

class _OrganisationDashboardScreenState
    extends State<OrganisationDashboardScreen> {
  final OrganisationService _organisationService = OrganisationService();

  late int _currentIndex;
  Map<String, dynamic> _dashboardStats = {};
  List<Map<String, dynamic>> _urgentDemandes = [];
  List<Map<String, dynamic>> _recentEtudes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      _organisationService.fetchDashboard(),
      _organisationService.fetchDemandesOrganisation(),
      _organisationService.fetchEtudesTerrain(),
    ]);

    if (mounted) {
      setState(() {
        _dashboardStats = results[0] as Map<String, dynamic>;
        _urgentDemandes = results[1] as List<Map<String, dynamic>>;
        _recentEtudes = results[2] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color vertPrincipal = Color(0xFF137A4B);
    const Color fondBeige = Color(0xFFF7F4EB);
    const Color texteGris = Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: fondBeige,
      body: _buildCurrentTabBody(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            if (index == 0) _loadDashboardData();
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: vertPrincipal,
          unselectedItemColor: texteGris,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: "Accueil",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description_outlined),
              activeIcon: Icon(Icons.description),
              label: "Demandes",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on_outlined),
              activeIcon: Icon(Icons.location_on),
              label: "Visites",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: "Bénéficiaires",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: "Profil",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTabBody() {
    switch (_currentIndex) {
      case 1:
        return const OrganisationDemandesScreen();
      case 2:
        return const OrganisationVisitesScreen();
      case 3:
        return const OrganisationBeneficiairesScreen();
      case 4:
        return const OrganisationProfileScreen();
      case 0:
      default:
        return _buildDashboardHome();
    }
  }

  Widget _buildDashboardHome() {
    const Color vertPrincipal = Color(0xFF137A4B);
    const Color texteFonce = Color(0xFF1F1F1F);
    const Color texteGris = Color(0xFF6B7280);
    const Color orangeCouleur = Color(0xFFEA580C);
    const Color bleuCouleur = Color(0xFF2563EB);
    const Color jauneCouleur = Color(0xFFD97706);

    final nomOrg = UserSession.currentUserNomStructure ?? 'Organisation Partenaire';
    final nbDemandes = _urgentDemandes.isNotEmpty
        ? _urgentDemandes.length
        : (_dashboardStats['totalDemandesAide'] ?? 2);
    final nbEnAttente = _dashboardStats['demandesEnAttente'] ?? _urgentDemandes.where((d) => (d['statut'] ?? '').toString().toUpperCase() == 'EN_ATTENTE').length;
    final nbBenef = _dashboardStats['totalBeneficiaires'] ?? 4;
    final nbEtudes = _recentEtudes.length;

    if (_isLoading && _dashboardStats.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: vertPrincipal));
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: vertPrincipal,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. En-tête : Logo Dèmè Mali et Cloche de notifications
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.volunteer_activism,
                            color: vertPrincipal,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Dèmè Mali",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: texteFonce,
                        ),
                      ),
                    ],
                  ),

                  // Cloche de notification avec badge dynamique
                  Stack(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_none,
                          color: texteFonce,
                          size: 24,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFDC2626),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$nbEnAttente',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 2. Salutation et sous-titre
              Text(
                "Bonjour, $nomOrg",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: texteFonce,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Effectuez vos visites de terrain, rédigez vos rapports et validez les aides.",
                style: TextStyle(
                  fontSize: 13,
                  color: texteGris,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 22),

              // 3. Grille des 4 indicateurs clés en direct
              Row(
                children: [
                  // Carte 1 : Demandes à vérifier (Orange)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _currentIndex = 1),
                      child: _buildMetricCard(
                        icon: Icons.description_outlined,
                        iconColor: orangeCouleur,
                        title: "Demandes",
                        value: "$nbEnAttente".padLeft(2, '0'),
                        subtitle: "à vérifier",
                        borderColor: orangeCouleur.withOpacity(0.5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Carte 2 : Bénéficiaires suivis (Vert)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _currentIndex = 3),
                      child: _buildMetricCard(
                        icon: Icons.person_outline,
                        iconColor: vertPrincipal,
                        title: "Bénéficiaires",
                        value: "$nbBenef".padLeft(2, '0'),
                        subtitle: "suivis",
                        borderColor: vertPrincipal.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  // Carte 3 : Visites de terrain (Bleu)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _currentIndex = 2),
                      child: _buildMetricCard(
                        icon: Icons.location_on_outlined,
                        iconColor: bleuCouleur,
                        title: "Visites terrain",
                        value: "$nbEtudes".padLeft(2, '0'),
                        subtitle: "effectuées",
                        borderColor: bleuCouleur.withOpacity(0.5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Carte 4 : Total demandes assignées
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _currentIndex = 1),
                      child: _buildMetricCard(
                        icon: Icons.assignment_turned_in_outlined,
                        iconColor: jauneCouleur,
                        title: "Total dossiers",
                        value: "$nbDemandes".padLeft(2, '0'),
                        subtitle: "assignés",
                        borderColor: jauneCouleur.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // 4. Section : "À traiter maintenant"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "À traiter maintenant",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: texteFonce,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _currentIndex = 1),
                    child: const Text(
                      "Voir tout",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: vertPrincipal,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Item 1 : Demande d'aide à vérifier
                    _buildTaskItem(
                      icon: Icons.description_outlined,
                      iconBgColor: const Color(0xFFFFEDE6),
                      iconColor: orangeCouleur,
                      title: "Demandes d'aide à vérifier",
                      subtitle: "$nbEnAttente demande(s) en attente de terrain",
                      count: "$nbEnAttente",
                      badgeBgColor: const Color(0xFFFFEDE6),
                      badgeTextColor: orangeCouleur,
                      isLast: false,
                      onTap: () => setState(() => _currentIndex = 1),
                    ),
                    // Item 2 : Visite de terrain à effectuer
                    _buildTaskItem(
                      icon: Icons.location_on_outlined,
                      iconBgColor: const Color(0xFFEFF6FF),
                      iconColor: bleuCouleur,
                      title: "Visites de terrain",
                      subtitle: "Constat sur place & rapports",
                      count: "${_urgentDemandes.length}",
                      badgeBgColor: const Color(0xFFEFF6FF),
                      badgeTextColor: bleuCouleur,
                      isLast: false,
                      onTap: () => setState(() => _currentIndex = 2),
                    ),
                    // Item 3 : Bénéficiaire à enrôler
                    _buildTaskItem(
                      icon: Icons.person_outline,
                      iconBgColor: const Color(0xFFE2F0E9),
                      iconColor: vertPrincipal,
                      title: "Enrôlement bénéficiaires",
                      subtitle: "$nbBenef personnes enregistrées",
                      count: "$nbBenef",
                      badgeBgColor: const Color(0xFFE2F0E9),
                      badgeTextColor: vertPrincipal,
                      isLast: true,
                      onTap: () => setState(() => _currentIndex = 3),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 5. Actions principales
              const Text(
                "Actions principales",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: texteFonce,
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  // Action 1 : Enregistrer bénéficiaire sur le terrain
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.person_add_outlined,
                      title: "Bénéficiaire",
                      subtitle: "Enrôler",
                      color: vertPrincipal,
                      onTap: () async {
                        final res = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EnregistrerBeneficiaireTerrainScreen(),
                          ),
                        );
                        if (res == true) _loadDashboardData();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Action 2 : Traiter les demandes
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.assignment_outlined,
                      title: "Demandes",
                      subtitle: "Vérifier",
                      color: orangeCouleur,
                      onTap: () => setState(() => _currentIndex = 1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Action 3 : Visite & Rapports
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.location_city_outlined,
                      title: "Visites",
                      subtitle: "Terrain",
                      color: bleuCouleur,
                      onTap: () => setState(() => _currentIndex = 2),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // 6. Dernières activités réelles
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Derniers dossiers assignés",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: texteFonce,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _currentIndex = 1),
                    child: const Text(
                      "Voir tout",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: vertPrincipal,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (_urgentDemandes.isNotEmpty) ...[
                ...List.generate(
                  _urgentDemandes.length > 2 ? 2 : _urgentDemandes.length,
                  (index) {
                    final d = _urgentDemandes[index];
                    final t = d['titre']?.toString() ?? 'Demande d\'aide';
                    final bNom = '${d['beneficiairePrenom'] ?? ''} ${d['beneficiaireNom'] ?? ''}'.trim();
                    final statut = (d['statut'] ?? 'EN_ATTENTE').toString();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: statut == 'VALIDEE' ? const Color(0xFFE2F0E9) : const Color(0xFFFFEDE6),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                statut == 'VALIDEE' ? Icons.check : Icons.hourglass_top,
                                color: statut == 'VALIDEE' ? vertPrincipal : orangeCouleur,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: texteFonce,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  bNom.isNotEmpty ? bNom : 'Bénéficiaire assigné',
                                  style: const TextStyle(fontSize: 12, color: texteGris),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios, size: 16, color: texteGris),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DemandeVerificationDetailScreen(demande: d),
                                ),
                              ).then((_) => _loadDashboardData());
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('Aucune demande en attente.', style: TextStyle(color: texteGris, fontSize: 13)),
                  ),
                ),
              ],

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    String? suffix,
    required String subtitle,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F1F1F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
              if (suffix != null) ...[
                const SizedBox(width: 4),
                Text(
                  suffix,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ],
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTaskItem({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String count,
    required Color badgeBgColor,
    required Color badgeTextColor,
    required bool isLast,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: isLast
          ? const BorderRadius.vertical(bottom: Radius.circular(20))
          : BorderRadius.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F1F1F),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: badgeTextColor,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right, size: 20, color: Color(0xFF9CA3AF)),
              ],
            ),
          ),
          if (!isLast)
            const Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: Color(0xFFF3F4F6),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5), width: 1.2),
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F1F1F),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
