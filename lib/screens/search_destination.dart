import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SearchDestination extends StatefulWidget {
  const SearchDestination({super.key});

  @override
  State<SearchDestination> createState() => _SearchDestinationState();
}

class _SearchDestinationState extends State<SearchDestination> {
  final TextEditingController _pickUpController = TextEditingController();
  final TextEditingController _dropOffController = TextEditingController();

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
              // En-tête
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Set Your Destination',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Champs de saisie
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildLocationField(
                      icon: Icons.location_pin,
                      label: 'Pickup Location',
                      controller: _pickUpController,
                    ),
                    const SizedBox(height: 12),
                    _buildLocationField(
                      icon: Icons.flag,
                      label: 'Destination',
                      controller: _dropOffController,
                    ),
                  ],
                ),
              ),

              const Spacer(), // Pousse le bouton vers le bas
              // Bouton de confirmation
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      'CONFIRM DESTINATION',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ).animate().scale(end: const Offset(0.95, 0.95)),
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
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
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
