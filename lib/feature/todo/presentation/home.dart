// HomeScreen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../shared/widgets/appbar.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/textfield.dart';
import '../../auth/provider/auth_provider.dart';
import '../../todo/domain/todo_model.dart';
import '../../todo/provider/todo_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int userId;
  String selectedFilter = 'All';
  List<TodoModel> localTasks = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      userId = Provider.of<AuthProvider>(context, listen: false).user!.id!;
      final provider = Provider.of<TodoProvider>(context, listen: false);
      provider.loadTasks(userId).then((_) {
        setState(() {
          localTasks = _filteredTasks(provider);
        });
      });
    });
  }

  List<TodoModel> _filteredTasks(TodoProvider provider) {
    if (selectedFilter == 'Active') {
      return provider.tasks.where((e) => e.status == 'Active').toList();
    } else if (selectedFilter == 'Completed') {
      return provider.tasks.where((e) => e.status == 'Completed').toList();
    }
    return provider.tasks;
  }

  void _onFilterChanged(String filter, TodoProvider provider) {
    setState(() {
      selectedFilter = filter;
      localTasks = _filteredTasks(provider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TodoProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          NavigationBarWidget(onNewTask: _showNewTaskDialog),
          Expanded(
            child: isSmall ? _buildSmallLayout() : _buildLargeLayout(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallLayout() {
    return ListView(
      padding: EdgeInsets.all(4.w),
      children: [
        _quickStats(),
        SizedBox(height: 2.h),
        ReorderableListView.builder(
          buildDefaultDragHandles: false,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: localTasks.length,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) newIndex--;
              final item = localTasks.removeAt(oldIndex);
              localTasks.insert(newIndex, item);
            });
          },
          itemBuilder: (context, index) {
            return Container(
              key: ValueKey(localTasks[index].id),
              child: _taskCard(localTasks[index]),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLargeLayout(TodoProvider provider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22.w,
          padding: EdgeInsets.all(2.w),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 2.h),
              _filterTile("All", provider.tasks.length, provider),
              _filterTile(
                "Active",
                provider.tasks.where((e) => e.status == 'Active').length,
                provider,
              ),
              _filterTile(
                "Completed",
                provider.tasks.where((e) => e.status == 'Completed').length,
                provider,
              ),
              SizedBox(height: 4.h),
              _quickStats(),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(2.w),
            child: ReorderableListView.builder(
              itemCount: localTasks.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = localTasks.removeAt(oldIndex);
                  localTasks.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                return Container(
                  key: ValueKey(localTasks[index].id),
                  child: _taskCard(localTasks[index]),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _filterTile(String title, int count, TodoProvider provider) {
    final isSelected = selectedFilter == title;
    return InkWell(
      onTap: () => _onFilterChanged(title, provider),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.purple : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? const Color(0xFFF5EBFF) : null,
        ),
        child: ListTile(
          title: Text(title),
          trailing: CircleAvatar(
            radius: 12,
            backgroundColor: Colors.grey.shade200,
            child: Text(
              '$count',
              style: const TextStyle(fontSize: 12, color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  Widget _quickStats() {
    final completed = localTasks.where((e) => e.status == 'Completed').length;
    final total = localTasks.length;
    final progress = total == 0 ? 0 : ((completed / total) * 100).toInt();

    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Stats',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 1.h),
          Text(
            'Total Tasks: $total',
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            'Completed: $completed',
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            'Progress: $progress%',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _taskCard(TodoModel todo) {
    final provider = Provider.of<TodoProvider>(context, listen: false);
    return Card(
      color: Colors.white,
      elevation: 2,
      key: ValueKey(todo.id),
      child: ListTile(
        title: Text(todo.title),
        subtitle: Text(todo.description),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange),
              onPressed: () => _showEditTaskDialog(todo),
            ),
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: () async {
                await provider.updateTask(
                  todo.copyWith(status: 'Completed', updatedAt: DateTime.now()),
                );
                _showSnack('Task marked as completed');
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await provider.deleteTask(todo.id!, userId);
                setState(() => localTasks.removeWhere((e) => e.id == todo.id));
                _showSnack('Task deleted');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNewTaskDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedStatus = 'Active';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Task'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFieldWidget(
                    controller: titleController,
                    label: 'Title',
                    inputType: TextInputType.text,
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Title is required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFieldWidget(
                    controller: descController,
                    label: 'Description',
                    inputType: TextInputType.multiline,
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Description is required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Active', 'Completed'].map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        selectedStatus = value;
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  ButtonWidget(
                    label: 'Create Task',
                    textColor: Colors.white,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                    ),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final now = DateTime.now();
                        final task = TodoModel(
                          title: titleController.text.trim(),
                          description: descController.text.trim(),
                          status: selectedStatus,
                          createdAt: now,
                          updatedAt: now,
                          userId: userId,
                        );
                        await Provider.of<TodoProvider>(
                          context,
                          listen: false,
                        ).addTask(task);
                        Navigator.of(context).pop();
                        _showSnack('Task added successfully');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditTaskDialog(TodoModel todo) {
    final titleController = TextEditingController(text: todo.title);
    final descController = TextEditingController(text: todo.description);
    String selectedStatus = todo.status;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFieldWidget(
                    controller: titleController,
                    label: 'Title',
                    inputType: TextInputType.text,
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Title is required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFieldWidget(
                    controller: descController,
                    label: 'Description',
                    inputType: TextInputType.multiline,
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Description is required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Active', 'Completed'].map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        selectedStatus = value;
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  ButtonWidget(
                    label: 'Update Task',
                    textColor: Colors.white,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                    ),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final updatedTask = todo.copyWith(
                          title: titleController.text.trim(),
                          description: descController.text.trim(),
                          status: selectedStatus,
                          updatedAt: DateTime.now(),
                        );
                        await Provider.of<TodoProvider>(
                          context,
                          listen: false,
                        ).updateTask(updatedTask);
                        Navigator.of(context).pop();
                        _showSnack('Task updated successfully');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
