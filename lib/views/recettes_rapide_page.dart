import 'package:flutter/material.dart';

class RecettesRapidesPage extends StatelessWidget {
  const RecettesRapidesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("modules rapides"),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          "Ici s’afficheront les differents modules",
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
