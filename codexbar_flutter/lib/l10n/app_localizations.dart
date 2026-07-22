import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _translations = {
    'en': _en,
    'ko': _ko,
    'ja': _ja,
    'zh': _zh,
    'de': _de,
    'fr': _fr,
    'es': _es,
    'pt': _pt,
    'ru': _ru,
    'ar': _ar,
    'it': _it,
    'vi': _vi,
    'nl': _nl,
    'tr': _tr,
    'uk': _uk,
    'id': _id,
    'pl': _pl,
    'th': _th,
    'sv': _sv,
  };

  String _t(String key) {
    final lang = locale.languageCode;
    return _translations[lang]?[key] ?? _translations['en']?[key] ?? key;
  }

  // Core UI
  String get appTitle => _t('app_title');
  String get settings => _t('settings');
  String get refresh => _t('refresh');
  String get refreshAll => _t('refresh_all');
  String get quit => _t('quit');
  String get cancel => _t('cancel');
  String get done => _t('done');
  String get ok => _t('ok');
  String get close => _t('close');
  String get enabled => _t('enabled');
  String get disabled => _t('disabled');

  // Settings panes
  String get tabGeneral => _t('tab_general');
  String get tabNotifications => _t('tab_notifications');
  String get tabMenuBar => _t('tab_menu_bar');
  String get tabMenu => _t('tab_menu');
  String get tabAdvanced => _t('tab_advanced');
  String get tabAbout => _t('tab_about');
  String get tabDebug => _t('tab_debug');
  String get tabProviders => _t('tab_providers');

  // General settings
  String get sectionSystem => _t('section_system');
  String get startAtLogin => _t('start_at_login');
  String get sectionRefreshing => _t('section_refreshing');
  String get refreshInterval => _t('refresh_interval');
  String get refreshOnOpen => _t('refresh_on_open');
  String get checkProviderStatus => _t('check_provider_status');
  String get sectionKeyboardShortcut => _t('section_keyboard_shortcut');
  String get quitApp => _t('quit_app');

  // Refresh frequencies
  String get refreshManual => _t('refresh_manual');
  String get refresh1min => _t('refresh_1min');
  String get refresh2min => _t('refresh_2min');
  String get refresh5min => _t('refresh_5min');
  String get refresh15min => _t('refresh_15min');
  String get refresh30min => _t('refresh_30min');
  String get refreshAdaptive => _t('refresh_adaptive');

  // Menu bar settings
  String get sectionIcon => _t('section_icon');
  String get menuBarStyle => _t('menu_bar_style');
  String get displayMode => _t('display_mode');
  String get sectionCombinedIcon => _t('section_combined_icon');
  String get mergeIcons => _t('merge_icons');
  String get showHighestUsage => _t('show_highest_usage');
  String get sectionAnimation => _t('section_animation');
  String get randomBlink => _t('random_blink');
  String get hideCritters => _t('hide_critters');

  // Notifications
  String get sessionQuotaNotifications => _t('session_quota_notifications');
  String get confettiOnSessionReset => _t('confetti_session_reset');
  String get confettiOnWeeklyReset => _t('confetti_weekly_reset');
  String get quotaWarnings => _t('quota_warnings');

  // Menu settings
  String get showUsedPercentage => _t('show_used_percentage');
  String get absoluteResetTimes => _t('absolute_reset_times');

  // Advanced
  String get hidePersonalInfo => _t('hide_personal_info');
  String get configFile => _t('config_file');
  String get clearAllSettings => _t('clear_all_settings');

  // Usage display
  String get usage => _t('usage');
  String get credits => _t('credits');
  String get balance => _t('balance');
  String get cost => _t('cost');
  String get session => _t('session');
  String get weekly => _t('weekly');
  String get monthly => _t('monthly');
  String get refreshing => _t('refreshing');
  String get notFetchedYet => _t('not_fetched_yet');
  String percentLeft(double percent) => _t('percent_left').replaceAll('{percent}', percent.toStringAsFixed(0));
  String get resets => _t('resets');
  String get noUsageData => _t('no_usage_data');

  // Provider status
  String get statusOperational => _t('status_operational');
  String get statusDegraded => _t('status_degraded');
  String get statusMajorOutage => _t('status_major_outage');

  // About
  String get version => _t('version');
  String get originalAppBy => _t('original_app_by');
  String get linuxPortBy => _t('linux_port_by');
  String get mitLicense => _t('mit_license');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ko', 'ja', 'zh', 'de', 'fr', 'es', 'pt', 'ru', 'ar', 'it', 'vi', 'nl', 'tr', 'uk', 'id', 'pl', 'th', 'sv'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}

