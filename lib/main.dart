import 'package:flutter/material.dart';
import 'LoginPage.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login/Register',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}
// this code sets up the basic structure of a Flutter application, including defining the main function,
// creating the MyApp widget as the root of the application, and specifying the initial screen to be the login page.
