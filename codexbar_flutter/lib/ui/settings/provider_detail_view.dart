import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/usage_provider.dart';
import '../../core/models/usage_snapshot.dart';
import '../../core/models/rate_window.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/fetch_strategy.dart';

/// Provider detail/settings view with API test, cookie input, source selection.
class ProviderDetailView extends ConsumerStatefulWidget {
  final UsageProvider provider;
  final VoidCallback onBack;

  const ProviderDetailView({
    super.key,
    required this.provider,
    required this.onBack,
  });

  @override
  ConsumerState<ProviderDetailView> createState() => _ProviderDetailViewState();
}

class _ProviderDetailViewState extends ConsumerState<ProviderDetailView> {
  final _apiTokenController = TextEditingController();
  final _cookieController = TextEditingController();
  String _selectedSourceMode = 'auto';
  bool _isTesting = false;
  String? _testError;
  UsageSnapshot? _testSnapshot;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await ref.read(settingsStoreProvider.future);
    if (!mounted) return;
    setState(() {
      _selectedSourceMode = settings.providerSourceMode(widget.provider) ?? 'auto';
      _apiTokenController.text = settings.providerAPIKey(widget.provider) ?? '';
      _cookieController.text = settings.providerManualCookieHeader(widget.provider) ?? '';
    });
  }

  @override
  void dispose() {
    _apiTokenController.dispose();
    _cookieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final registry = ref.watch(providerRegistryProvider);
    final descriptor = registry.descriptorFor(provider);

    return Scaffold(
      body: Column(
        children: [
          _buildTitleBar(context, provider),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildProviderInfo(context, provider, descriptor),
                const SizedBox(height: 20),
                _buildSourceSelection(context),
                const SizedBox(height: 16),
                _buildTokenInput(context),
                const SizedBox(height: 16),
                _buildCookieInput(context),
                const SizedBox(height: 20),
                _buildTestButton(context),
                if (_testSnapshot != null) ...[
                  const SizedBox(height: 16),
                  _buildTestSuccess(context),
                ],
                if (_testError != null) ...[
                  const SizedBox(height: 16),
                  _buildTestError(context),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleBar(BuildContext context, UsageProvider provider) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            onPressed: widget.onBack,
          ),
          const SizedBox(width: 8),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                provider.displayName[0],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            provider.displayName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderInfo(BuildContext context, UsageProvider provider, dynamic descriptor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Provider Info', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _infoRow('CLI Name', provider.cliName),
            if (descriptor?.metadata?.dashboardURL != null)
              _infoRow('Dashboard', descriptor!.metadata!.dashboardURL!),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline))),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildSourceSelection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Data Source', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Choose how to fetch usage data', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _sourceChip('auto', 'Auto', 'Try all methods'),
                _sourceChip('cli', 'CLI', 'Use CLI binary'),
                _sourceChip('web', 'Web', 'Browser cookies'),
                _sourceChip('api', 'API', 'API token'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sourceChip(String value, String label, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: FilterChip(
        label: Text(label),
        selected: _selectedSourceMode == value,
        onSelected: (selected) {
          if (selected) {
            setState(() => _selectedSourceMode = value);
            _saveSourceMode(value);
          }
        },
      ),
    );
  }

  Widget _buildTokenInput(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('API Token', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Enter API key or token', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline)),
            const SizedBox(height: 8),
            TextField(
              controller: _apiTokenController,
              decoration: InputDecoration(
                hintText: 'sk-... or API key',
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.save, size: 18),
                  onPressed: () => _saveApiKey(_apiTokenController.text),
                  tooltip: 'Save',
                ),
              ),
              obscureText: true,
              onSubmitted: _saveApiKey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCookieInput(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Manual Cookie', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              'Paste cookies from browser DevTools\n(F12 → Application → Cookies → copy name=value pairs)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _cookieController,
              decoration: InputDecoration(
                hintText: 'session_id=xxx; token=yyy; ...',
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.save, size: 18),
                  onPressed: () => _saveCookie(_cookieController.text),
                  tooltip: 'Save',
                ),
              ),
              maxLines: 3,
              onSubmitted: _saveCookie,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isTesting ? null : _runTest,
        icon: _isTesting
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.play_arrow),
        label: Text(_isTesting ? 'Testing...' : 'Test Connection'),
      ),
    );
  }

  Widget _buildTestSuccess(BuildContext context) {
    final snap = _testSnapshot!;
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer.withAlpha(50),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.check_circle, size: 18, color: Colors.green.shade600),
              const SizedBox(width: 8),
              Text('Test Successful', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.green.shade700, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 8),
            if (snap.primary != null) _usageRow('Session', snap.primary!),
            if (snap.secondary != null) _usageRow('Weekly', snap.secondary!),
            if (snap.identity?.accountEmail != null) _infoLine('Email', snap.identity!.accountEmail!),
            if (snap.identity?.loginMethod != null) _infoLine('Method', snap.identity!.loginMethod!),
          ],
        ),
      ),
    );
  }

  Widget _usageRow(String label, RateWindow window) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        SizedBox(width: 70, child: Text(label, style: const TextStyle(fontSize: 12))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: window.usedPercent / 100,
              minHeight: 8,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation(
                window.usedPercent > 90 ? Colors.red : window.usedPercent > 70 ? Colors.orange : Colors.green,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(width: 45, child: Text('${window.usedPercent.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
      ]),
    );
  }

  Widget _infoLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        SizedBox(width: 70, child: Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
      ]),
    );
  }

  Widget _buildTestError(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer.withAlpha(50),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.error_outline, size: 18, color: Colors.red.shade600),
              const SizedBox(width: 8),
              Text('Test Failed', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.red.shade700, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 8),
            Text(_testError!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error)),
          ],
        ),
      ),
    );
  }

  Future<void> _runTest() async {
    setState(() {
      _isTesting = true;
      _testError = null;
      _testSnapshot = null;
    });

    try {
      final registry = ref.read(providerRegistryProvider);
      final descriptor = registry.descriptorFor(widget.provider);
      if (descriptor == null) throw Exception('No descriptor for ${widget.provider.displayName}');

      // Build environment with manual inputs
      final env = <String, String>{};
      env.addAll(Platform.environment);

      final apiKey = _apiTokenController.text.trim();
      final cookie = _cookieController.text.trim();
      final prov = widget.provider.name.toUpperCase();

      if (apiKey.isNotEmpty) {
        env['${prov}_API_KEY'] = apiKey;
        env['${prov}_API_TOKEN'] = apiKey;
        // Also set common env var names
        if (widget.provider == UsageProvider.zai) env['ZAI_API_TOKEN'] = apiKey;
        if (widget.provider == UsageProvider.minimax) env['MINIMAX_API_TOKEN'] = apiKey;
        if (widget.provider == UsageProvider.claude) env['ANTHROPIC_API_KEY'] = apiKey;
        if (widget.provider == UsageProvider.openai) env['OPENAI_API_KEY'] = apiKey;
        if (widget.provider == UsageProvider.deepseek) env['DEEPSEEK_API_KEY'] = apiKey;
      }

      if (cookie.isNotEmpty) {
        env['${prov}_COOKIE'] = cookie;
      }

      final context = ProviderFetchContext(
        sourceMode: ProviderSourceMode.values.byName(_selectedSourceMode),
        includeCredits: true,
        env: env,
      );

      final outcome = await descriptor.fetchOutcome(context);

      if (outcome.isSuccess) {
        setState(() => _testSnapshot = outcome.result!.usage);
      } else {
        setState(() => _testError = outcome.error.toString());
      }
    } catch (e) {
      setState(() => _testError = e.toString());
    } finally {
      if (mounted) setState(() => _isTesting = false);
    }
  }

  Future<void> _saveSourceMode(String mode) async {
    final settings = await ref.read(settingsStoreProvider.future);
    settings.setProviderSourceMode(widget.provider, mode);
  }

  Future<void> _saveApiKey(String key) async {
    final settings = await ref.read(settingsStoreProvider.future);
    settings.setProviderAPIKey(widget.provider, key.isEmpty ? null : key);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('API key saved'), duration: Duration(seconds: 1)));
    }
  }

  Future<void> _saveCookie(String cookie) async {
    final settings = await ref.read(settingsStoreProvider.future);
    settings.setProviderManualCookieHeader(widget.provider, cookie.isEmpty ? null : cookie);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cookie saved'), duration: Duration(seconds: 1)));
    }
  }
}
