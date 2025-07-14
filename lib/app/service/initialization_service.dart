import 'package:flutter/rendering.dart';
import 'package:neo_financyuai/app/database/local_storage/local_storage.dart';
import 'package:neo_financyuai/app/database/sqllite/db.dart';
import 'package:neo_financyuai/app/service/firebase_category_service.dart';

/// Serviço responsável pela inicialização de dados padrão do aplicativo
class InitializationService {
  final LocalStorage _localStorage;

  /// Cria uma instância do serviço de inicialização
  const InitializationService(this._localStorage);

  /// Popula as categorias padrão se for o primeiro acesso do usuário
  Future<void> popularCategoriasSePrimeiroAcesso(String idUsuario) async {
    try {
      final isFirst = await _localStorage.isFirstAccess();
      
      if (isFirst) {
        await _inserirCategoriasPadrao(idUsuario);
        await _marcarPrimeiroAcessoConcluido();
        
        debugPrint('Categorias padrão inseridas com sucesso para o usuário $idUsuario');
      }
    } catch (e) {
      debugPrint('Erro ao popular categorias: $e');
      rethrow;
    }
  }

  /// Insere as categorias padrão no banco de dados
  Future<void> _inserirCategoriasPadrao(String idUsuario) async {
    final db = await DB.instance.database;

    // Busca categorias padrão e do usuário no Firebase
    final firebaseService = FirebaseCategoryService();
    final defaultCats = await firebaseService.fetchDefaultCategories();
    final userCats = await firebaseService.fetchUserCategories(idUsuario);
    // Combina categorias
    final allCats = [...defaultCats, ...userCats];
    // Recupera categorias já presentes no SQLite para este usuário
    final existing = await db.query(
      'categoria',
      where: 'IdUsuario IS NULL OR IdUsuario = ?',
      whereArgs: [idUsuario],
    );
    // Insere categorias que ainda não existem
    for (final cat in allCats) {
      final nome = cat['Nome'];
      final usuario = cat['IdUsuario'];
      final existe = existing.any((e) =>
        e['Nome'] == nome &&
        (e['IdUsuario'] as String?) == usuario
      );
      if (!existe) {
        await db.insert('categoria', cat);
      }
    }
  }

  /// Marca que o primeiro acesso foi concluído
  Future<void> _marcarPrimeiroAcessoConcluido() async {
    await _localStorage.write('first_access_completed', true);
  }

  /// Verifica se as categorias já foram inicializadas
  Future<bool> categoriesInitialized() async {
    return await _localStorage.containsKey('first_access_completed');
  }

  /// Reset para desenvolvimento (remove a marcação de primeiro acesso)
  Future<void> resetFirstAccess() async {
    await _localStorage.remove('first_access_completed');
  }
}
