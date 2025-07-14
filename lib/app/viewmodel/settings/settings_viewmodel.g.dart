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
  String toString() {
    return '''

    ''';
  }
}
