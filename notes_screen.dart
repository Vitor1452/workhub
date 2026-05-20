import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class NotesScreen extends StatefulWidget {
  final AppState state;
  const NotesScreen({super.key, required this.state});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final notes = widget.state.notes
        .where((n) =>
            n.title.toLowerCase().contains(_search.toLowerCase()) ||
            n.content.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    final pinned = notes.where((n) => n.isPinned).toList();
    final regular = notes.where((n) => !n.isPinned).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notas',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showNoteEditor(context, null),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add,
                          color: AppTheme.background, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Buscar notas...',
                  prefixIcon:
                      Icon(Icons.search, color: AppTheme.textMuted, size: 20),
                ),
              ),
            ),
            Expanded(
              child: notes.isEmpty
                  ? const EmptyState(
                      icon: Icons.sticky_note_2_outlined,
                      title: 'Nenhuma nota ainda',
                      subtitle: 'Toque em + para criar sua primeira nota',
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        if (pinned.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(
                              'FIXADAS',
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 11,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          ...pinned.map((n) => _NoteCard(
                                note: n,
                                state: widget.state,
                                onTap: () => _showNoteEditor(context, n),
                              )),
                          const SizedBox(height: 16),
                        ],
                        if (regular.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(
                              'OUTRAS',
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 11,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          ...regular.map((n) => _NoteCard(
                                note: n,
                                state: widget.state,
                                onTap: () => _showNoteEditor(context, n),
                              )),
                        ],
                        const SizedBox(height: 20),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNoteEditor(BuildContext context, Note? note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => _NoteEditorScreen(
          note: note,
          state: widget.state,
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  final AppState state;
  final VoidCallback onTap;

  const _NoteCard({required this.note, required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: note.backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: note.accentColor.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    note.title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => state.togglePin(note.id),
                  child: Icon(
                    note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: note.isPinned ? note.accentColor : AppTheme.textMuted,
                    size: 16,
                  ),
                ),
              ],
            ),
            if (note.content.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                note.content,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (note.tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                children: note.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: note.accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '#$tag',
                      style: TextStyle(
                        color: note.accentColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NoteEditorScreen extends StatefulWidget {
  final Note? note;
  final AppState state;

  const _NoteEditorScreen({this.note, required this.state});

  @override
  State<_NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<_NoteEditorScreen> {
  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;
  late NoteColor _color;
  final TextEditingController _tagCtrl = TextEditingController();
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.note?.title ?? '');
    _contentCtrl = TextEditingController(text: widget.note?.content ?? '');
    _color = widget.note?.color ?? NoteColor.blue;
    _tags = List.from(widget.note?.tags ?? []);
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _colorAccent(_color);
    return Scaffold(
      backgroundColor: _colorBackground(_color),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.note != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppTheme.danger),
              onPressed: () {
                widget.state.deleteNote(widget.note!.id);
                Navigator.pop(context);
              },
            ),
          IconButton(
            icon: Icon(Icons.check, color: accentColor),
            onPressed: _save,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              decoration: const InputDecoration(
                hintText: 'Título',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const Divider(color: AppTheme.border),
            Expanded(
              child: TextField(
                controller: _contentCtrl,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 15,
                  height: 1.6,
                ),
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Escreva sua nota aqui...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),

            // ─── Tags ────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    children: _tags
                        .map((tag) => GestureDetector(
                              onTap: () => setState(() => _tags.remove(tag)),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '#$tag',
                                      style: TextStyle(
                                          color: accentColor, fontSize: 12),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.close,
                                        color: accentColor, size: 12),
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _tagCtrl,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: '+ tag',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (v) {
                      if (v.trim().isNotEmpty) {
                        setState(() {
                          _tags.add(v.trim());
                          _tagCtrl.clear();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),

            // ─── Color Picker ─────────────────────────────────────────
            const SizedBox(height: 12),
            Row(
              children: NoteColor.values.map((c) {
                final isSelected = _color == c;
                return GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: Container(
                    width: 28,
                    height: 28,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: _colorAccent(c),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _colorAccent(NoteColor c) {
    switch (c) {
      case NoteColor.blue: return AppTheme.primary;
      case NoteColor.purple: return AppTheme.accent;
      case NoteColor.green: return AppTheme.success;
      case NoteColor.orange: return AppTheme.warning;
      case NoteColor.red: return AppTheme.danger;
    }
  }

  Color _colorBackground(NoteColor c) {
    switch (c) {
      case NoteColor.blue: return const Color(0xFF080F1A);
      case NoteColor.purple: return const Color(0xFF0E0A1A);
      case NoteColor.green: return const Color(0xFF081410);
      case NoteColor.orange: return const Color(0xFF160E08);
      case NoteColor.red: return const Color(0xFF160808);
    }
  }

  void _save() {
    if (_titleCtrl.text.trim().isEmpty) return;
    final note = Note(
      id: widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      color: _color,
      tags: _tags,
      isPinned: widget.note?.isPinned ?? false,
      createdAt: widget.note?.createdAt,
    );

    if (widget.note == null) {
      widget.state.addNote(note);
    } else {
      widget.state.updateNote(note);
    }
    Navigator.pop(context);
  }
}
