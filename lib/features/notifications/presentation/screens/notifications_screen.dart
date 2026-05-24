import 'package:flutter/material.dart';

import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/responsive_content.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: const ResponsiveContent(
        child: EmptyState(
        title: 'No notifications',
        subtitle: 'Updates about courses and classes will appear here.',
        icon: Icons.notifications_none,
        ),
      ),
    );
  }
}