// English translations
const Map<String, String> _en = {
  'app_title': 'CodexBar',
  'settings': 'Settings',
  'refresh': 'Refresh',
  'refresh_all': 'Refresh All',
  'quit': 'Quit',
  'cancel': 'Cancel',
  'done': 'Done',
  'ok': 'OK',
  'close': 'Close',
  'enabled': 'Enabled',
  'disabled': 'Disabled',
  'tab_general': 'General',
  'tab_notifications': 'Notifications',
  'tab_menu_bar': 'Menu Bar',
  'tab_menu': 'Menu',
  'tab_advanced': 'Advanced',
  'tab_about': 'About',
  'tab_debug': 'Debug',
  'tab_providers': 'Providers',
  'section_system': 'System',
  'start_at_login': 'Start at login',
  'section_refreshing': 'Refreshing',
  'refresh_interval': 'Refresh interval',
  'refresh_on_open': 'Refresh on menu open',
  'check_provider_status': 'Check provider status',
  'section_keyboard_shortcut': 'Keyboard Shortcut',
  'quit_app': 'Quit CodexBar',
  'refresh_manual': 'Manual',
  'refresh_1min': '1 minute',
  'refresh_2min': '2 minutes',
  'refresh_5min': '5 minutes',
  'refresh_15min': '15 minutes',
  'refresh_30min': '30 minutes',
  'refresh_adaptive': 'Adaptive',
  'section_icon': 'Icon',
  'menu_bar_style': 'Menu bar style',
  'display_mode': 'Display mode',
  'section_combined_icon': 'Combined Icon',
  'merge_icons': 'Merge icons',
  'show_highest_usage': 'Show highest usage',
  'section_animation': 'Animation',
  'random_blink': 'Random blink',
  'hide_critters': 'Hide critters',
  'session_quota_notifications': 'Session quota notifications',
  'confetti_session_reset': 'Confetti on session reset',
  'confetti_weekly_reset': 'Confetti on weekly reset',
  'quota_warnings': 'Quota warnings',
  'show_used_percentage': 'Show used percentage',
  'absolute_reset_times': 'Absolute reset times',
  'hide_personal_info': 'Hide personal info',
  'config_file': 'Configuration file',
  'clear_all_settings': 'Clear all settings',
  'usage': 'Usage',
  'credits': 'Credits',
  'balance': 'Balance',
  'cost': 'Cost',
  'session': 'Session',
  'weekly': 'Weekly',
  'monthly': 'Monthly',
  'refreshing': 'Refreshing',
  'not_fetched_yet': 'Not fetched yet',
  'percent_left': '{percent}% left',
  'resets': 'Resets',
  'no_usage_data': 'No usage data available',
  'status_operational': 'Operational',
  'status_degraded': 'Degraded',
  'status_major_outage': 'Major Outage',
  'version': 'Version',
  'original_app_by': 'Original macOS app by Peter Steinberger',
  'linux_port_by': 'Linux port powered by Flutter',
  'mit_license': 'MIT License',
};

