import 'package:flutter/material.dart';

import '../../core/constants/responsive_breakpoints.dart';
import 'app_settings_controls.dart';

/// Centers content and applies a max width on large screens.
class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = 960,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// Auth pages: centered card layout for mobile through desktop.
class AuthPageScaffold extends StatelessWidget {
  const AuthPageScaffold({
    super.key,
    required this.title,
    required this.child,
    this.showBack = false,
  });

  final String title;
  final Widget child;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final isWide = !ResponsiveBreakpoints.isMobile(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: showBack,
        title: showBack ? Text(title) : null,
        actions: const [
          AppSettingsControls(),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWide ? 480 : double.infinity,
              ),
              child: showBack
                  ? child
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!isWide) ...[
                          Icon(
                            Icons.school_outlined,
                            size: 56,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                        ],
                        child,
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// AppBar with automatic back button when navigation stack allows pop.
class AppPageScaffold extends StatelessWidget {
  const AppPageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          const AppSettingsControls(compact: true),
          ...?actions,
        ],
      ),
      body: ResponsiveContent(child: body),
      floatingActionButton: floatingActionButton,
    );
  }
}
