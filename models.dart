import 'package:flutter/material.dart';

// ─── Task Model ────────────────────────────────────────────────────────────
enum TaskPriority { low, medium, high, urgent }
enum TaskStatus { todo, inProgress, done }

class Task {
  final String id;
  String title;
  String description;
  TaskPriority priority;
  TaskStatus status;
  DateTime? dueDate;
  String? assignee;
  String category;
  DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.todo,
    this.dueDate,
    this.assignee,
    this.category = 'Geral',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isOverdue =>
      dueDate != null &&
      dueDate!.isBefore(DateTime.now()) &&
      status != TaskStatus.done;

  Color get priorityColor {
    switch (priority) {
      case TaskPriority.low:
        return const Color(0xFF10B981);
      case TaskPriority.medium:
        return const Color(0xFFF59E0B);
      case TaskPriority.high:
        return const Color(0xFFEF4444);
      case TaskPriority.urgent:
        return const Color(0xFFDC2626);
    }
  }

  String get priorityLabel {
    switch (priority) {
      case TaskPriority.low:
        return 'Baixa';
      case TaskPriority.medium:
        return 'Média';
      case TaskPriority.high:
        return 'Alta';
      case TaskPriority.urgent:
        return 'Urgente';
    }
  }
}

// ─── Note Model ────────────────────────────────────────────────────────────
enum NoteColor { blue, purple, green, orange, red }

class Note {
  final String id;
  String title;
  String content;
  NoteColor color;
  List<String> tags;
  DateTime createdAt;
  DateTime updatedAt;
  bool isPinned;

  Note({
    required this.id,
    required this.title,
    this.content = '',
    this.color = NoteColor.blue,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isPinned = false,
  })  : tags = tags ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Color get backgroundColor {
    switch (color) {
      case NoteColor.blue:
        return const Color(0xFF0D2137);
      case NoteColor.purple:
        return const Color(0xFF1A0D37);
      case NoteColor.green:
        return const Color(0xFF0D2118);
      case NoteColor.orange:
        return const Color(0xFF261A0D);
      case NoteColor.red:
        return const Color(0xFF260D0D);
    }
  }

  Color get accentColor {
    switch (color) {
      case NoteColor.blue:
        return const Color(0xFF00E5FF);
      case NoteColor.purple:
        return const Color(0xFF8B5CF6);
      case NoteColor.green:
        return const Color(0xFF10B981);
      case NoteColor.orange:
        return const Color(0xFFF59E0B);
      case NoteColor.red:
        return const Color(0xFFEF4444);
    }
  }
}

// ─── Goal Model ────────────────────────────────────────────────────────────
class DailyGoal {
  final String id;
  String title;
  int target;
  int current;
  String unit;
  IconData icon;
  Color color;

  DailyGoal({
    required this.id,
    required this.title,
    required this.target,
    this.current = 0,
    this.unit = '',
    required this.icon,
    required this.color,
  });

  double get progress => target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
  bool get isCompleted => current >= target;
}

// ─── Pomodoro Session ──────────────────────────────────────────────────────
class PomodoroSession {
  final String taskId;
  final String taskTitle;
  final DateTime startedAt;
  DateTime? completedAt;

  PomodoroSession({
    required this.taskId,
    required this.taskTitle,
    DateTime? startedAt,
  }) : startedAt = startedAt ?? DateTime.now();

  Duration get elapsed =>
      (completedAt ?? DateTime.now()).difference(startedAt);
}
