import 'package:mobx/mobx.dart';

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
  
  @observable
  bool _isChatbotEnabled = true;
  
  @observable
  bool _isDarkMode = false;

  /// Indica se o chatbot está habilitado
  bool get isChatbotEnabled => _isChatbotEnabled;

  /// Indica se o modo escuro está ativo
  bool get isDarkMode => _isDarkMode;
  
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
  }
}
