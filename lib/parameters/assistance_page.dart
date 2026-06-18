import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AssistancePage extends StatelessWidget {
  const AssistancePage({Key? key}) : super(key: key);

  Future<void> _launchWhatsApp() async {
    final url = Uri.parse(
        "https://wa.me/242064885504?text=Bonjour, j’ai besoin d’aide pour la configuration.");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Impossible d’ouvrir WhatsApp");
    }
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@domotique.com',
      query:
      'subject=Assistance App Domotique&body=Bonjour, je rencontre un problème...',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      debugPrint("Impossible d’ouvrir l’e-mail");
    }
  }

  Future<void> _openGuideVideo() async {
    final url = Uri.parse('https://www.youtube.com/watch?v=abc123xyz');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Impossible d’ouvrir la vidéo");
    }
  }

  Widget _buildAssistanceCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: (color ?? Colors.deepPurple).withOpacity(0.15),
          child: Icon(icon, color: color ?? Colors.deepPurple),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      elevation: 1,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const Icon(Icons.help_outline, color: Colors.deepPurple),
        title: Text(question,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        subtitle: Text(answer,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[700],
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Assistance",
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: false,
        elevation: 4,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            "Besoin d’aide pour configurer vos appareils ?",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // 📌 Boutons Assistance
          _buildAssistanceCard(
            icon: Icons.video_library,
            title: "Regarder le guide vidéo",
            onTap: _openGuideVideo,
          ),
          _buildAssistanceCard(
            icon: Icons.chat,
            title: "Contacter via WhatsApp",
            onTap: _launchWhatsApp,
            color: Colors.green,
          ),
          _buildAssistanceCard(
            icon: Icons.email,
            title: "Envoyer un email au support",
            onTap: _launchEmail,
            color: Colors.orange,
          ),

          const SizedBox(height: 24),

          // 📖 FAQ
          Text(
            "FAQ - Questions fréquentes",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          _buildFAQItem(
            "Comment connecter une prise intelligente ?",
            "Allez dans la page Configuration, entrez le nom Wi-Fi et suivez les étapes affichées.",
          ),
          _buildFAQItem(
            "Comment réinitialiser un appareil ?",
            "Maintenez le bouton RESET pendant 5 secondes jusqu’à ce que la LED clignote.",
          ),
        ],
      ),
    );
  }
}
