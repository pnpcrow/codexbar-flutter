import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'core/providers/codex/codex_descriptor.dart';
import 'core/providers/provider_registry.dart';
import 'core/providers/unified_provider_registry.dart';

// Dedicated provider descriptors
import 'core/providers/alibaba/alibaba_descriptor.dart';
import 'core/providers/amp/amp_descriptor.dart';
import 'core/providers/claude/claude_descriptor.dart';
import 'core/providers/clawrouter/clawrouter_descriptor.dart';
import 'core/providers/crof/crof_descriptor.dart';
import 'core/providers/crossmodel/crossmodel_descriptor.dart';
import 'core/providers/cursor/cursor_descriptor.dart';
import 'core/providers/deepgram/deepgram_descriptor.dart';
import 'core/providers/deepseek/deepseek_descriptor.dart';
import 'core/providers/doubao/doubao_descriptor.dart';
import 'core/providers/elevenlabs/elevenlabs_descriptor.dart';
import 'core/providers/groq/groq_descriptor.dart';
import 'core/providers/kimi/kimi_descriptor.dart';
import 'core/providers/kimik2/kimik2_descriptor.dart';
import 'core/providers/litellm/litellm_descriptor.dart';
import 'core/providers/llmproxy/llmproxy_descriptor.dart';
import 'core/providers/minimax/minimax_descriptor.dart';
import 'core/providers/moonshot/moonshot_descriptor.dart';
import 'core/providers/openai/openai_descriptor.dart';
import 'core/providers/openrouter/openrouter_descriptor.dart';
import 'core/providers/perplexity/perplexity_descriptor.dart';
import 'core/providers/poe/poe_descriptor.dart';
import 'core/providers/stepfun/stepfun_descriptor.dart';
import 'core/providers/synthetic/synthetic_descriptor.dart';
import 'core/providers/venice/venice_descriptor.dart';
import 'core/providers/warp/warp_descriptor.dart';
import 'core/providers/zai/zai_descriptor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register all providers
  final registry = ProviderRegistry();

  // Register dedicated descriptors first (these take priority)
  registry.register(CodexDescriptor.descriptor);
  registry.register(ClaudeDescriptor.descriptor);
  registry.register(OpenAIDescriptor.descriptor);
  registry.register(WarpDescriptor.descriptor);
  registry.register(DoubaoDescriptor.descriptor);
  registry.register(StepFunDescriptor.descriptor);
  registry.register(VeniceDescriptor.descriptor);
  registry.register(CrofDescriptor.descriptor);
  registry.register(PoeDescriptor.descriptor);
  registry.register(KimiDescriptor.descriptor);
  registry.register(KimiK2Descriptor.descriptor);
  registry.register(MiniMaxDescriptor.descriptor);
  registry.register(AlibabaDescriptor.descriptor);
  registry.register(PerplexityDescriptor.descriptor);
  registry.register(DeepgramDescriptor.descriptor);
  registry.register(ElevenLabsDescriptor.descriptor);
  registry.register(GroqDescriptor.descriptor);
  registry.register(LLMProxyDescriptor.descriptor);
  registry.register(LiteLLMDescriptor.descriptor);
  registry.register(ClawRouterDescriptor.descriptor);
  registry.register(CrossModelDescriptor.descriptor);
  registry.register(DeepSeekDescriptor.descriptor);
  registry.register(MoonshotDescriptor.descriptor);
  registry.register(AmpDescriptor.descriptor);
  registry.register(ZaiDescriptor.descriptor);
  registry.register(SyntheticDescriptor.descriptor);
  registry.register(OpenRouterDescriptor.descriptor);
  registry.register(CursorDescriptor.descriptor);

  // Register remaining providers via unified registry
  UnifiedProviderRegistry.registerAll(registry);

  // Initialize window manager for desktop
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(420, 640),
    minimumSize: Size(360, 480),
    center: true,
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: true,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const ProviderScope(child: CodexBarApp()));
}