// Korean translations
const Map<String, String> _ko = {
  'app_title': 'CodexBar',
  'settings': '설정',
  'refresh': '새로고침',
  'refresh_all': '모두 새로고침',
  'quit': '종료',
  'cancel': '취소',
  'done': '완료',
  'ok': '확인',
  'close': '닫기',
  'enabled': '활성화',
  'disabled': '비활성화',
  'tab_general': '일반',
  'tab_notifications': '알림',
  'tab_menu_bar': '메뉴 바',
  'tab_menu': '메뉴',
  'tab_advanced': '고급',
  'tab_about': '정보',
  'tab_debug': '디버그',
  'tab_providers': '프로바이더',
  'section_system': '시스템',
  'start_at_login': '로그인 시 시작',
  'section_refreshing': '새로고침',
  'refresh_interval': '새로고침 간격',
  'refresh_on_open': '메뉴 열 때 새로고침',
  'check_provider_status': '프로바이더 상태 확인',
  'section_keyboard_shortcut': '키보드 단축키',
  'quit_app': 'CodexBar 종료',
  'refresh_manual': '수동',
  'refresh_1min': '1분',
  'refresh_2min': '2분',
  'refresh_5min': '5분',
  'refresh_15min': '15분',
  'refresh_30min': '30분',
  'refresh_adaptive': '적응형',
  'section_icon': '아이콘',
  'menu_bar_style': '메뉴 바 스타일',
  'display_mode': '표시 모드',
  'section_combined_icon': '결합 아이콘',
  'merge_icons': '아이콘 합치기',
  'show_highest_usage': '가장 높은 사용량 표시',
  'section_animation': '애니메이션',
  'random_blink': '랜덤 깜빡임',
  'hide_critters': '캐릭터 숨기기',
  'session_quota_notifications': '세션 할당 알림',
  'confetti_session_reset': '세션 리셋 시 축하 효과',
  'confetti_weekly_reset': '주간 리셋 시 축하 효과',
  'quota_warnings': '할당 경고',
  'show_used_percentage': '사용률 표시',
  'absolute_reset_times': '절대 리셋 시간',
  'hide_personal_info': '개인정보 숨기기',
  'config_file': '설정 파일',
  'clear_all_settings': '모든 설정 초기화',
  'usage': '사용량',
  'credits': '크레딧',
  'balance': '잔액',
  'cost': '비용',
  'session': '세션',
  'weekly': '주간',
  'monthly': '월간',
  'refreshing': '새로고침 중',
  'not_fetched_yet': '아직 가져오지 않음',
  'percent_left': '{percent}% 남음',
  'resets': '리셋',
  'no_usage_data': '사용 데이터 없음',
  'status_operational': '정상',
  'status_degraded': '성능 저하',
  'status_major_outage': '주요 장애',
  'version': '버전',
  'original_app_by': '원본 macOS 앱: Peter Steinberger',
  'linux_port_by': 'Linux 포트: Flutter로 제작',
  'mit_license': 'MIT 라이선스',
};

