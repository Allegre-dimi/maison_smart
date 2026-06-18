import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class WifiConfigurationPage extends StatefulWidget {
  @override
  _WifiConfigurationPage createState() => _WifiConfigurationPage();
}

class _WifiConfigurationPage extends State<WifiConfigurationPage> {
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _deviceNameController = TextEditingController();
  String _selectedDeviceType = "Prise";
  bool _isLoading = false;
  String _responseMessage = '';

  final List<String> _deviceTypes = [
    'Prise',
    'Interrupteur',
    'Capteur de température',
    'Alarme',
    'Lampe',
    'Ventilateur',
    'Autre'
  ];

  Future<void> sendConfiguration() async {
    setState(() {
      _isLoading = true;
      _responseMessage = '';
    });

    final uri = Uri.parse("http://192.168.4.1/config");
    final body = jsonEncode({
      "ssid": _ssidController.text,
      "password": _passwordController.text,
      "device_name": _deviceNameController.text,
      "device_type": _selectedDeviceType,
    });

    try {
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        setState(() {
          _responseMessage = "✅ Configuration envoyée avec succès !";
        });
      } else {
        setState(() {
          _responseMessage = "❌ Erreur lors de l'envoi : ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = "❌ Erreur de connexion à l’ESP32 : $e";
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget buildStyledForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Connectez-vous au Wi-Fi avant de continuer.",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple,
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: _selectedDeviceType,
              items: _deviceTypes.map((String type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) => setState(() => _selectedDeviceType = value!),
              decoration: _inputDecoration("Type d'appareil", Icons.devices),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: _deviceNameController,
              decoration: _inputDecoration("Nom de l'appareil", Icons.label),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: _ssidController,
              decoration: _inputDecoration("SSID du Wi-Fi", Icons.wifi),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: _passwordController,
              decoration: _inputDecoration("Mot de passe Wi-Fi", Icons.lock),
              obscureText: true,
            ),

            const SizedBox(height: 25),

            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.send, color: Colors.white),
                label: Text(
                  "Envoyer la configuration",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: sendConfiguration,
              ),
            ),

            if (_responseMessage.isNotEmpty) ...[
              const SizedBox(height: 20),
              Center(
                child: Text(
                  _responseMessage,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _responseMessage.startsWith("✅")
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.deepPurple),
      labelStyle: GoogleFonts.poppins(),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Configurer un appareil IoT',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: buildStyledForm(),
      ),
    );
  }
}
