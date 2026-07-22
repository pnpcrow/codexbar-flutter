import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/rate_window.dart';
import '../../core/models/usage_snapshot.dart';
import '../common/usage_progress_bar.dart';

class UsageMenuCardView extends StatelessWidget {
  final UsageProvider provider;
  final UsageSnapshot? snapshot;
  final String? error;
  final bool isRefreshing;
  final double width;

  const UsageMenuCardView({
    super.key,
    required this.provider,
    this.snapshot,
    this.error,
    this.isRefreshing = false,
    this.width = 340,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progressColor = AppColors.progressColor(provider);

    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context, colorScheme),
          if (error != null) ...[
            const SizedBox(height: 8),
            _buildError(context, colorScheme),
          ] else if (snapshot != null) ...[
            const Divider(height: 24),
            _buildUsageContent(context, progressColor),
          ] else if (isRefreshing) ...[
            const Divider(height: 24),
            _buildLoading(context),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                provider.displayName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (snapshot?.identity?.accountEmail != null)
                Text(
                  snapshot!.identity!.accountEmail!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        if (snapshot?.identity?.loginMethod != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              snapshot!.identity!.loginMethod!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildError(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 16, color: colorScheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error!,
              style: TextStyle(color: colorScheme.error, fontSize: 12),
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildUsageContent(BuildContext context, Color progressColor) {
    final theme = Theme.of(context);
    final metrics = <Widget>[];

    if (snapshot?.primary != null) {
      metrics.add(_buildMetricRow(
        context,
        title: 'Session',
        window: snapshot!.primary!,
        progressColor: progressColor,
      ));
    }

    if (snapshot?.secondary != null) {
      metrics.add(_buildMetricRow(
        context,
        title: 'Weekly',
        window: snapshot!.secondary!,
        progressColor: progressColor,
      ));
    }

    if (snapshot?.tertiary != null) {
      metrics.add(_buildMetricRow(
        context,
        title: 'Monthly',
        window: snapshot!.tertiary!,
        progressColor: progressColor,
      ));
    }

    if (metrics.isEmpty) {
      return Text(
        'No usage data available',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < metrics.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          metrics[i],
        ],
      ],
    );
  }

  Widget _buildMetricRow(
    BuildContext context, {
    required String title,
    required RateWindow window,
    required Color progressColor,
  }) {
    final theme = Theme.of(context);
    final remaining = window.remainingPercent;
    final percentLabel = '${remaining.toStringAsFixed(0)}% left';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (window.resetDescription != null)
              Text(
                window.resetDescription!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        UsageProgressBar(
          percent: remaining,
          color: progressColor,
        ),
        const SizedBox(height: 4),
        Text(
          percentLabel,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