// Japanese translations
const Map<String, String> _ja = {
  'app_title': 'CodexBar',
  'settings': '設定',
  'refresh': '更新',
  'refresh_all': 'すべて更新',
  'quit': '終了',
  'cancel': 'キャンセル',
  'done': '完了',
  'ok': 'OK',
  'close': '閉じる',
  'enabled': '有効',
  'disabled': '無効',
  'tab_general': '一般',
  'tab_notifications': '通知',
  'tab_menu_bar': 'メニューバー',
  'tab_menu': 'メニュー',
  'tab_advanced': '詳細',
  'tab_about': 'バージョン情報',
  'tab_debug': 'デバッグ',
  'tab_providers': 'プロバイダー',
  'section_system': 'システム',
  'start_at_login': 'ログイン時に起動',
  'section_refreshing': '更新',
  'refresh_interval': '更新間隔',
  'refresh_on_open': 'メニューを開いた時に更新',
  'check_provider_status': 'プロバイダーの状態を確認',
  'section_keyboard_shortcut': 'キーボードショートカット',
  'quit_app': 'CodexBarを終了',
  'refresh_manual': '手動',
  'refresh_1min': '1分',
  'refresh_2min': '2分',
  'refresh_5min': '5分',
  'refresh_15min': '15分',
  'refresh_30min': '30分',
  'refresh_adaptive': 'アダプティブ',
  'section_icon': 'アイコン',
  'menu_bar_style': 'メニューバースタイル',
  'display_mode': '表示モード',
  'section_combined_icon': '結合アイコン',
  'merge_icons': 'アイコンを結合',
  'show_highest_usage': '最も使用量の多いものを表示',
  'section_animation': 'アニメーション',
  'random_blink': 'ランダム瞬き',
  'hide_critters': 'キャラクターを隠す',
  'session_quota_notifications': 'セッション割り当て通知',
  'confetti_session_reset': 'セッションリセット時に紙吹雪',
  'confetti_weekly_reset': '週間リセット時に紙吹雪',
  'quota_warnings': '割り当て警告',
  'show_used_percentage': '使用率を表示',
  'absolute_reset_times': '絶対リセット時間',
  'hide_personal_info': '個人情報を隠す',
  'config_file': '設定ファイル',
  'clear_all_settings': 'すべての設定をクリア',
  'usage': '使用量',
  'credits': 'クレジット',
  'balance': '残高',
  'cost': 'コスト',
  'session': 'セッション',
  'weekly': '週間',
  'monthly': '月間',
  'refreshing': '更新中',
  'not_fetched_yet': 'まだ取得していません',
  'percent_left': '残り{percent}%',
  'resets': 'リセット',
  'no_usage_data': '使用データがありません',
  'status_operational': '正常',
  'status_degraded': '性能低下',
  'status_major_outage': '重大な障害',
  'version': 'バージョン',
  'original_app_by': '元のmacOSアプリ: Peter Steinberger',
  'linux_port_by': 'Linuxポート: Flutterで制作',
  'mit_license': 'MITライセンス',
};

// Chinese (Simplified)
const Map<String, String> _zh = {
  'app_title': 'CodexBar', 'settings': '设置', 'refresh': '刷新', 'refresh_all': '全部刷新',
  'quit': '退出', 'cancel': '取消', 'done': '完成', 'ok': '确定', 'close': '关闭',
  'enabled': '已启用', 'disabled': '已禁用', 'tab_general': '通用', 'tab_notifications': '通知',
  'tab_menu_bar': '菜单栏', 'tab_menu': '菜单', 'tab_advanced': '高级', 'tab_about': '关于',
  'tab_debug': '调试', 'tab_providers': '提供商', 'section_system': '系统',
  'start_at_login': '登录时启动', 'section_refreshing': '刷新', 'refresh_interval': '刷新间隔',
  'quit_app': '退出 CodexBar', 'refresh_manual': '手动', 'refresh_5min': '5分钟',
  'usage': '使用量', 'credits': '积分', 'session': '会话', 'weekly': '每周', 'monthly': '每月',
};

// German
const Map<String, String> _de = {
  'app_title': 'CodexBar', 'settings': 'Einstellungen', 'refresh': 'Aktualisieren', 'refresh_all': 'Alle aktualisieren',
  'quit': 'Beenden', 'cancel': 'Abbrechen', 'done': 'Fertig', 'ok': 'OK', 'close': 'Schließen',
  'enabled': 'Aktiviert', 'disabled': 'Deaktiviert', 'tab_general': 'Allgemein', 'tab_notifications': 'Benachrichtigungen',
  'tab_menu_bar': 'Menüleiste', 'tab_menu': 'Menü', 'tab_advanced': 'Erweitert', 'tab_about': 'Über',
  'tab_debug': 'Debug', 'tab_providers': 'Anbieter', 'section_system': 'System',
  'start_at_login': 'Beim Login starten', 'section_refreshing': 'Aktualisierung',
  'usage': 'Nutzung', 'credits': 'Guthaben', 'session': 'Sitzung', 'weekly': 'Wöchentlich', 'monthly': 'Monatlich',
};

