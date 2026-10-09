import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/note_model.dart';

class NotesRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // obtener todas las notas ordenadas por fecha
  Future<List<NoteModel>> getNotes() async {
    final response = await _client
        .from('notes')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => NoteModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // insertar una nueva nota
  Future<void> createNote(String title, String content) async {
    await _client.from('notes').insert({'title': title, 'content': content});
  }
}
