import '../../models/provider_branding.dart';
import '../../models/provider_metadata.dart';
import '../../models/usage_provider.dart';
import '../fetch_strategy.dart';
import '../provider_descriptor.dart';
import 'stepfun_fetch_strategy.dart';

/// StepFun provider descriptor.
class StepFunDescriptor {
  static final descriptor = ProviderDescriptor(
    id: UsageProvider.stepfun,
    metadata: const ProviderMetadata(
      id: UsageProvider.stepfun,
      displayName: 'StepFun',
      sessionLabel: 'Usage',
      weeklyLabel: 'Weekly',
      supportsOpus: false,
      supportsCredits: false,
      creditsHint: '',
      toggleTitle: 'Show StepFun usage',
      cliName: 'stepfun',
      defaultEnabled: false,
      dashboardURL: 'https://platform.stepfun.com/dashboard',
      statusPageURL: null,
    ),
    branding: const ProviderBranding(
      iconStyle: 'stepfun',
      iconResourceName: 'ProviderIcon-stepfun',
      colorValue: 0xFF7C3AED,
    ),
    pipeline: FetchPipeline(
      resolveStrategies: _resolveStrategies,
    ),
    cliName: 'stepfun',
  );

  static Future<List<FetchStrategy>> _resolveStrategies(
    ProviderFetchContext context,
  ) async {
    final strategies = <FetchStrategy>[];
    final api = StepFunFetchStrategy();
    if (await api.isAvailable(context)) {
      strategies.add(api);
    }
    return strategies;
  }
}
