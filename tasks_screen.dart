import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class TasksScreen extends StatefulWidget {
  final AppState state;
  const TasksScreen({super.key, required this.state});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    'Tarefas',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showAddTaskSheet(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: AppTheme.background,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Search ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Buscar tarefas...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppTheme.textMuted,
                    size: 20,
                  ),
                ),
              ),
            ),

            // ─── Tabs ──────────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: AppTheme.background,
                unselectedLabelColor: AppTheme.textMuted,
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                indicator: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                padding: const EdgeInsets.all(4),
                tabs: [
                  Tab(text: 'A fazer (${widget.state.todoTasks.length})'),
                  Tab(text: 'Em prog. (${widget.state.inProgressTasks.length})'),
                  Tab(text: 'Feitas (${widget.state.doneTasks.length})'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ─── Task Lists ────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _TaskList(
                    tasks: _filter(widget.state.todoTasks),
                    state: widget.state,
                    emptyMessage: 'Nenhuma tarefa pendente',
                  ),
                  _TaskList(
                    tasks: _filter(widget.state.inProgressTasks),
                    state: widget.state,
                    emptyMessage: 'Nenhuma tarefa em andamento',
                  ),
                  _TaskList(
                    tasks: _filter(widget.state.doneTasks),
                    state: widget.state,
                    emptyMessage: 'Nenhuma tarefa concluída',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Task> _filter(List<Task> tasks) {
    if (_searchQuery.isEmpty) return tasks;
    return tasks
        .where((t) =>
            t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            t.description.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _showAddTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AddTaskSheet(state: widget.state),
    );
  }
}

class _TaskList extends StatelessWidget {
  final List<Task> tasks;
  final AppState state;
  final String emptyMessage;

  const _TaskList({
    required this.tasks,
    required this.state,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return EmptyState(
        icon: Icons.task_alt_outlined,
        title: emptyMessage,
        subtitle: 'Toque em + para adicionar uma nova tarefa',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: tasks.length,
      itemBuilder: (context, i) => _TaskCard(task: tasks[i], state: state),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final AppState state;

  const _TaskCard({required this.task, required this.state});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.danger.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete_outline, color: AppTheme.danger),
      ),
      onDismissed: (_) => state.deleteTask(task.id),
      child: GestureDetector(
        onTap: () => _showDetails(context),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: task.isOverdue
                  ? AppTheme.danger.withOpacity(0.3)
                  : AppTheme.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _StatusButton(task: task, state: state),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        color: task.status == TaskStatus.done
                            ? AppTheme.textMuted
                            : AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        decoration: task.status == TaskStatus.done
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                  PriorityBadge(
                    label: task.priorityLabel,
                    color: task.priorityColor,
                  ),
                ],
              ),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Text(
                    task.description,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  const SizedBox(width: 32),
                  _chip(Icons.folder_outlined, task.category, AppTheme.textMuted),
                  if (task.assignee != null) ...[
                    const SizedBox(width: 8),
                    _chip(Icons.person_outline, task.assignee!, AppTheme.textMuted),
                  ],
                  if (task.dueDate != null) ...[
                    const SizedBox(width: 8),
                    _chip(
                      Icons.access_time,
                      _formatDue(task.dueDate!),
                      task.isOverdue ? AppTheme.danger : AppTheme.textMuted,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(color: color, fontSize: 11)),
      ],
    );
  }

  String _formatDue(DateTime date) {
    final diff = date.difference(DateTime.now());
    if (diff.isNegative) return 'Atrasada';
    if (diff.inHours < 1) return '${diff.inMinutes}min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _TaskDetailSheet(task: task, state: state),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final Task task;
  final AppState state;

  const _StatusButton({required this.task, required this.state});

  @override
  Widget build(BuildContext context) {
    Color color;
    Widget? child;

    switch (task.status) {
      case TaskStatus.todo:
        color = AppTheme.border;
        child = null;
        break;
      case TaskStatus.inProgress:
        color = AppTheme.warning;
        child = Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppTheme.warning,
            borderRadius: BorderRadius.circular(4),
          ),
        );
        break;
      case TaskStatus.done:
        color = AppTheme.success;
        child = const Icon(Icons.check, color: Colors.white, size: 13);
        break;
    }

    return GestureDetector(
      onTap: () => state.toggleTaskStatus(task.id),
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
          color: task.status == TaskStatus.done ? AppTheme.success : Colors.transparent,
        ),
        child: child != null ? Center(child: child) : null,
      ),
    );
  }
}

class _TaskDetailSheet extends StatelessWidget {
  final Task task;
  final AppState state;

  const _TaskDetailSheet({required this.task, required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(task.title, style: Theme.of(context).textTheme.titleLarge),
              ),
              PriorityBadge(label: task.priorityLabel, color: task.priorityColor),
            ],
          ),
          if (task.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(task.description, style: Theme.of(context).textTheme.bodyLarge),
          ],
          const SizedBox(height: 16),
          _detailRow(Icons.folder_outlined, 'Categoria', task.category),
          if (task.assignee != null)
            _detailRow(Icons.person_outline, 'Responsável', task.assignee!),
          if (task.dueDate != null)
            _detailRow(
              Icons.access_time,
              'Prazo',
              _fmt(task.dueDate!),
              color: task.isOverdue ? AppTheme.danger : null,
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    state.deleteTask(task.id);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Excluir'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.danger,
                    side: const BorderSide(color: AppTheme.danger),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    state.toggleTaskStatus(task.id);
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    task.status == TaskStatus.done
                        ? Icons.refresh
                        : Icons.check,
                    size: 16,
                  ),
                  label: Text(
                    task.status == TaskStatus.done ? 'Reabrir' : 'Concluir',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textMuted, size: 16),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              color: color ?? AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} às ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}

class _AddTaskSheet extends StatefulWidget {
  final AppState state;
  const _AddTaskSheet({required this.state});

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;
  String _category = 'Geral';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nova Tarefa',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleCtrl,
            autofocus: true,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(hintText: 'Título da tarefa'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descCtrl,
            style: const TextStyle(color: AppTheme.textPrimary),
            maxLines: 2,
            decoration: const InputDecoration(hintText: 'Descrição (opcional)'),
          ),
          const SizedBox(height: 16),
          const Text(
            'PRIORIDADE',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 11,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: TaskPriority.values.map((p) {
              final colors = {
                TaskPriority.low: AppTheme.success,
                TaskPriority.medium: AppTheme.warning,
                TaskPriority.high: AppTheme.danger,
                TaskPriority.urgent: const Color(0xFFDC2626),
              };
              final labels = {
                TaskPriority.low: 'Baixa',
                TaskPriority.medium: 'Média',
                TaskPriority.high: 'Alta',
                TaskPriority.urgent: 'Urgente',
              };
              final isSelected = _priority == p;
              final color = colors[p]!;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _priority = p),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withOpacity(0.15)
                          : AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? color.withOpacity(0.5)
                            : AppTheme.border,
                      ),
                    ),
                    child: Text(
                      labels[p]!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? color : AppTheme.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              child: const Text('Criar Tarefa'),
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    if (_titleCtrl.text.trim().isEmpty) return;
    widget.state.addTask(Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      priority: _priority,
      category: _category,
    ));
    Navigator.pop(context);
  }
}
