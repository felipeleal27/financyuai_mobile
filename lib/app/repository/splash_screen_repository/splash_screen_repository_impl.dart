import 'package:flutter/foundation.dart';
import 'package:neo_financyuai/app/database/local_storage/local_storage.dart';
import 'package:neo_financyuai/app/database/sqllite/db.dart';
import 'package:neo_financyuai/app/database/sqllite/sql_lite.dart';
import 'package:neo_financyuai/app/repository/splash_screen_repository/splash_screen_repository.dart';
import 'package:neo_financyuai/app/service/exceptions/rest_client.dart';

/// Implementação do repositório da splash screen
/// Responsável por inicialização e cálculos de saldo total
class SplashScreenRepositoryImpl extends SplashScreenRepository {
  final LocalStorage _localStorage;

  SplashScreenRepositoryImpl({
    required RestClient restClient, // Mantido para compatibilidade futura
    required LocalStorage localStorage,
  }) : _localStorage = localStorage;

  /// Verifica se é o primeiro acesso do usuário
  Future<bool> _primeiroAcesso() async {
    return await _localStorage.isFirstAccess();
  }

  @override
  Future<bool> calcularSaldoTotal() async {
    try {
      if (await _primeiroAcesso()) {
        final db = await DB.instance.database;
        final query = CommandSql(db);
        var saldo = await query
            .rawQuery('SELECT SUM(valor) as saldo FROM movimentacao');
        if (saldo.isNotEmpty) {
          await _localStorage.write('saldo', saldo.first['saldo'].toString());
          return true;
        } else {
          return false;
        }
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }
}