// French
const Map<String, String> _fr = {
  'app_title': 'CodexBar', 'settings': 'Paramètres', 'refresh': 'Actualiser', 'refresh_all': 'Tout actualiser',
  'quit': 'Quitter', 'cancel': 'Annuler', 'done': 'Terminé', 'ok': 'OK', 'close': 'Fermer',
  'enabled': 'Activé', 'disabled': 'Désactivé', 'tab_general': 'Général', 'tab_notifications': 'Notifications',
  'tab_menu_bar': 'Barre de menus', 'tab_menu': 'Menu', 'tab_advanced': 'Avancé', 'tab_about': 'À propos',
  'tab_debug': 'Débogage', 'tab_providers': 'Fournisseurs', 'section_system': 'Système',
  'usage': 'Utilisation', 'credits': 'Crédits', 'session': 'Session', 'weekly': 'Hebdomadaire', 'monthly': 'Mensuel',
};

// Spanish
const Map<String, String> _es = {
  'app_title': 'CodexBar', 'settings': 'Configuración', 'refresh': 'Actualizar', 'refresh_all': 'Actualizar todo',
  'quit': 'Salir', 'cancel': 'Cancelar', 'done': 'Hecho', 'ok': 'OK', 'close': 'Cerrar',
  'enabled': 'Habilitado', 'disabled': 'Deshabilitado', 'tab_general': 'General', 'tab_notifications': 'Notificaciones',
  'usage': 'Uso', 'credits': 'Créditos', 'session': 'Sesión', 'weekly': 'Semanal', 'monthly': 'Mensual',
};

// Portuguese (Brazil)
const Map<String, String> _pt = {
  'app_title': 'CodexBar', 'settings': 'Configurações', 'refresh': 'Atualizar', 'refresh_all': 'Atualizar tudo',
  'quit': 'Sair', 'cancel': 'Cancelar', 'done': 'Concluído', 'ok': 'OK', 'close': 'Fechar',
  'usage': 'Uso', 'credits': 'Créditos', 'session': 'Sessão', 'weekly': 'Semanal', 'monthly': 'Mensal',
};

// Russian
const Map<String, String> _ru = {
  'app_title': 'CodexBar', 'settings': 'Настройки', 'refresh': 'Обновить', 'refresh_all': 'Обновить все',
  'quit': 'Выход', 'cancel': 'Отмена', 'done': 'Готово', 'ok': 'OK', 'close': 'Закрыть',
  'usage': 'Использование', 'credits': 'Кредиты', 'session': 'Сессия', 'weekly': 'Еженедельно', 'monthly': 'Ежемесячно',
};

// Arabic
const Map<String, String> _ar = {
  'app_title': 'CodexBar', 'settings': 'الإعدادات', 'refresh': 'تحديث', 'refresh_all': 'تحديث الكل',
  'quit': 'خروج', 'cancel': 'إلغاء', 'done': 'تم', 'ok': 'موافق', 'close': 'إغلاق',
  'usage': 'الاستخدام', 'credits': 'الأرصدة', 'session': 'الجلسة', 'weekly': 'أسبوعي', 'monthly': 'شهري',
};

// Italian
const Map<String, String> _it = {
  'app_title': 'CodexBar', 'settings': 'Impostazioni', 'refresh': 'Aggiorna', 'refresh_all': 'Aggiorna tutto',
  'quit': 'Esci', 'cancel': 'Annulla', 'done': 'Fatto', 'ok': 'OK', 'close': 'Chiudi',
  'usage': 'Utilizzo', 'credits': 'Crediti', 'session': 'Sessione', 'weekly': 'Settimanale', 'monthly': 'Mensile',
};

// Vietnamese
const Map<String, String> _vi = {
  'app_title': 'CodexBar', 'settings': 'Cài đặt', 'refresh': 'Làm mới', 'refresh_all': 'Làm mới tất cả',
  'quit': 'Thoát', 'cancel': 'Hủy', 'done': 'Xong', 'ok': 'OK', 'close': 'Đóng',
  'usage': 'Sử dụng', 'credits': 'Tín dụng', 'session': 'Phiên', 'weekly': 'Hàng tuần', 'monthly': 'Hàng tháng',
};

