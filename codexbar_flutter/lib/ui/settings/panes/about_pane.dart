import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPane extends StatelessWidget {
  const AboutPane({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.speed,
              size: 48,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),

          // App name
          Text(
            'CodexBar',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Version
          Text(
            'Version 0.1.0 (Linux Port)',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),

          // Tagline
          Text(
            'Every AI coding limit, in your system tray.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Links
          Wrap(
            spacing: 16,
            children: [
              _buildLinkButton(
                context,
                icon: Icons.code,
                label: 'GitHub',
                onTap: () => _launchUrl('https://github.com/steipete/CodexBar'),
              ),
              _buildLinkButton(
                context,
                icon: Icons.language,
                label: 'Website',
                onTap: () => _launchUrl('https://codexbar.app'),
              ),
              _buildLinkButton(
                context,
                icon: Icons.bug_report,
                label: 'Report Issue',
                onTap: () => _launchUrl('https://github.com/steipete/CodexBar/issues'),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Credits
          Text(
            'Original macOS app by Peter Steinberger',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Linux port powered by Flutter',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'MIT License',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
