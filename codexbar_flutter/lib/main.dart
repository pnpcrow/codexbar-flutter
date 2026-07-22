import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'core/services/credential_store.dart';
import 'core/services/http_client.dart';
import 'l10n/app_localizations.dart';
import 'ui/tray/tray_manager.dart' as tray;
import 'ui/popup/popup_window.dart';
import 'ui/settings/preferences_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await CredentialStore().initialize();
  HttpClient().initialize();

  // Initialize window manager for tray app
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(380, 500),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: true,
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.hide();
  });

  runApp(const ProviderScope(child: CodexBarApp()));
}

class CodexBarApp extends StatefulWidget {
  const CodexBarApp({super.key});

  @override
  State<CodexBarApp> createState() => _CodexBarAppState();
}

class _CodexBarAppState extends State<CodexBarApp> {
  final _trayManager = tray.TrayManagerImpl();

  @override
  void initState() {
    super.initState();
    _initializeTray();
  }

  Future<void> _initializeTray() async {
    await _trayManager.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CodexBar',
      debugShowCheckedModeBanner: false,
      navigatorKey: tray.navigatorKey,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ko'),
        Locale('ja'),
        Locale('zh'),
        Locale('de'),
        Locale('fr'),
        Locale('es'),
        Locale('pt'),
        Locale('ru'),
        Locale('ar'),
        Locale('it'),
        Locale('vi'),
        Locale('nl'),
        Locale('tr'),
        Locale('uk'),
        Locale('id'),
        Locale('pl'),
        Locale('th'),
        Locale('sv'),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const PopupWindow(),
      routes: {
        '/settings': (context) => const PreferencesView(),
      },
    );
  }
}
