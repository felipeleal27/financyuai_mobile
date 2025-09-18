// ignore_for_file: library_private_types_in_public_api
import 'package:mobx/mobx.dart';
import 'package:neo_financyuai/app/data/model/categoria_model.dart';
import 'package:neo_financyuai/app/repository/home_repository/home_repository.dart';
import 'package:neo_financyuai/app/service/firebase_category_service.dart';
import 'package:neo_financyuai/app/service/auth_service.dart';

part 'categorias_viewmodel.g.dart';

class CategoriasViewmodel = _CategoriasViewmodelBase with _$CategoriasViewmodel;

abstract class _CategoriasViewmodelBase with Store {
  final HomeRepository _repository;
  final FirebaseCategoryService _firebaseService;
  final AuthService _authService;

  _CategoriasViewmodelBase(this._repository, this._firebaseService, this._authService);

  @observable
  ObservableList<CategoriaModel> categorias = ObservableList<CategoriaModel>();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @action
  Future<void> carregarCategorias() async {
    isLoading = true;
    errorMessage = null;
    
    try {
      final result = await _repository.getCategorias();
      categorias.clear();
      categorias.addAll(result);
    } catch (e) {
      errorMessage = 'Erro ao carregar categorias: $e';
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<bool> adicionarCategoria(String nome, String icone) async {
    try {
      final userId = _authService.userId;
      
      // Cria categoria com ID do usuário se estiver logado
      final categoria = CategoriaModel(
        id: 0, // O banco irá gerar o ID
        nome: nome,
        icone: icone,
        idUsuario: userId, // Associa ao usuário logado
      );
      
      // 1. Salva no SQLite local
      final sucesso = await _repository.inserirCategoria(categoria);
      
      // 2. Se salvou no SQLite e usuário está logado, salva no Firebase
      if (sucesso && userId != null) {
        await _firebaseService.saveUserCategory(userId, nome, icone);
      }
      
      if (sucesso) {
        await carregarCategorias(); // Recarrega a lista
      }
      return sucesso;
    } catch (e) {
      errorMessage = 'Erro ao adicionar categoria: $e';
      return false;
    }
  }

  @action
  Future<bool> atualizarCategoria(CategoriaModel categoria) async {
    try {
      final sucesso = await _repository.atualizarCategoria(categoria);
      if (sucesso) {
        await carregarCategorias(); // Recarrega a lista
      }
      return sucesso;
    } catch (e) {
      errorMessage = 'Erro ao atualizar categoria: $e';
      return false;
    }
  }

  @action
  Future<bool> removerCategoria(int id) async {
    try {
      final sucesso = await _repository.removerCategoria(id);
      if (sucesso) {
        await carregarCategorias(); // Recarrega a lista
      } else {
        errorMessage = 'Não é possível remover: existem transações associadas à categoria';
      }
      return sucesso;
    } catch (e) {
      errorMessage = 'Erro ao remover categoria: $e';
      return false;
    }
  }

  @action
  void clearError() {
    errorMessage = null;
  }
}
