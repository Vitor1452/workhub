import 'package:flutter/material.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  // ─── Tasks ───────────────────────────────────────────────────────────────
  final List<Task> _tasks = [
    Task(
      id: '1',
      title: 'Revisar proposta do cliente',
      description: 'Analisar os requisitos e dar feedback',
      priority: TaskPriority.high,
      status: TaskStatus.inProgress,
      assignee: 'Ana Lima',
      category: 'Clientes',
      dueDate: DateTime.now().add(const Duration(hours: 3)),
    ),
    Task(
      id: '2',
      title: 'Reunião de alinhamento semanal',
      description: 'Sincronizar progresso com a equipe',
      priority: TaskPriority.medium,
      status: TaskStatus.todo,
      assignee: 'Você',
      category: 'Reuniões',
      dueDate: DateTime.now().add(const Duration(days: 1)),
    ),
    Task(
      id: '3',
      title: 'Atualizar documentação técnica',
      description: 'Revisar e atualizar os docs do módulo de pagamento',
      priority: TaskPriority.low,
      status: TaskStatus.todo,
      assignee: 'Carlos Melo',
      category: 'Documentação',
    ),
    Task(
      id: '4',
      title: 'Deploy versão 2.4.1',
      description: 'Publicar hotfix de produção',
      priority: TaskPriority.urgent,
      status: TaskStatus.done,
      assignee: 'Dev Team',
      category: 'Desenvolvimento',
    ),
  ];

  List<Task> get tasks => List.unmodifiable(_tasks);

  List<Task> get todoTasks =>
      _tasks.where((t) => t.status == TaskStatus.todo).toList();
  List<Task> get inProgressTasks =>
      _tasks.where((t) => t.status == TaskStatus.inProgress).toList();
  List<Task> get doneTasks =>
      _tasks.where((t) => t.status == TaskStatus.done).toList();

  int get completedToday =>
      _tasks.where((t) => t.status == TaskStatus.done).length;
  int get totalTasks => _tasks.length;

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void updateTask(Task task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void toggleTaskStatus(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index];
      if (task.status == TaskStatus.done) {
        task.status = TaskStatus.todo;
      } else if (task.status == TaskStatus.todo) {
        task.status = TaskStatus.inProgress;
      } else {
        task.status = TaskStatus.done;
      }
      notifyListeners();
    }
  }

  // ─── Notes ───────────────────────────────────────────────────────────────
  final List<Note> _notes = [
    Note(
      id: '1',
      title: 'Ideias para o produto',
      content:
          'Feature de notificações inteligentes\nIntegração com Slack\nDashboard executivo com métricas em tempo real',
      color: NoteColor.blue,
      tags: ['produto', 'ideias'],
      isPinned: true,
    ),
    Note(
      id: '2',
      title: 'Feedback do cliente XYZ',
      content:
          'Gostaram da nova interface. Pedem mais filtros nos relatórios. Próxima reunião em 2 semanas.',
      color: NoteColor.green,
      tags: ['cliente', 'feedback'],
    ),
    Note(
      id: '3',
      title: 'Dívidas técnicas',
      content: 'Refatorar módulo de autenticação\nMigrar para nova versão da API\nOtimizar queries lentas',
      color: NoteColor.orange,
      tags: ['tech', 'backlog'],
    ),
  ];

  List<Note> get notes => List.unmodifiable(_notes);
  List<Note> get pinnedNotes => _notes.where((n) => n.isPinned).toList();

  void addNote(Note note) {
    _notes.insert(0, note);
    notifyListeners();
  }

  void updateNote(Note note) {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      notifyListeners();
    }
  }

  void deleteNote(String id) {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void togglePin(String id) {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notes[index].isPinned = !_notes[index].isPinned;
      notifyListeners();
    }
  }

  // ─── Daily Goals ─────────────────────────────────────────────────────────
  final List<DailyGoal> _goals = [
    DailyGoal(
      id: '1',
      title: 'Tarefas concluídas',
      target: 8,
      current: 4,
      unit: 'tarefas',
      icon: Icons.check_circle_outline,
      color: const Color(0xFF00E5FF),
    ),
    DailyGoal(
      id: '2',
      title: 'Foco (Pomodoros)',
      target: 6,
      current: 3,
      unit: 'sessões',
      icon: Icons.timer_outlined,
      color: const Color(0xFF8B5CF6),
    ),
    DailyGoal(
      id: '3',
      title: 'Reuniões',
      target: 3,
      current: 2,
      unit: 'reuniões',
      icon: Icons.people_outline,
      color: const Color(0xFF10B981),
    ),
    DailyGoal(
      id: '4',
      title: 'E-mails respondidos',
      target: 20,
      current: 12,
      unit: 'e-mails',
      icon: Icons.mail_outline,
      color: const Color(0xFFF59E0B),
    ),
  ];

  List<DailyGoal> get goals => List.unmodifiable(_goals);

  void incrementGoal(String id) {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index != -1 && _goals[index].current < _goals[index].target) {
      _goals[index].current++;
      notifyListeners();
    }
  }

  void decrementGoal(String id) {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index != -1 && _goals[index].current > 0) {
      _goals[index].current--;
      notifyListeners();
    }
  }

  // ─── Pomodoro ─────────────────────────────────────────────────────────────
  List<PomodoroSession> pomodoroHistory = [];
  int todayPomodoros = 3;

  void addPomodoroSession(PomodoroSession session) {
    pomodoroHistory.add(session);
    todayPomodoros++;
    notifyListeners();
  }
}
