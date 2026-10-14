import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pocket_ai_app/features/notes/presentation/notes_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno
  await dotenv.load(fileName: ".env");

  // limpiar la url de barras o rutas extras por seguridad
  //String rawUrl = dotenv.env['SUPABASE_URL']?.trim() ?? '';
  //if (rawUrl.endsWith('/rest/v1')) {
  //  rawUrl = rawUrl.replaceAll('/rest/v1', '');
  //}
  //if (rawUrl.endsWith('/')) {
  //  rawUrl = rawUrl.substring(0, rawUrl.length - 1);
  //}
  //final publishableKey = dotenv.env['SUPABASE_ANON_KEY']?.trim() ?? '';

  // inicializar cliente de Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    publishableKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const ProviderScope(child: PocketAIApp()));
}

class PocketAIApp extends StatelessWidget {
  const PocketAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PocketAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const NotesScreen(),
    );
  }
}
