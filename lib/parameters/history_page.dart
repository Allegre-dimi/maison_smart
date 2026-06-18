import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String selectedFilter = 'Tous';

  final List<Map<String, String>> allHistoryData = [
    {
      'title': 'Prise Salon allumée',
      'subtitle': '10 Juillet 2025 à 08:35',
      'type': 'Prises',
    },
    {
      'title': 'Configuration Wi-Fi modifiée',
      'subtitle': '09 Juillet 2025 à 21:12',
      'type': 'Wi-Fi',
    },
    {
      'title': 'Paiement abonnement mensuel',
      'subtitle': '07 Juillet 2025 à 15:50',
      'type': 'Paiements',
    },
    {
      'title': 'Appareil "Lampe Chambre" ajouté',
      'subtitle': '05 Juillet 2025 à 19:02',
      'type': 'Appareils',
    },
    {
      'title': 'Prise Cuisine éteinte',
      'subtitle': '02 Juillet 2025 à 22:45',
      'type': 'Prises',
    },
  ];

  List<String> filterOptions = ['Tous', 'Prises', 'Wi-Fi', 'Paiements', 'Appareils'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredData = selectedFilter == 'Tous'
        ? allHistoryData
        : allHistoryData.where((item) => item['type'] == selectedFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Historique',
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedFilter,
                icon: const Icon(Icons.filter_list, color: Colors.white),
                dropdownColor: Colors.white,
                style: GoogleFonts.poppins(color: Colors.black),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedFilter = newValue!;
                  });
                },
                items: filterOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          )
        ],
      ),
      body: filteredData.isEmpty
          ? Center(
        child: Text(
          'Aucun historique pour ce filtre',
          style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemCount: filteredData.length,
        itemBuilder: (context, index) {
          final item = filteredData[index];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.blue.withOpacity(0.15),
                child: const Icon(Icons.history, color: Colors.deepPurple),
              ),
              title: Text(
                item['title']!,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                item['subtitle']!,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.grey[700],
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}
