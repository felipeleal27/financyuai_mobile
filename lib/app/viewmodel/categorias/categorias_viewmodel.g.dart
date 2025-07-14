// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categorias_viewmodel.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$CategoriasViewmodel on _CategoriasViewmodelBase, Store {
  late final _$categoriasAtom = Atom(
    name: '_CategoriasViewmodelBase.categorias',
    context: context,
  );

  @override
  ObservableList<CategoriaModel> get categorias {
    _$categoriasAtom.reportRead();
    return super.categorias;
  }

  @override
  set categorias(ObservableList<CategoriaModel> value) {
    _$categoriasAtom.reportWrite(value, super.categorias, () {
      super.categorias = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: '_CategoriasViewmodelBase.isLoading',
    context: context,
  );

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$errorMessageAtom = Atom(
    name: '_CategoriasViewmodelBase.errorMessage',
    context: context,
  );

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$carregarCategoriasAsyncAction = AsyncAction(
    '_CategoriasViewmodelBase.carregarCategorias',
    context: context,
  );

  @override
  Future<void> carregarCategorias() {
    return _$carregarCategoriasAsyncAction.run(
      () => super.carregarCategorias(),
    );
  }

  late final _$adicionarCategoriaAsyncAction = AsyncAction(
    '_CategoriasViewmodelBase.adicionarCategoria',
    context: context,
  );

  @override
  Future<bool> adicionarCategoria(String nome, String icone) {
    return _$adicionarCategoriaAsyncAction.run(
      () => super.adicionarCategoria(nome, icone),
    );
  }

  late final _$atualizarCategoriaAsyncAction = AsyncAction(
    '_CategoriasViewmodelBase.atualizarCategoria',
    context: context,
  );

  @override
  Future<bool> atualizarCategoria(CategoriaModel categoria) {
    return _$atualizarCategoriaAsyncAction.run(
      () => super.atualizarCategoria(categoria),
    );
  }

  late final _$removerCategoriaAsyncAction = AsyncAction(
    '_CategoriasViewmodelBase.removerCategoria',
    context: context,
  );

  @override
  Future<bool> removerCategoria(int id) {
    return _$removerCategoriaAsyncAction.run(() => super.removerCategoria(id));
  }

  late final _$_CategoriasViewmodelBaseActionController = ActionController(
    name: '_CategoriasViewmodelBase',
    context: context,
  );

  @override
  void clearError() {
    final _$actionInfo = _$_CategoriasViewmodelBaseActionController.startAction(
      name: '_CategoriasViewmodelBase.clearError',
    );
    try {
      return super.clearError();
    } finally {
      _$_CategoriasViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
categorias: ${categorias},
isLoading: ${isLoading},
errorMessage: ${errorMessage}
    ''';
  }
}
