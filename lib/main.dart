
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Firebase Auth Demo', home: const AuthExample());
  }
}

class AuthExample extends StatefulWidget {
  const AuthExample({super.key});

  @override
  AuthExampleState createState() => AuthExampleState();
}

class AuthExampleState extends State<AuthExample> {
  String status = "Not signed in";
  bool isAuthenticated = false;

  void signInAnonymously() async {


    try {
      await FirebaseAuth.instance.signInAnonymously();
      setState(() {
        status = "Signed in anonymously";
        isAuthenticated = true;
      });

    } catch (e) {
      setState(() {
        status = "Error: $e";
        isAuthenticated = false;
      });
    }
  }

  void getMessageFromAPI() async {

    if(!isAuthenticated){
      _showAuthenticationAlert();
      return;
    }

    try {
      final url = Uri.parse("http://10.0.2.2:3000/saludo");
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String mensaje = data['mensaje'];
        setState(() {
          status = mensaje;
        });
      }
    } catch (e) {
      setState(() {
        status = "Error: $e";
      });
    }
  }

  void _showAuthenticationAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Autenticación requerida'),
          content: const Text('Debes iniciar sesión para acceder a esta función.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Iniciar sesión'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Firebase Auth and Http Req")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(status, style: TextStyle(fontSize: 20),),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: signInAnonymously,
              child: const Text("Login anónimo"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: getMessageFromAPI,
              child: const Text('Saludo desde API'),

            ),
          ],
        ),
      ),
    );
  }
}
