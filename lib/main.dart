import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:localstorage/localstorage.dart';
import 'providers/time_entry_provider.dart';
import 'screens/home_screen.dart';
import 'services/logger_service.dart';

void main() async {
  // Initialize logging service first
  LoggerService.initialize();
  LoggerService.info('*** Time Tracking App Starting ***');
  
  WidgetsFlutterBinding.ensureInitialized();
  
  LoggerService.info('*** Initializing Flutter bindings ***');
  await initLocalStorage();

  debugPrint('Time Entries: ${localStorage.getItem('timeEntries')}');
  debugPrint('Projects: ${localStorage.getItem('projects')}');
  debugPrint('Tasks: ${localStorage.getItem('tasks')}');
  
  LoggerService.info('*** LocalStorage initialized successfully ***');

  runApp(const TimeTrackingApp());
}

class TimeTrackingApp extends StatelessWidget {
  const TimeTrackingApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TimeEntryProvider(),
      child: MaterialApp(
        title: 'Time Tracking App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.teal,
          primaryColor: const Color(0xFF4DB6AC),
          
          // AppBar theme
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF4DB6AC),
            foregroundColor: Colors.white,
            elevation: 4,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          
          // Floating Action Button theme
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.white,
          ),
          
          cardTheme: const CardThemeData(
            elevation: 2,
            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          ),
          
          inputDecorationTheme: InputDecorationTheme(
            border: const OutlineInputBorder(),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF4DB6AC), width: 2),
            ),
            labelStyle: const TextStyle(color: Color(0xFF4DB6AC)),
            floatingLabelStyle: const TextStyle(color: Color(0xFF4DB6AC)),
          ),
          
          // Button theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4DB6AC),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          
          // Text button theme
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF4DB6AC),
            ),
          ),
          
          // Tab bar theme
          tabBarTheme: const TabBarThemeData(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontWeight: FontWeight.w500),
          ),
          
          // Drawer theme
          drawerTheme: const DrawerThemeData(
            backgroundColor: Colors.white,
          ),
          
          // List tile theme
          listTileTheme: const ListTileThemeData(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
          
          // Color scheme
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4DB6AC),
            primary: const Color(0xFF4DB6AC),
            secondary: Colors.amber,
          ),
          
          // Use Material 3 design
          useMaterial3: true,
        ),
        
        // Set the home screen
        home: const HomeScreen(),
        
        // Define routes for navigation (using Navigator.push)
        routes: {
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}