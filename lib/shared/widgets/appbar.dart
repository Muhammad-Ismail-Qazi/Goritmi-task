import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:todo_desktop_app/feature/auth/provider/auth_provider.dart';
import 'package:todo_desktop_app/shared/widgets/button.dart';

import '../../core/routes/app_routes.dart';

class NavigationBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onNewTask;

  const NavigationBarWidget({super.key, required this.onNewTask});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 700;
        final buttonWidth = isCompact ? 25.w : 10.w;

        return AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
          automaticallyImplyLeading: false,
          titleSpacing: 20,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'TF',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded( // 👈 This ensures the column fits within available space
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Task Flow',
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Welcome back, Muhammad Ismail',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          actions: [
            ButtonWidget(
              width: buttonWidth,
              textColor: Colors.white,
              gradient: const LinearGradient(
                colors: [Color(0xFFA070EC), Color(0xFF8E2DE2), Color(0xFF3E1978)],
              ),
              onPressed: onNewTask,
              label: isCompact ? '+' : 'New Task',
            ),
            const SizedBox(width: 8),
            ButtonWidget(
              width: buttonWidth,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              onPressed: () async {
                final confirmed = await showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Logout')),
                    ],
                  ),
                );

                if (confirmed == true) {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  authProvider.logout();
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                }
              },

              label: isCompact ? '🔓' : 'Logout',
            ),
            const SizedBox(width: 16),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