// Dutch
const Map<String, String> _nl = {
  'app_title': 'CodexBar', 'settings': 'Instellingen', 'refresh': 'Vernieuwen', 'refresh_all': 'Alles vernieuwen',
  'quit': 'Afsluiten', 'cancel': 'Annuleren', 'done': 'Gereed', 'ok': 'OK', 'close': 'Sluiten',
  'usage': 'Gebruik', 'credits': 'Credits', 'session': 'Sessie', 'weekly': 'Wekelijks', 'monthly': 'Maandelijks',
};

// Turkish
const Map<String, String> _tr = {
  'app_title': 'CodexBar', 'settings': 'Ayarlar', 'refresh': 'Yenile', 'refresh_all': 'Tümünü yenile',
  'quit': 'Çıkış', 'cancel': 'İptal', 'done': 'Bitti', 'ok': 'Tamam', 'close': 'Kapat',
  'usage': 'Kullanım', 'credits': 'Kredi', 'session': 'Oturum', 'weekly': 'Haftalık', 'monthly': 'Aylık',
};

// Ukrainian
const Map<String, String> _uk = {
  'app_title': 'CodexBar', 'settings': 'Налаштування', 'refresh': 'Оновити', 'refresh_all': 'Оновити все',
  'quit': 'Вийти', 'cancel': 'Скасувати', 'done': 'Готово', 'ok': 'OK', 'close': 'Закрити',
  'usage': 'Використання', 'credits': 'Кредити', 'session': 'Сесія', 'weekly': 'Щотижня', 'monthly': 'Щомісяця',
};

// Indonesian
const Map<String, String> _id = {
  'app_title': 'CodexBar', 'settings': 'Pengaturan', 'refresh': 'Segarkan', 'refresh_all': 'Segarkan semua',
  'quit': 'Keluar', 'cancel': 'Batal', 'done': 'Selesai', 'ok': 'OK', 'close': 'Tutup',
  'usage': 'Penggunaan', 'credits': 'Kredit', 'session': 'Sesi', 'weekly': 'Mingguan', 'monthly': 'Bulanan',
};

// Polish
const Map<String, String> _pl = {
  'app_title': 'CodexBar', 'settings': 'Ustawienia', 'refresh': 'Odśwież', 'refresh_all': 'Odśwież wszystko',
  'quit': 'Zamknij', 'cancel': 'Anuluj', 'done': 'Gotowe', 'ok': 'OK', 'close': 'Zamknij',
  'usage': 'Użycie', 'credits': 'Kredyty', 'session': 'Sesja', 'weekly': 'Tygodniowo', 'monthly': 'Miesięcznie',
};

// Thai
const Map<String, String> _th = {
  'app_title': 'CodexBar', 'settings': 'การตั้งค่า', 'refresh': 'รีเฟรช', 'refresh_all': 'รีเฟรชทั้งหมด',
  'quit': 'ออก', 'cancel': 'ยกเลิก', 'done': 'เสร็จ', 'ok': 'ตกลง', 'close': 'ปิด',
  'usage': 'การใช้งาน', 'credits': 'เครดิต', 'session': 'เซสชัน', 'weekly': 'รายสัปดาห์', 'monthly': 'รายเดือน',
};

// Swedish
const Map<String, String> _sv = {
  'app_title': 'CodexBar', 'settings': 'Inställningar', 'refresh': 'Uppdatera', 'refresh_all': 'Uppdatera alla',
  'quit': 'Avsluta', 'cancel': 'Avbryt', 'done': 'Klar', 'ok': 'OK', 'close': 'Stäng',
  'usage': 'Användning', 'credits': 'Krediter', 'session': 'Session', 'weekly': 'Veckovis', 'monthly': 'Månadsvis',
};
