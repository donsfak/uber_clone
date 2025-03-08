import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:place_picker/place_picker.dart';

class SearchDestination extends StatefulWidget {
  const SearchDestination({super.key});

  @override
  State<SearchDestination> createState() => _SearchDestinationState();
}

class _SearchDestinationState extends State<SearchDestination> {
  final TextEditingController _pickUpController = TextEditingController();
  final TextEditingController _dropOffController = TextEditingController();
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  /// 📌 Fonction pour obtenir la position actuelle de l'utilisateur
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez activer la localisation')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission de localisation refusée')),
        );
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _pickUpController.text =
          "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}";
    });

    print("Position actuelle: $_currentPosition");
  }

  /// 📌 Fonction pour rechercher une destination
  Future<void> _searchLocation() async {
    print("Recherche de destination lancée");

    if (_currentPosition == null) return;

    LocationResult? result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => PlacePickerScreen(
              apiKey: "AIzaSyB1g4Q-Sx6QlxOLbX139fRovrut69_slEU",
              initialLocation: _currentPosition!,
            ),
      ),
    );

    if (result != null) {
      setState(() {
        _dropOffController.text =
            result.formattedAddress ?? "Adresse non trouvée";
      });
      print("Adresse sélectionnée: ${_dropOffController.text}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildLocationField(
                      icon: Icons.location_pin,
                      label: 'Position actuelle',
                      controller: _pickUpController,
                      enabled: false,
                    ),
                    const SizedBox(height: 12),
                    _buildLocationField(
                      icon: Icons.flag,
                      label: 'Destination',
                      controller: _dropOffController,
                      onTap: _searchLocation,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      print(
                        "Bouton cliqué - Pickup: $_currentPosition, Destination: ${_dropOffController.text}",
                      );
                      if (_dropOffController.text.isNotEmpty) {
                        Navigator.pop(context, {
                          'pickup': _currentPosition,
                          'destination': _dropOffController.text,
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Veuillez choisir une destination"),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      'CONFIRMER LA DESTINATION',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly: !enabled,
      style: const TextStyle(color: Colors.white),
      onTap: onTap,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.8)),
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
      ),
    );
  }
}
