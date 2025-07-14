import 'package:flutter/material.dart';
import 'package:neo_financyuai/app/database/local_storage/local_storage.dart';
import 'package:neo_financyuai/app/utils/theme_preference.dart';

/// Gerenciador de tema do aplicativo
/// 
/// Responsável por:
/// - Gerenciar a preferência de tema do usuário
/// - Notificar mudanças de tema para widgets interessados
/// - Persistir preferências no armazenamento local
/// - Fornecer métodos para alternar entre temas
class ThemeManager extends ChangeNotifier {
  static const String _themeKey = 'theme_preference';
  
  final LocalStorage _localStorage;
  ThemePreference _currentPreference = ThemePreference.system;

  /// Cria uma instância do gerenciador de tema
  ThemeManager(this._localStorage);

  /// Preferência atual de tema
  ThemePreference get currentPreference => _currentPreference;

  /// Retorna o ThemeMode baseado na preferência atual
  ThemeMode get themeMode {
    switch (_currentPreference) {
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
      case ThemePreference.system:
        return ThemeMode.system;
    }
  }

  /// Carrega a preferência de tema salva
  Future<void> loadThemePreference() async {
    try {
      final savedTheme = await _localStorage.read<String>(_themeKey);
      if (savedTheme != null) {
        _currentPreference = ThemePreference.fromString(savedTheme);
        notifyListeners();
      }
    } catch (e) {
      // Se houver erro ao carregar, mantém o padrão (sistema)
      debugPrint('Erro ao carregar preferência de tema: $e');
    }
  }

  /// Salva a nova preferência de tema
  Future<void> setThemePreference(ThemePreference preference) async {
    try {
      _currentPreference = preference;
      await _localStorage.write(_themeKey, preference.value);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao salvar preferência de tema: $e');
    }
  }

  /// Método para alternar entre os temas
  Future<void> toggleTheme() async {
    switch (_currentPreference) {
      case ThemePreference.system:
        await setThemePreference(ThemePreference.light);
        break;
      case ThemePreference.light:
        await setThemePreference(ThemePreference.dark);
        break;
      case ThemePreference.dark:
        await setThemePreference(ThemePreference.system);
        break;
    }
  }

  /// Verifica se está no modo escuro considerando a preferência
  bool isDarkMode(BuildContext context) {
    switch (_currentPreference) {
      case ThemePreference.light:
        return false;
      case ThemePreference.dark:
        return true;
      case ThemePreference.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
  }
}
