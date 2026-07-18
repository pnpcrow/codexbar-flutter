import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'general_pane.dart';
import 'notifications_pane.dart';
import 'providers_pane.dart';

/// Settings pane identifiers.
enum SettingsPane {
  general,
  providers,
  notifications,
  about;

  String get label {
    switch (this) {
      case SettingsPane.general:
        return 'General';
      case SettingsPane.providers:
        return 'Providers';
      case SettingsPane.notifications:
        return 'Notifications';
      case SettingsPane.about:
        return 'About';
    }
  }

  IconData get icon {
    switch (this) {
      case SettingsPane.general:
        return Icons.settings;
      case SettingsPane.providers:
        return Icons.api;
      case SettingsPane.notifications:
        return Icons.notifications;
      case SettingsPane.about:
        return Icons.info;
    }
  }
}

/// Preferences view - main settings screen.
/// Direct port of Swift PreferencesView.
class PreferencesView extends ConsumerStatefulWidget {
  final VoidCallback onBack;

  const PreferencesView({super.key, required this.onBack});

  @override
  ConsumerState<PreferencesView> createState() => _PreferencesViewState();
}

class _PreferencesViewState extends ConsumerState<PreferencesView> {
  SettingsPane _selectedPane = SettingsPane.general;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Title bar
          _buildTitleBar(context),

          // Content
          Expanded(
            child: Row(
              children: [
                // Sidebar
                _buildSidebar(context),

                // Divider
                VerticalDivider(width: 1, color: Theme.of(context).dividerColor),

                // Pane content
                Expanded(
                  child: _buildPaneContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleBar(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            onPressed: widget.onBack,
            tooltip: 'Back',
          ),
          const SizedBox(width: 8),
          Text(
            'Preferences',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        children: SettingsPane.values.map((pane) {
          final isSelected = _selectedPane == pane;
          return ListTile(
            leading: Icon(pane.icon, size: 20),
            title: Text(pane.label),
            selected: isSelected,
            dense: true,
            onTap: () => setState(() => _selectedPane = pane),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaneContent() {
    switch (_selectedPane) {
      case SettingsPane.general:
        return const GeneralPane();
      case SettingsPane.providers:
        return const ProvidersPane();
      case SettingsPane.notifications:
        return const NotificationsPane();
      case SettingsPane.about:
        return _buildAboutPane();
    }
  }

  Widget _buildAboutPane() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.monitor_heart, size: 64),
          const SizedBox(height: 16),
          Text(
            'CodexBar',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'v0.43.1 (build 105)',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'AI Provider Usage Monitor',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          Text(
            'Flutter Port',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}
