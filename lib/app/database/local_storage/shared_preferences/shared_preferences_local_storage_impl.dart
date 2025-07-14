import 'package:neo_financyuai/app/database/local_storage/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Implementação do LocalStorage usando SharedPreferences
/// Responsável por persistir dados simples no dispositivo
class SharedPreferencesLocalStorageImpl implements LocalStorage {
  /// Constantes para chaves utilizadas internamente
  static const String _keyCodigoColetor = "codigoColetor";
  static const String _keyFirstAccess = "isFirstAccess";

  /// Getter privado para obter instância do SharedPreferences
  Future<SharedPreferences> get _instance => SharedPreferences.getInstance();

  @override
  Future<void> clear() async {
    final sharedPreferences = await _instance;
    await sharedPreferences.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    final sharedPreferences = await _instance;
    return sharedPreferences.containsKey(key);
  }

  @override
  Future<V?> read<V>(String key) async {
    final sharedPreferences = await _instance;
    return sharedPreferences.get(key) as V?;
  }

  @override
  Future<void> remove(String key) async {
    final sharedPreferences = await _instance;
    await sharedPreferences.remove(key);
  }

  @override
  Future<void> write<V>(String key, V value) async {
    final sharedPreferences = await _instance;

    switch (V) {
      case const (String):
        await sharedPreferences.setString(key, value as String);
        break;
      case const (int):
        await sharedPreferences.setInt(key, value as int);
        break;
      case const (double):
        await sharedPreferences.setDouble(key, value as double);
        break;
      case const (bool):
        await sharedPreferences.setBool(key, value as bool);
        break;
      case const (List):
        await sharedPreferences.setStringList(key, value as List<String>);
        break;
      default:
        throw Exception('Type not supported: $V');
    }
  }

  @override
  Future<void> clearLogin(String key) async {
    final sharedPreferences = await _instance;
    await sharedPreferences.clear();

    await write<String>(_keyCodigoColetor, key);
  }

  @override
  Future<bool> isFirstAccess() async {
    final sharedPreferences = await _instance;
    bool isFirstTime = sharedPreferences.getBool(_keyFirstAccess) ?? true;

    if (isFirstTime) {
      await sharedPreferences.setBool(_keyFirstAccess, false);
    }

    return isFirstTime;
  }
}
