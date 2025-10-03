// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_viewmodel.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SettingsViewmodel on _SettingsViewmodelBase, Store {
  late final _$_isChatbotEnabledAtom = Atom(
    name: '_SettingsViewmodelBase._isChatbotEnabled',
    context: context,
  );

  @override
  bool get _isChatbotEnabled {
    _$_isChatbotEnabledAtom.reportRead();
    return super._isChatbotEnabled;
  }

  @override
  set _isChatbotEnabled(bool value) {
    _$_isChatbotEnabledAtom.reportWrite(value, super._isChatbotEnabled, () {
      super._isChatbotEnabled = value;
    });
  }

  late final _$_isDarkModeAtom = Atom(
    name: '_SettingsViewmodelBase._isDarkMode',
    context: context,
  );

  @override
  bool get _isDarkMode {
    _$_isDarkModeAtom.reportRead();
    return super._isDarkMode;
  }

  @override
  set _isDarkMode(bool value) {
    _$_isDarkModeAtom.reportWrite(value, super._isDarkMode, () {
      super._isDarkMode = value;
    });
  }

  late final _$_notificationsEnabledAtom = Atom(
    name: '_SettingsViewmodelBase._notificationsEnabled',
    context: context,
  );

  @override
  bool get _notificationsEnabled {
    _$_notificationsEnabledAtom.reportRead();
    return super._notificationsEnabled;
  }

  @override
  set _notificationsEnabled(bool value) {
    _$_notificationsEnabledAtom.reportWrite(
      value,
      super._notificationsEnabled,
      () {
        super._notificationsEnabled = value;
      },
    );
  }

  late final _$_dailyRemindersEnabledAtom = Atom(
    name: '_SettingsViewmodelBase._dailyRemindersEnabled',
    context: context,
  );

  @override
  bool get _dailyRemindersEnabled {
    _$_dailyRemindersEnabledAtom.reportRead();
    return super._dailyRemindersEnabled;
  }

  @override
  set _dailyRemindersEnabled(bool value) {
    _$_dailyRemindersEnabledAtom.reportWrite(
      value,
      super._dailyRemindersEnabled,
      () {
        super._dailyRemindersEnabled = value;
      },
    );
  }

  late final _$_aiRoutineEnabledAtom = Atom(
    name: '_SettingsViewmodelBase._aiRoutineEnabled',
    context: context,
  );

  @override
  bool get _aiRoutineEnabled {
    _$_aiRoutineEnabledAtom.reportRead();
    return super._aiRoutineEnabled;
  }

  @override
  set _aiRoutineEnabled(bool value) {
    _$_aiRoutineEnabledAtom.reportWrite(value, super._aiRoutineEnabled, () {
      super._aiRoutineEnabled = value;
    });
  }

  late final _$_aiHolidayEnabledAtom = Atom(
    name: '_SettingsViewmodelBase._aiHolidayEnabled',
    context: context,
  );

  @override
  bool get _aiHolidayEnabled {
    _$_aiHolidayEnabledAtom.reportRead();
    return super._aiHolidayEnabled;
  }

  @override
  set _aiHolidayEnabled(bool value) {
    _$_aiHolidayEnabledAtom.reportWrite(value, super._aiHolidayEnabled, () {
      super._aiHolidayEnabled = value;
    });
  }

  late final _$_aiBalanceForecastEnabledAtom = Atom(
    name: '_SettingsViewmodelBase._aiBalanceForecastEnabled',
    context: context,
  );

  @override
  bool get _aiBalanceForecastEnabled {
    _$_aiBalanceForecastEnabledAtom.reportRead();
    return super._aiBalanceForecastEnabled;
  }

  @override
  set _aiBalanceForecastEnabled(bool value) {
    _$_aiBalanceForecastEnabledAtom.reportWrite(
      value,
      super._aiBalanceForecastEnabled,
      () {
        super._aiBalanceForecastEnabled = value;
      },
    );
  }

  late final _$_highExpenseEnabledAtom = Atom(
    name: '_SettingsViewmodelBase._highExpenseEnabled',
    context: context,
  );

  @override
  bool get _highExpenseEnabled {
    _$_highExpenseEnabledAtom.reportRead();
    return super._highExpenseEnabled;
  }

  @override
  set _highExpenseEnabled(bool value) {
    _$_highExpenseEnabledAtom.reportWrite(value, super._highExpenseEnabled, () {
      super._highExpenseEnabled = value;
    });
  }

  late final _$_monthlyReportEnabledAtom = Atom(
    name: '_SettingsViewmodelBase._monthlyReportEnabled',
    context: context,
  );

  @override
  bool get _monthlyReportEnabled {
    _$_monthlyReportEnabledAtom.reportRead();
    return super._monthlyReportEnabled;
  }

  @override
  set _monthlyReportEnabled(bool value) {
    _$_monthlyReportEnabledAtom.reportWrite(
      value,
      super._monthlyReportEnabled,
      () {
        super._monthlyReportEnabled = value;
      },
    );
  }

  late final _$_savingsAchievedEnabledAtom = Atom(
    name: '_SettingsViewmodelBase._savingsAchievedEnabled',
    context: context,
  );

  @override
  bool get _savingsAchievedEnabled {
    _$_savingsAchievedEnabledAtom.reportRead();
    return super._savingsAchievedEnabled;
  }

  @override
  set _savingsAchievedEnabled(bool value) {
    _$_savingsAchievedEnabledAtom.reportWrite(
      value,
      super._savingsAchievedEnabled,
      () {
        super._savingsAchievedEnabled = value;
      },
    );
  }

  late final _$loadAsyncAction = AsyncAction(
    '_SettingsViewmodelBase.load',
    context: context,
  );

  @override
  Future<void> load() {
    return _$loadAsyncAction.run(() => super.load());
  }

  late final _$_SettingsViewmodelBaseActionController = ActionController(
    name: '_SettingsViewmodelBase',
    context: context,
  );

  @override
  void toggleChatbot() {
    final _$actionInfo = _$_SettingsViewmodelBaseActionController.startAction(
      name: '_SettingsViewmodelBase.toggleChatbot',
    );
    try {
      return super.toggleChatbot();
    } finally {
      _$_SettingsViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleTheme() {
    final _$actionInfo = _$_SettingsViewmodelBaseActionController.startAction(
      name: '_SettingsViewmodelBase.toggleTheme',
    );
    try {
      return super.toggleTheme();
    } finally {
      _$_SettingsViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setTheme(bool value) {
    final _$actionInfo = _$_SettingsViewmodelBaseActionController.startAction(
      name: '_SettingsViewmodelBase.setTheme',
    );
    try {
      return super.setTheme(value);
    } finally {
      _$_SettingsViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setChatbot(bool value) {
    final _$actionInfo = _$_SettingsViewmodelBaseActionController.startAction(
      name: '_SettingsViewmodelBase.setChatbot',
    );
    try {
      return super.setChatbot(value);
    } finally {
      _$_SettingsViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNotificationsEnabled(bool value) {
    final _$actionInfo = _$_SettingsViewmodelBaseActionController.startAction(
      name: '_SettingsViewmodelBase.setNotificationsEnabled',
    );
    try {
      return super.setNotificationsEnabled(value);
    } finally {
      _$_SettingsViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setDailyRemindersEnabled(bool value) {
    final _$actionInfo = _$_SettingsViewmodelBaseActionController.startAction(
      name: '_SettingsViewmodelBase.setDailyRemindersEnabled',
    );
    try {
      return super.setDailyRemindersEnabled(value);
    } finally {
      _$_SettingsViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setAiRoutineEnabled(bool value) {
    final _$actionInfo = _$_SettingsViewmodelBaseActionController.startAction(
      name: '_SettingsViewmodelBase.setAiRoutineEnabled',
    );
    try {
      return super.setAiRoutineEnabled(value);
    } finally {
      _$_SettingsViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setAiHolidayEnabled(bool value) {
    final _$actionInfo = _$_SettingsViewmodelBaseActionController.startAction(
      name: '_SettingsViewmodelBase.setAiHolidayEnabled',
    );
    try {
      return super.setAiHolidayEnabled(value);
    } finally {
      _$_SettingsViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setAiBalanceForecastEnabled(bool value) {
    final _$actionInfo = _$_SettingsViewmodelBaseActionController.startAction(
      name: '_SettingsViewmodelBase.setAiBalanceForecastEnabled',
    );
    try {
      return super.setAiBalanceForecastEnabled(value);
    } finally {
      _$_SettingsViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setHighExpenseEnabled(bool value) {
    final _$actionInfo = _$_SettingsViewmodelBaseActionController.startAction(
      name: '_SettingsViewmodelBase.setHighExpenseEnabled',
    );
    try {
      return super.setHighExpenseEnabled(value);
    } finally {
      _$_SettingsViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setMonthlyReportEnabled(bool value) {
    final _$actionInfo = _$_SettingsViewmodelBaseActionController.startAction(
      name: '_SettingsViewmodelBase.setMonthlyReportEnabled',
    );
    try {
      return super.setMonthlyReportEnabled(value);
    } finally {
      _$_SettingsViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSavingsAchievedEnabled(bool value) {
    final _$actionInfo = _$_SettingsViewmodelBaseActionController.startAction(
      name: '_SettingsViewmodelBase.setSavingsAchievedEnabled',
    );
    try {
      return super.setSavingsAchievedEnabled(value);
    } finally {
      _$_SettingsViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''

    ''';
  }
}
