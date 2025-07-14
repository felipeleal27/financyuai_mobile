/// Enum que representa as preferências de tema disponíveis
/// 
/// Suporta três modos:
/// - [system]: Segue o tema do sistema
/// - [light]: Tema claro forçado
/// - [dark]: Tema escuro forçado
enum ThemePreference {
  system('system', 'Sistema'),
  light('light', 'Claro'),
  dark('dark', 'Escuro');

  const ThemePreference(this.value, this.displayName);
  
  /// Valor string da preferência
  final String value;
  
  /// Nome para exibição na UI
  final String displayName;

  /// Converte uma string para ThemePreference
  /// 
  /// [value] String representando a preferência
  /// Retorna [ThemePreference.system] se o valor não for encontrado
  static ThemePreference fromString(String value) {
    return ThemePreference.values.firstWhere(
      (preference) => preference.value == value,
      orElse: () => ThemePreference.system,
    );
  }
}
