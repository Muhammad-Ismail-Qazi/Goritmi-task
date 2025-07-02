import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../shared/widgets/appbar.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/textfield.dart';
import '../../todo/domain/todo_model.dart';
import '../../todo/provider/todo_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Provider.of<TodoProvider>(context, listen: false).loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmall = screenWidth < 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          NavigationBarWidget(onNewTask: _showNewTaskDialog),
          Expanded(
            child: isSmall
                ? _buildSmallLayout(todoProvider)
                : _buildLargeLayout(todoProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallLayout(TodoProvider todoProvider) {
    return ListView(
      padding: EdgeInsets.all(4.w),
      children: [
        _quickStats(todoProvider),
        SizedBox(height: 2.h),
        ...todoProvider.tasks.map((todo) => _taskCard(todo)),
      ],
    );
  }

  Widget _buildLargeLayout(TodoProvider todoProvider) {
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
              const Text('Filters',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 2.h),
              _filterTile("All Tasks", todoProvider.tasks.length, selected: true),
              _filterTile("Active", todoProvider.tasks.where((e) => e.status == 'Active').length),
              _filterTile("Completed", todoProvider.tasks.where((e) => e.status == 'Completed').length),
              SizedBox(height: 4.h),
              _quickStats(todoProvider),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(2.w),
            child: ListView(
              children: todoProvider.tasks.map((todo) => _taskCard(todo)).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _quickStats(TodoProvider todoProvider) {
    final completed = todoProvider.tasks.where((e) => e.status == 'Completed').length;
    final total = todoProvider.tasks.length;
    final progress = total == 0 ? 0 : ((completed / total) * 100).toInt();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Stats',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          SizedBox(height: 1.h),
          Text('Total Tasks: $total', style: const TextStyle(color: Colors.white)),
          Text('Completed: $completed', style: const TextStyle(color: Colors.white)),
          Text('Progress: $progress%', style: const TextStyle(color: Colors.white, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _filterTile(String title, int count, {bool selected = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: selected ? Colors.purple : Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: selected ? const Color(0xFFF5EBFF) : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        title: Text(title, overflow: TextOverflow.ellipsis),
        trailing: CircleAvatar(
          radius: 12,
          backgroundColor: Colors.grey.shade200,
          child: Text('$count', style: const TextStyle(fontSize: 12, color: Colors.black)),
        ),
      ),
    );
  }

  Widget _taskCard(TodoModel todo) {
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    todo.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: todo.status == 'Completed' ? Colors.green.shade100 : Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    todo.status,
                    style: TextStyle(color: todo.status == 'Completed' ? Colors.green : Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(todo.description),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _showEditTaskDialog(todo),
                  ),
                ),
                CircleAvatar(
                  child: IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () async {
                      await todoProvider.updateTask(
                        todo.copyWith(status: 'Completed', updatedAt: DateTime.now()),
                      );
                      _showSnack('Task marked as completed');
                    },
                  ),
                ),
                CircleAvatar(
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await todoProvider.deleteTask(todo.id!);
                      _showSnack('Task deleted');
                    },
                  ),
                ),
              ],
            )
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
                    validator: (val) => val == null || val.trim().isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFieldWidget(
                    controller: descController,
                    label: 'Description',
                    inputType: TextInputType.multiline,
                    validator: (val) => val == null || val.trim().isEmpty ? 'Description is required' : null,
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
                        );
                        await Provider.of<TodoProvider>(context, listen: false).addTask(task);
                        Navigator.of(context).pop();
                        _showSnack('Task added successfully');
                      }
                    },
                  )
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
                    validator: (val) => val == null || val.trim().isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFieldWidget(
                    controller: descController,
                    label: 'Description',
                    inputType: TextInputType.multiline,
                    validator: (val) => val == null || val.trim().isEmpty ? 'Description is required' : null,
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
                        await Provider.of<TodoProvider>(context, listen: false).updateTask(updatedTask);
                        Navigator.of(context).pop();
                        _showSnack('Task updated successfully');
                      }
                    },
                  )
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
