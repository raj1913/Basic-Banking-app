import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/solitaire_provider.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const SolitaireApp());
}

class SolitaireApp extends StatelessWidget {
  const SolitaireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SolitaireProvider(),
      child: MaterialApp(
        title: 'Flutter Solitaire',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const GameScreen(),
      ),
    );
  }
}