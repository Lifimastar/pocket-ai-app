import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/notes_repository.dart';
import '../domain/note_model.dart';

// provider del repositorio
final notesRepositoryProvider = Provider((ref) => NotesRepository());

// provider que maneja la lista de notas de forma reactiva
final notesListProvider = FutureProvider.autoDispose<List<NoteModel>>((
  ref,
) async {
  final repository = ref.watch(notesRepositoryProvider);
  return repository.getNotes();
});

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  void _showAddNoteDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva Nota'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Titulo'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: 'Contenido'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                await ref
                    .read(notesRepositoryProvider)
                    .createNote(titleController.text, contentController.text);
                ref.invalidate(notesListProvider);
                if (context.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // Modal interactivo que muestra el analisis y las tareas extraidas
  void _showActionItemsModal(
    BuildContext context,
    String summary,
    List<dynamic> actionItems,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xff1e1e2c),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.purpleAccent),
                SizedBox(width: 8),
                Text(
                  'Analisis de IA & Tareas Extraidas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Resumen Ejecutivo:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(summary),
            const Divider(height: 24),
            const Text(
              'Puntos de Accion Detectados:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.purpleAccent,
              ),
            ),
            const SizedBox(height: 8),
            if (actionItems.isEmpty)
              const Text('No se detectaron tareas pendientes especificas.')
            else
              ...actionItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 18,
                        color: Colors.greenAccent,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item.toString())),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cerrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PocketAI Notes'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(notesListProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: notesAsync.when(
        data: (notes) {
          if (notes.isEmpty) {
            return const Center(
              child: Text('No hay notas aun. Crea la primera.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notes.length,
            itemBuilder: (ctx, index) {
              final note = notes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(note.content),
                      const Divider(height: 24),
                      if (note.summary != null) ...[
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.deepPurpleAccent),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    size: 16,
                                    color: Colors.purpleAccent,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Resumen Inteligente (IA)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purpleAccent,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                note.summary!,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Align(
                          alignment: AlignmentGeometry.centerRight,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.auto_awesome, size: 16),
                            label: const Text('Analizar con IA'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Procesando nota con IA...'),
                                ),
                              );
                              final result = await ref
                                  .read(notesRepositoryProvider)
                                  .processNoteWithAI(note.id, note.content);
                              ref.invalidate(notesListProvider);

                              if (context.mounted) {
                                final summary = result['summary'] ?? '';
                                final actionItems =
                                    result['action_items'] as List<dynamic>? ??
                                    [];
                                _showActionItemsModal(
                                  context,
                                  summary,
                                  actionItems,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoteDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
