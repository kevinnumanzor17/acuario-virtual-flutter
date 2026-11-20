import 'package:flutter/material.dart';
import 'acuario/pantalla.dart';

void main() => runApp(const AcuarioApp());

class AcuarioApp extends StatelessWidget {
  const AcuarioApp({super.key});
  @override
  Widget build(BuildContext context) {
    final esquema = ColorScheme.fromSeed(
      seedColor: const Color(0xff74d7bf), brightness: Brightness.dark,
    ).copyWith(primary: const Color(0xff9be4d1), surface: const Color(0xff101e25));
    return MaterialApp(
      title: 'Acuario virtual', debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorScheme: esquema,
        scaffoldBackgroundColor: const Color(0xff0a151c)),
      home: const PantallaAcuario(),
    );
  }
}
