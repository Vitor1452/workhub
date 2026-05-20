import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

enum PomodoroMode { work, shortBreak, longBreak }

class PomodoroScreen extends StatefulWidget {
  final AppState state;
  const PomodoroScreen({super.key, required this.state});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen>
    with TickerProviderStateMixin {
  PomodoroMode _mode = PomodoroMode.work;
  bool _isRunning = false;
  int _secondsLeft = 25 * 60;
  Timer? _timer;
  int _completedSessions = 0;
  late AnimationController _pulseController;
  String? _selectedTaskId;

  final Map<PomodoroMode, int> _durations = {
    PomodoroMode.work: 25 * 60,
    PomodoroMode.shortBreak: 5 * 60,
    PomodoroMode.longBreak: 15 * 60,
  };

  final Map<PomodoroMode, String> _modeLabels = {
    PomodoroMode.work: 'Foco',
    PomodoroMode.shortBreak: 'Pausa Curta',
    PomodoroMode.longBreak: 'Pausa Longa',
  };

  final Map<PomodoroMode, Color> _modeColors = {
    PomodoroMode.work: AppTheme.primary,
    PomodoroMode.shortBreak: AppTheme.success,
    PomodoroMode.longBreak: AppTheme.accent,
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _setMode(PomodoroMode mode) {
    _timer?.cancel();
    setState(() {
      _mode = mode;
      _isRunning = false;
      _secondsLeft = _durations[mode]!;
    });
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() {
          if (_secondsLeft > 0) {
            _secondsLeft--;
          } else {
            _onSessionComplete();
          }
        });
      });
      setState(() => _isRunning = true);
    }
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _secondsLeft = _durations[_mode]!;
    });
  }

  void _onSessionComplete() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _completedSessions++;
    });

    if (_mode == PomodoroMode.work) {
      final task = _selectedTaskId != null
          ? widget.state.tasks.firstWhere((t) => t.id == _selectedTaskId, orElse: () => widget.state.tasks.first)
          : null;

      if (task != null) {
        widget.state.addPomodoroSession(PomodoroSession(
          taskId: task.id,
          taskTitle: task.title,
        ));
      }

      // Auto switch to break
      if (_completedSessions % 4 == 0) {
        _setMode(PomodoroMode.longBreak);
      } else {
        _setMode(PomodoroMode.shortBreak);
      }
    } else {
      _setMode(PomodoroMode.work);
    }
  }

  double get _progress {
    final total = _durations[_mode]!;
    return 1 - (_secondsLeft / total);
  }

  String get _timeString {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final color = _modeColors[_mode]!;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Timer de Foco',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_fire_department,
                            color: AppTheme.warning, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.state.todayPomodoros} hoje',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ─── Mode Selector ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: PomodoroMode.values.map((m) {
                    final isSelected = _mode == m;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _setMode(m),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? _modeColors[m]! : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _modeLabels[m]!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected
                                  ? AppTheme.background
                                  : AppTheme.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // ─── Timer Ring ────────────────────────────────────────────
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 260,
                          height: 260,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: _isRunning
                                ? [
                                    BoxShadow(
                                      color: color.withOpacity(
                                          0.1 + 0.15 * _pulseController.value),
                                      blurRadius:
                                          40 + 20 * _pulseController.value,
                                      spreadRadius: 0,
                                    ),
                                  ]
                                : [],
                          ),
                          child: child,
                        );
                      },
                      child: CustomPaint(
                        painter: _TimerPainter(
                          progress: _progress,
                          color: color,
                          backgroundColor: AppTheme.surface,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _timeString,
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 52,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _modeLabels[_mode]!.toUpperCase(),
                                style: TextStyle(
                                  color: color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(4, (i) {
                                  return Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.symmetric(horizontal: 3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: i < (_completedSessions % 4)
                                          ? color
                                          : AppTheme.border,
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ─── Controls ────────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Reset
                        GestureDetector(
                          onTap: _reset,
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: const Icon(
                              Icons.refresh,
                              color: AppTheme.textMuted,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),

                        // Play/Pause
                        GestureDetector(
                          onTap: _toggleTimer,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [color, color.withOpacity(0.7)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              _isRunning
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: AppTheme.background,
                              size: 32,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),

                        // Skip
                        GestureDetector(
                          onTap: _onSessionComplete,
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: const Icon(
                              Icons.skip_next,
                              color: AppTheme.textMuted,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ─── Task Selector ─────────────────────────────────────────
            if (widget.state.inProgressTasks.isNotEmpty ||
                widget.state.todoTasks.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FOCANDO EM',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedTaskId,
                        isExpanded: true,
                        underline: const SizedBox.shrink(),
                        dropdownColor: AppTheme.surfaceElevated,
                        hint: const Text(
                          'Selecionar tarefa...',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 14,
                          ),
                        ),
                        items: [
                          ...widget.state.inProgressTasks,
                          ...widget.state.todoTasks,
                        ].map((task) {
                          return DropdownMenuItem(
                            value: task.id,
                            child: Text(
                              task.title,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _selectedTaskId = v),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TimerPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _TimerPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Track
    final trackPaint = Paint()
      ..color = AppTheme.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_TimerPainter old) =>
      old.progress != progress || old.color != color;
}
