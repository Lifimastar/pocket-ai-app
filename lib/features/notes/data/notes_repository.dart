import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/note_model.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class NotesRepository {
  final SupabaseClient _client = Supabase.instance.client;
  String get _backendUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api/v1/analyze-note';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api/v1/analyze-note';
    } else {
      return 'http://localhost:8000/api/v1/analyze-note';
    }
  }

  // obtener notas
  Future<List<NoteModel>> getNotes() async {
    final response = await _client
        .from('notes')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => NoteModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Crear nota
  Future<void> createNote(String title, String content) async {
    await _client.from('notes').insert({'title': title, 'content': content});
  }

  // Disparar el analisis con IA hacia nuestro microservicio FastAPI
  Future<Map<String, dynamic>> processNoteWithAI(
    String noteId,
    String content,
  ) async {
    final response = await http.post(
      Uri.parse(_backendUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'note_id': noteId, 'content': content}),
    );

    if (response.statusCode != 200) {
      throw Exception('Fallo al analizar la nota: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
