import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';
import 'providers/observation_provider.dart';
import 'services/observation_storage_service.dart';

void main() async {
  print('=== APP STARTUP: main() entry point ===');
  
  try {
    print('main(): Calling WidgetsFlutterBinding.ensureInitialized()');
    WidgetsFlutterBinding.ensureInitialized();
    print('main(): WidgetsFlutterBinding.ensureInitialized() completed successfully');
  } catch (e, stackTrace) {
    print('main(): ERROR in WidgetsFlutterBinding.ensureInitialized(): $e');
    print('main(): Stack trace: $stackTrace');
    rethrow;
  }
  
  try {
    print('main(): Starting Firebase initialization...');
    await Firebase.initializeApp();
    print('main(): Firebase initialization completed successfully');
  } catch (e, stackTrace) {
    print('main(): ERROR in Firebase initialization: $e');
    print('main(): Stack trace: $stackTrace');
    // Continue with app startup even if Firebase fails
  }
  
  try {
    print('main(): Starting ObservationStorage initialization...');
    await ObservationStorage().initialize();
    print('main(): ObservationStorage initialization completed successfully');
  } catch (e, stackTrace) {
    print('main(): ERROR in ObservationStorage initialization: $e');
    print('main(): Stack trace: $stackTrace');
    // Continue with app startup even if storage fails
  }
  
  try {
    print('main(): Calling runApp()...');
    runApp(const ConservationApp());
    print('main(): runApp() called successfully');
  } catch (e, stackTrace) {
    print('main(): ERROR in runApp(): $e');
    print('main(): Stack trace: $stackTrace');
    rethrow;
  }
}

class ConservationApp extends StatelessWidget {
  const ConservationApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('ConservationApp.build: Building app widget tree');
    
    try {
      print('ConservationApp.build: Creating MultiProvider with ObservationProvider');
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) {
            print('ConservationApp.build: Creating new ObservationProvider instance');
            return ObservationProvider();
          }),
        ],
        child: MaterialApp(
          title: 'Conservation Data App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.green,
            primaryColor: const Color(0xFF2E7D32),
            scaffoldBackgroundColor: const Color(0xFFF8F9FA),
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.green,
              accentColor: const Color(0xFF8D6E63),
              backgroundColor: const Color(0xFFF8F9FA),
            ),
            cardColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFF8D6E63),
              foregroundColor: Colors.white,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            textTheme: const TextTheme(
              headlineMedium: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
              titleLarge: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF424242),
              ),
              bodyLarge: TextStyle(
                fontSize: 16,
                color: Color(0xFF424242),
              ),
              bodyMedium: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
          ),
          home: const HomeScreen(),
        ),
      );
    } catch (e, stackTrace) {
      print('ConservationApp.build: ERROR building app: $e');
      print('ConservationApp.build: Stack trace: $stackTrace');
      // Return a simple error widget to prevent complete app failure
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error building app: $e'),
          ),
        ),
      );
    }
  }
} 