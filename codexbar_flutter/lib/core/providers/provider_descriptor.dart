import '../models/fetch_result.dart';
import '../models/provider_branding.dart';
import '../models/provider_metadata.dart';
import '../models/usage_provider.dart';
import 'fetch_strategy.dart';

/// Complete provider descriptor - metadata, branding, fetch plan.
/// Direct port of Swift ProviderDescriptor.
class ProviderDescriptor {
  final UsageProvider id;
  final ProviderMetadata metadata;
  final ProviderBranding branding;
  final FetchPipeline pipeline;
  final String cliName;
  final List<String> cliAliases;

  const ProviderDescriptor({
    required this.id,
    required this.metadata,
    required this.branding,
    required this.pipeline,
    required this.cliName,
    this.cliAliases = const [],
  });

  Future<ProviderFetchOutcome> fetchOutcome(ProviderFetchContext context) {
    return pipeline.fetch(context: context, providerName: id.name);
  }

  Future<ProviderFetchResult> fetch(ProviderFetchContext context) async {
    final outcome = await fetchOutcome(context);
    if (outcome.isSuccess) return outcome.result!;
    throw outcome.error!;
  }
}
