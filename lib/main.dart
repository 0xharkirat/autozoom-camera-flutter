import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AutoZoom Camera Flutter',
      theme: ThemeData(visualDensity: VisualDensity.adaptivePlatformDensity),
      darkTheme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}
