import 'package:flutter/material.dart';
import 'package:deme_mali_app/screens/auth/fill_profile_screen.dart';

// Cet écran permet de sélectionner le pays de l'utilisateur (ex: iPhone 16 - 8 et 9).
// On utilise un StatefulWidget pour gérer la barre de recherche et le pays sélectionné.
class CountrySelectionScreen extends StatefulWidget {
  const CountrySelectionScreen({super.key});

  @override
  State<CountrySelectionScreen> createState() => _CountrySelectionScreenState();
}

class _CountrySelectionScreenState extends State<CountrySelectionScreen> {
  // Liste des pays disponibles (chaque pays a un code, un nom, et une image de drapeau)
  // Pour le design, on va utiliser de simples textes pour simuler les drapeaux.
  final List<Map<String, String>> _countries = [
    {'code': 'ML', 'name': 'Mali', 'flag': '🇲🇱'},
    {'code': 'SN', 'name': 'Sénégal', 'flag': '🇸🇳'},
    {'code': 'CI', 'name': "Côte d'Ivoire", 'flag': '🇨🇮'},
    {'code': 'GN', 'name': 'Guinée', 'flag': '🇬🇳'},
    {'code': 'BF', 'name': 'Burkina Faso', 'flag': '🇧🇫'},
    {'code': 'NE', 'name': 'Niger', 'flag': '🇳🇪'},
  ];

  // Le pays actuellement sélectionné
  String? _selectedCountryCode;
  
  // Le texte tapé dans la barre de recherche
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // On filtre la liste des pays en fonction de ce qui est tapé dans la recherche
    final filteredCountries = _countries.where((country) {
      return country['name']!.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F4EB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Bouton retour
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF137A4B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Sélectionnez votre pays',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // 1. La barre de recherche
              TextField(
                onChanged: (value) {
                  // Quand on tape, on met à jour la recherche
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Rechercher',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  suffixIcon: const Icon(Icons.search, color: Colors.black54),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none, // Pas de bordure
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
              const SizedBox(height: 24),

              // 2. La liste des pays (qui prend le reste de l'espace)
              Expanded(
                child: ListView.separated(
                  itemCount: filteredCountries.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final country = filteredCountries[index];
                    final isSelected = _selectedCountryCode == country['code'];

                    return GestureDetector(
                      onTap: () {
                        // On sélectionne le pays au clic
                        setState(() {
                          _selectedCountryCode = country['code'];
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          // Si sélectionné, bordure verte
                          border: Border.all(
                            color: isSelected ? const Color(0xFF137A4B) : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Le drapeau simulé en Emoji
                            Text(country['flag']!, style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 12),
                            // Le code du pays (ex: ML)
                            Text(
                              country['code']!,
                              style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 12),
                            // Le nom du pays (Mali)
                            Expanded(
                              child: Text(
                                country['name']!,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                            // Le bouton radio (cercle de sélection)
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF137A4B) : Colors.grey.shade300,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF137A4B),
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

              // 3. Le bouton Continuer
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  // Le bouton n'est cliquable que si un pays est sélectionné
                  onPressed: _selectedCountryCode != null
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const FillProfileScreen()),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedCountryCode != null ? const Color(0xFF137A4B) : const Color(0xFF99C2A2),
                    disabledBackgroundColor: const Color(0xFF99C2A2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'Continuer',
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
