// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../services/auth_controller.dart';
// import '../models/utilisateur.dart';
// import '../home_page.dart';
//
// class EmailConnexionPage extends StatefulWidget {
//   @override
//   State<EmailConnexionPage> createState() => _EmailConnexionPageState();
// }
//
// class _EmailConnexionPageState extends State<EmailConnexionPage> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final AuthController authController = AuthController();
//
//   bool _obscureText = true;
//   bool _loading = false;
//
//   void _connexion() async {
//     setState(() => _loading = true);
//
//     Utilisateur? user = await authController.connexionEmail(
//       emailController.text.trim(),
//       passwordController.text.trim(),
//     );
//
//     setState(() => _loading = false);
//
//     if (user != null) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => HomePage()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Email ou mot de passe incorrect")),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white.withOpacity(0),
//         leading: IconButton(
//           onPressed: () => Navigator.pop(context),
//           icon: Icon(Icons.close, color: Colors.black, size: 30),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.symmetric(vertical: 40, horizontal: 30),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Text(
//               "Connectez votre adresse e-mail",
//               style: GoogleFonts.poppins(
//                 color: Colors.blue[600],
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             SizedBox(height: 22),
//             Text(
//               'Votre adresse e-mail nous aide à mieux protéger votre compte.',
//               textAlign: TextAlign.center,
//               style: GoogleFonts.poppins(
//                 color: Colors.grey[600],
//                 fontSize: 15,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             SizedBox(height: 100),
//
//             // Email
//             TextField(
//               controller: emailController,
//               decoration: InputDecoration(
//                 labelText: 'Votre adresse email',
//                 labelStyle: TextStyle(color: Colors.grey[400]),
//               ),
//             ),
//             SizedBox(height: 30),
//
//             // Mot de passe
//             TextField(
//               controller: passwordController,
//               obscureText: _obscureText,
//               decoration: InputDecoration(
//                 labelText: 'Votre mot de passe',
//                 labelStyle: TextStyle(color: Colors.grey[400]),
//                 suffixIcon: IconButton(
//                   icon: Icon(
//                     _obscureText ? Icons.visibility : Icons.visibility_off,
//                     color: Colors.black,
//                   ),
//                   onPressed: () => setState(() {
//                     _obscureText = !_obscureText;
//                   }),
//                 ),
//               ),
//             ),
//             SizedBox(height: 60),
//
//             // Bouton de connexion
//             _loading
//                 ? CircularProgressIndicator()
//                 : ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 shape: StadiumBorder(),
//                 backgroundColor: Colors.blue,
//                 padding: EdgeInsets.symmetric(
//                   horizontal: 118,
//                   vertical: 10,
//                 ),
//               ),
//               onPressed: _connexion,
//               child: Text(
//                 "Confirmation",
//                 style: GoogleFonts.poppins(
//                   color: Colors.white,
//                   fontSize: 9,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
