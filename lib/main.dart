import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hafalyuk_dsn/pages/login_page.dart';
import 'package:hafalyuk_dsn/pages/pa_page.dart';
import 'package:hafalyuk_dsn/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Setoran Hafalan',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFC2E9D7),
          scrolledUnderElevation: 0,
        ),
        scaffoldBackgroundColor: Color(0xFFC2E9D7),
        primarySwatch: Colors.blue,
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: Colors.blue,
          cursorColor: Colors.grey,
          selectionHandleColor: Colors.blue,
        ),
      ),
      home: const InitializerWidget(),
    );
  }
}

class InitializerWidget extends StatelessWidget {
  const InitializerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: AuthService().getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.blueAccent,
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return const LoginPage();
        } else {
          final token = snapshot.data;
          return token != null ? const PaPage() : const LoginPage();
        }
      },
    );
  }
}