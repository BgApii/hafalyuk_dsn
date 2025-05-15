import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hafalyuk_dsn/pages/login_page.dart';
import 'package:hafalyuk_dsn/pages/pa_page.dart';
import 'package:hafalyuk_dsn/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final authService = AuthService();
  final token = await authService.getToken();
  Widget initialPage =
      (token != null) ? const PaPage() : const LoginPage();

  runApp(MyApp(initialPage: initialPage));
}

class MyApp extends StatelessWidget {
  final Widget initialPage;

  const MyApp({super.key, required this.initialPage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Setoran Hafalan',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFC2E9D7),
          scrolledUnderElevation: 0,
        ),
        scaffoldBackgroundColor: Color(0xFFC2E9D7),
        primarySwatch: Colors.blue,
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: Colors.blue.shade100,
          cursorColor: Colors.grey.shade300,
          selectionHandleColor: Colors.blue.shade300,
        ),
      ),
      home: initialPage,
    );
  }
}
