import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class DashboardScreen extends StatelessWidget {
  final AppState state;

  const DashboardScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Bom dia';
    } else if (hour < 18) {
      greeting = 'Boa tarde';
    } else {
      greeting = 'Boa noite';
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ─── Header ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primary.withOpacity(0.08),
                    AppTheme.accent.withOpacity(0.06),
                    AppTheme.background,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$greeting, Rafael 👋',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Pronto para produzir?',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primary, AppTheme.accent],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Text(
                            'R',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Today's date chip
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
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: AppTheme.primary,
                          size: 13,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatDate(now),
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
          ),

          // ─── Stats Grid ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: 'Tarefas hoje',
                          value: state.completedToday.toString(),
                          icon: Icons.check_circle_outline,
                          color: AppTheme.primary,
                          subtitle: 'de ${state.totalTasks} total',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          label: 'Em andamento',
                          value: state.inProgressTasks.length.toString(),
                          icon: Icons.refresh_outlined,
                          color: AppTheme.warning,
                          subtitle: 'tarefas ativas',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: 'Pomodoros',
                          value: state.todayPomodoros.toString(),
                          icon: Icons.timer_outlined,
                          color: AppTheme.accent,
                          subtitle: 'sessões hoje',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          label: 'Notas',
                          value: state.notes.length.toString(),
                          icon: Icons.sticky_note_2_outlined,
                          color: AppTheme.success,
                          subtitle: '${state.pinnedNotes.length} fixadas',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ─── Priority Tasks ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Tarefas Prioritárias',
              actionLabel: 'Ver todas',
              onAction: () {},
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final urgentAndHigh = state.tasks
                    .where((t) =>
                        (t.priority == TaskPriority.urgent ||
                            t.priority == TaskPriority.high) &&
                        t.status != TaskStatus.done)
                    .toList();

                if (index >= urgentAndHigh.length) return null;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: _DashboardTaskCard(task: urgentAndHigh[index], state: state),
                );
              },
              childCount: state.tasks
                  .where((t) =>
                      (t.priority == TaskPriority.urgent ||
                          t.priority == TaskPriority.high) &&
                      t.status != TaskStatus.done)
                  .length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ─── Daily Goals Progress ────────────────────────────────────────
          SliverToBoxAdapter(
            child: SectionHeader(title: 'Progresso do Dia'),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 130,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: state.goals.length,
                itemBuilder: (context, i) {
                  final goal = state.goals[i];
                  return _GoalProgressCard(goal: goal);
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      '', 'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    const days = [
      'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'
    ];
    return '${days[date.weekday - 1]}, ${date.day} de ${months[date.month]}';
  }
}

class _DashboardTaskCard extends StatelessWidget {
  final Task task;
  final AppState state;

  const _DashboardTaskCard({required this.task, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: task.isOverdue
              ? AppTheme.danger.withOpacity(0.4)
              : AppTheme.border,
        ),
      ),
      child: Row(
        children: [
          // Status checkbox
          GestureDetector(
            onTap: () => state.toggleTaskStatus(task.id),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: task.status == TaskStatus.inProgress
                      ? AppTheme.warning
                      : AppTheme.border,
                  width: 2,
                ),
                color: task.status == TaskStatus.done
                    ? AppTheme.success
                    : Colors.transparent,
              ),
              child: task.status == TaskStatus.done
                  ? const Icon(Icons.check, color: Colors.white, size: 13)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    color: task.status == TaskStatus.done
                        ? AppTheme.textMuted
                        : AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration: task.status == TaskStatus.done
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                if (task.dueDate != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 11,
                        color: task.isOverdue
                            ? AppTheme.danger
                            : AppTheme.textMuted,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        _formatDue(task.dueDate!),
                        style: TextStyle(
                          color: task.isOverdue
                              ? AppTheme.danger
                              : AppTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          PriorityBadge(
            label: task.priorityLabel,
            color: task.priorityColor,
          ),
        ],
      ),
    );
  }

  String _formatDue(DateTime date) {
    final diff = date.difference(DateTime.now());
    if (diff.isNegative) return 'Atrasada';
    if (diff.inHours < 1) return 'Em ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'Em ${diff.inHours}h';
    return 'Em ${diff.inDays}d';
  }
}

class _GoalProgressCard extends StatelessWidget {
  final DailyGoal goal;

  const _GoalProgressCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: goal.isCompleted
              ? goal.color.withOpacity(0.4)
              : AppTheme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(goal.icon, color: goal.color, size: 18),
              if (goal.isCompleted)
                const Icon(Icons.check_circle, color: AppTheme.success, size: 16),
            ],
          ),
          const Spacer(),
          Text(
            goal.title,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: goal.progress,
              backgroundColor: AppTheme.border,
              valueColor: AlwaysStoppedAnimation<Color>(goal.color),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${goal.current}/${goal.target} ${goal.unit}',
            style: TextStyle(
              color: goal.color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
