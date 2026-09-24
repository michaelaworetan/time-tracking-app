import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'lib/providers/time_entry_provider.dart';
import 'lib/screens/home_screen.dart';

void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TimeEntryProvider(),
      child: MaterialApp(
        home: const HomeScreen(),
      ),
    );
  }
}