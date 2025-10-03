import 'package:mobx/mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:neo_financyuai/app/database/local_storage/local_storage.dart';

part 'settings_viewmodel.g.dart';

/// ViewModel responsável pelas configurações do aplicativo
/// 
/// Gerencia:
/// - Estado do chatbot (habilitado/desabilitado)
/// - Preferência de tema (claro/escuro)
/// - Persistência das configurações
// ignore: library_private_types_in_public_api
class SettingsViewmodel = _SettingsViewmodelBase with _$SettingsViewmodel;

abstract class _SettingsViewmodelBase with Store {
  static const String _kChatbotEnabled = 'settings.chatbot.enabled';
  static const String _kNotificationsEnabled = 'settings.notifications.enabled';
  static const String _kDailyRemindersEnabled = 'settings.notifications.daily.enabled';
  static const String _kAiRoutineEnabled = 'settings.notifications.ai.routine';
  static const String _kAiHolidayEnabled = 'settings.notifications.ai.holiday';
  static const String _kAiBalanceForecastEnabled = 'settings.notifications.ai.balanceForecast';
  static const String _kHighExpenseEnabled = 'settings.notifications.highExpense';
  static const String _kMonthlyReportEnabled = 'settings.notifications.monthlyReport';
  static const String _kSavingsAchievedEnabled = 'settings.notifications.savingsAchieved';
  final LocalStorage _storage = Modular.get<LocalStorage>();
  
  @observable
  bool _isChatbotEnabled = true;
  
  @observable
  bool _isDarkMode = false;

  @observable
  bool _notificationsEnabled = false;

  @observable
  bool _dailyRemindersEnabled = false;

  @observable
  bool _aiRoutineEnabled = false;

  @observable
  bool _aiHolidayEnabled = false;

  @observable
  bool _aiBalanceForecastEnabled = false;

  @observable
  bool _highExpenseEnabled = false;

  @observable
  bool _monthlyReportEnabled = false;

  @observable
  bool _savingsAchievedEnabled = false;

  /// Indica se o chatbot está habilitado
  bool get isChatbotEnabled => _isChatbotEnabled;

  /// Indica se o modo escuro está ativo
  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get dailyRemindersEnabled => _dailyRemindersEnabled;
  bool get aiRoutineEnabled => _aiRoutineEnabled;
  bool get aiHolidayEnabled => _aiHolidayEnabled;
  bool get aiBalanceForecastEnabled => _aiBalanceForecastEnabled;
  bool get highExpenseEnabled => _highExpenseEnabled;
  bool get monthlyReportEnabled => _monthlyReportEnabled;
  bool get savingsAchievedEnabled => _savingsAchievedEnabled;
  
  /// Carrega preferências salvas
  @action
  Future<void> load() async {
    try {
      final saved = await _storage.read<bool>(_kChatbotEnabled);
      if (saved != null) {
        _isChatbotEnabled = saved;
      }
      final notif = await _storage.read<bool>(_kNotificationsEnabled);
      if (notif != null) {
        _notificationsEnabled = notif;
      }
      final daily = await _storage.read<bool>(_kDailyRemindersEnabled);
      if (daily != null) {
        _dailyRemindersEnabled = daily;
      }
      final aiRoutine = await _storage.read<bool>(_kAiRoutineEnabled);
      if (aiRoutine != null) _aiRoutineEnabled = aiRoutine;
      final aiHoliday = await _storage.read<bool>(_kAiHolidayEnabled);
      if (aiHoliday != null) _aiHolidayEnabled = aiHoliday;
      final aiBalance = await _storage.read<bool>(_kAiBalanceForecastEnabled);
      if (aiBalance != null) _aiBalanceForecastEnabled = aiBalance;
      final highExpense = await _storage.read<bool>(_kHighExpenseEnabled);
      if (highExpense != null) _highExpenseEnabled = highExpense;
      final monthlyReport = await _storage.read<bool>(_kMonthlyReportEnabled);
      if (monthlyReport != null) _monthlyReportEnabled = monthlyReport;
      final savings = await _storage.read<bool>(_kSavingsAchievedEnabled);
      if (savings != null) _savingsAchievedEnabled = savings;
    } catch (_) {}
  }
  
  @action
  void toggleChatbot() {
    _isChatbotEnabled = !_isChatbotEnabled;
  }
  
  @action
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
  }
  
  @action
  void setTheme(bool value) {
    _isDarkMode = value;
  }
  
  @action
  void setChatbot(bool value) {
    _isChatbotEnabled = value;
    // persist async, fire-and-forget
    () async {
      try {
        await _storage.write<bool>(_kChatbotEnabled, value);
      } catch (_) {}
    }();
  }

  @action
  void setNotificationsEnabled(bool value) {
    _notificationsEnabled = value;
    () async {
      try {
        await _storage.write<bool>(_kNotificationsEnabled, value);
      } catch (_) {}
    }();
  }

  @action
  void setDailyRemindersEnabled(bool value) {
    _dailyRemindersEnabled = value;
    () async {
      try {
        await _storage.write<bool>(_kDailyRemindersEnabled, value);
      } catch (_) {}
    }();
  }

  @action
  void setAiRoutineEnabled(bool value) {
    _aiRoutineEnabled = value;
    () async { try { await _storage.write<bool>(_kAiRoutineEnabled, value); } catch (_) {} }();
  }

  @action
  void setAiHolidayEnabled(bool value) {
    _aiHolidayEnabled = value;
    () async { try { await _storage.write<bool>(_kAiHolidayEnabled, value); } catch (_) {} }();
  }

  @action
  void setAiBalanceForecastEnabled(bool value) {
    _aiBalanceForecastEnabled = value;
    () async { try { await _storage.write<bool>(_kAiBalanceForecastEnabled, value); } catch (_) {} }();
  }

  @action
  void setHighExpenseEnabled(bool value) {
    _highExpenseEnabled = value;
    () async { try { await _storage.write<bool>(_kHighExpenseEnabled, value); } catch (_) {} }();
  }

  @action
  void setMonthlyReportEnabled(bool value) {
    _monthlyReportEnabled = value;
    () async { try { await _storage.write<bool>(_kMonthlyReportEnabled, value); } catch (_) {} }();
  }

  @action
  void setSavingsAchievedEnabled(bool value) {
    _savingsAchievedEnabled = value;
    () async { try { await _storage.write<bool>(_kSavingsAchievedEnabled, value); } catch (_) {} }();
  }
}
