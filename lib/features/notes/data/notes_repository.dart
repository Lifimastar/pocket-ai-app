import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/note_model.dart';

class NotesRepository {
  final SupabaseClient _client = Supabase.instance.client;
  final String _backendUrl = 'http://localhost:8000/api/v1/analyze-note';

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
  Future<void> processNoteWithAI(String noteId, String content) async {
    final response = await http.post(
      Uri.parse(_backendUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'note_id': noteId, 'content': content}),
    );

    if (response.statusCode != 200) {
      throw Exception('Fallo al analizar la nota: ${response.body}');
    }
  }
}
