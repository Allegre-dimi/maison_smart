import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool securityAlerts = true;
  bool energyAlerts = true;
  bool deviceUpdates = false;

  final List<Map<String, String>> notifications = [
    {
      'title': 'Porte d’entrée ouverte',
      'subtitle': 'Aujourd\'hui à 18:30',
    },
    {
      'title': 'Fuite de gaz détectée',
      'subtitle': 'Hier à 22:10',
    },
    {
      'title': 'Consommation élevée salon',
      'subtitle': 'Hier à 17:45',
    },
    {
      'title': 'Mise à jour prise connectée',
      'subtitle': '2 jours avant',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Paramètres",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                )),

            const SizedBox(height: 12),

            // SWITCHES
            _buildStyledSwitch(
              title: 'Alertes sécurité',
              value: securityAlerts,
              onChanged: (val) => setState(() => securityAlerts = val),
              icon: Icons.security,
            ),
            _buildStyledSwitch(
              title: 'Alertes consommation',
              value: energyAlerts,
              onChanged: (val) => setState(() => energyAlerts = val),
              icon: Icons.bolt,
            ),
            _buildStyledSwitch(
              title: 'Mises à jour appareils',
              value: deviceUpdates,
              onChanged: (val) => setState(() => deviceUpdates = val),
              icon: Icons.system_update_alt,
            ),

            const SizedBox(height: 20),
            Divider(),

            const SizedBox(height: 10),
            Text(
              'Notifications récentes',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  return _buildNotificationCard(notif['title']!, notif['subtitle']!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget Styled Switch
  Widget _buildStyledSwitch({
    required String title,
    required bool value,
    required IconData icon,
    required Function(bool) onChanged,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: Icon(icon, color: Colors.deepPurple),
          title: Text(title, style: GoogleFonts.poppins(fontSize: 14)),
          value: value,
          activeColor: Colors.deepPurple,
          onChanged: onChanged,
        ),
      ),
    );
  }

  /// Widget Styled Notification Card
  Widget _buildNotificationCard(String title, String subtitle) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.notifications_active, size: 24, color: Colors.deepPurple),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 12)),
      ),
    );
  }
}
