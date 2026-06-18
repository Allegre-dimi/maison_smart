import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../services/auth_service.dart';

class FirestoreTestPage extends StatefulWidget {
  const FirestoreTestPage({super.key});

  @override
  State<FirestoreTestPage> createState() => _FirestoreTestPageState();
}

class _FirestoreTestPageState extends State<FirestoreTestPage> {
  String result = 'En attente de lecture...';

  @override
  void initState() {
    super.initState();
    _testApi();
  }

  Future<void> _testApi() async {
    try {
      final me = await AuthService().me();
      setState(() {
        result = 'Lecture réussie : ${me.toJson()}';
      });
    } on ApiException catch (e) {
      setState(() {
        result = 'Erreur API (${e.statusCode}) : ${e.message}';
      });
    } catch (e) {
      setState(() {
        result = 'Erreur : $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test API Django')),
      body: Center(child: Text(result, textAlign: TextAlign.center)),
    );
  }
}
