// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_viewmodel.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HomeViewmodel on HomeViewmodelBase, Store {
  late final _$_carregouAtom = Atom(
    name: 'HomeViewmodelBase._carregou',
    context: context,
  );

  @override
  bool get _carregou {
    _$_carregouAtom.reportRead();
    return super._carregou;
  }

  @override
  set _carregou(bool value) {
    _$_carregouAtom.reportWrite(value, super._carregou, () {
      super._carregou = value;
    });
  }

  late final _$_canSeeValueAtom = Atom(
    name: 'HomeViewmodelBase._canSeeValue',
    context: context,
  );

  @override
  bool get _canSeeValue {
    _$_canSeeValueAtom.reportRead();
    return super._canSeeValue;
  }

  @override
  set _canSeeValue(bool value) {
    _$_canSeeValueAtom.reportWrite(value, super._canSeeValue, () {
      super._canSeeValue = value;
    });
  }

  late final _$_valorAtom = Atom(
    name: 'HomeViewmodelBase._valor',
    context: context,
  );

  @override
  double get _valor {
    _$_valorAtom.reportRead();
    return super._valor;
  }

  @override
  set _valor(double value) {
    _$_valorAtom.reportWrite(value, super._valor, () {
      super._valor = value;
    });
  }

  late final _$_saldoAtualAtom = Atom(
    name: 'HomeViewmodelBase._saldoAtual',
    context: context,
  );

  @override
  double get _saldoAtual {
    _$_saldoAtualAtom.reportRead();
    return super._saldoAtual;
  }

  @override
  set _saldoAtual(double value) {
    _$_saldoAtualAtom.reportWrite(value, super._saldoAtual, () {
      super._saldoAtual = value;
    });
  }

  late final _$_categoriaSelecionadaAtom = Atom(
    name: 'HomeViewmodelBase._categoriaSelecionada',
    context: context,
  );

  @override
  CategoriaModel? get _categoriaSelecionada {
    _$_categoriaSelecionadaAtom.reportRead();
    return super._categoriaSelecionada;
  }

  @override
  set _categoriaSelecionada(CategoriaModel? value) {
    _$_categoriaSelecionadaAtom.reportWrite(
      value,
      super._categoriaSelecionada,
      () {
        super._categoriaSelecionada = value;
      },
    );
  }

  late final _$_dataSelecionadaAtom = Atom(
    name: 'HomeViewmodelBase._dataSelecionada',
    context: context,
  );

  @override
  DateTime get _dataSelecionada {
    _$_dataSelecionadaAtom.reportRead();
    return super._dataSelecionada;
  }

  @override
  set _dataSelecionada(DateTime value) {
    _$_dataSelecionadaAtom.reportWrite(value, super._dataSelecionada, () {
      super._dataSelecionada = value;
    });
  }

  late final _$_nomeMovimentacaoAtom = Atom(
    name: 'HomeViewmodelBase._nomeMovimentacao',
    context: context,
  );

  @override
  String get _nomeMovimentacao {
    _$_nomeMovimentacaoAtom.reportRead();
    return super._nomeMovimentacao;
  }

  @override
  set _nomeMovimentacao(String value) {
    _$_nomeMovimentacaoAtom.reportWrite(value, super._nomeMovimentacao, () {
      super._nomeMovimentacao = value;
    });
  }

  late final _$_isSaidaAtom = Atom(
    name: 'HomeViewmodelBase._isSaida',
    context: context,
  );

  @override
  bool get _isSaida {
    _$_isSaidaAtom.reportRead();
    return super._isSaida;
  }

  @override
  set _isSaida(bool value) {
    _$_isSaidaAtom.reportWrite(value, super._isSaida, () {
      super._isSaida = value;
    });
  }

  late final _$_categoriasAtom = Atom(
    name: 'HomeViewmodelBase._categorias',
    context: context,
  );

  @override
  ObservableList<CategoriaModel> get _categorias {
    _$_categoriasAtom.reportRead();
    return super._categorias;
  }

  @override
  set _categorias(ObservableList<CategoriaModel> value) {
    _$_categoriasAtom.reportWrite(value, super._categorias, () {
      super._categorias = value;
    });
  }

  late final _$_movimentacoesAtom = Atom(
    name: 'HomeViewmodelBase._movimentacoes',
    context: context,
  );

  @override
  ObservableList<MovimentacaoModel> get _movimentacoes {
    _$_movimentacoesAtom.reportRead();
    return super._movimentacoes;
  }

  @override
  set _movimentacoes(ObservableList<MovimentacaoModel> value) {
    _$_movimentacoesAtom.reportWrite(value, super._movimentacoes, () {
      super._movimentacoes = value;
    });
  }

  late final _$_shouldOpenDialogAtom = Atom(
    name: 'HomeViewmodelBase._shouldOpenDialog',
    context: context,
  );

  @override
  bool get _shouldOpenDialog {
    _$_shouldOpenDialogAtom.reportRead();
    return super._shouldOpenDialog;
  }

  @override
  set _shouldOpenDialog(bool value) {
    _$_shouldOpenDialogAtom.reportWrite(value, super._shouldOpenDialog, () {
      super._shouldOpenDialog = value;
    });
  }

  late final _$removerTransacoesRelacionadasAsyncAction = AsyncAction(
    'HomeViewmodelBase.removerTransacoesRelacionadas',
    context: context,
  );

  @override
  Future<void> removerTransacoesRelacionadas(MovimentacaoModel movimentacao) {
    return _$removerTransacoesRelacionadasAsyncAction.run(
      () => super.removerTransacoesRelacionadas(movimentacao),
    );
  }

  late final _$removerTransacoesDestaPraFrenteAsyncAction = AsyncAction(
    'HomeViewmodelBase.removerTransacoesDestaPraFrente',
    context: context,
  );

  @override
  Future<void> removerTransacoesDestaPraFrente(MovimentacaoModel movimentacao) {
    return _$removerTransacoesDestaPraFrenteAsyncAction.run(
      () => super.removerTransacoesDestaPraFrente(movimentacao),
    );
  }

  late final _$initializeServicesAsyncAction = AsyncAction(
    'HomeViewmodelBase.initializeServices',
    context: context,
  );

  @override
  Future<void> initializeServices() {
    return _$initializeServicesAsyncAction.run(
      () => super.initializeServices(),
    );
  }

  late final _$carregarSaldoAsyncAction = AsyncAction(
    'HomeViewmodelBase.carregarSaldo',
    context: context,
  );

  @override
  Future<void> carregarSaldo(DateTime mesAtual) {
    return _$carregarSaldoAsyncAction.run(() => super.carregarSaldo(mesAtual));
  }

  late final _$removerMovimentacaoAsyncAction = AsyncAction(
    'HomeViewmodelBase.removerMovimentacao',
    context: context,
  );

  @override
  Future<void> removerMovimentacao(MovimentacaoModel movimentacao) {
    return _$removerMovimentacaoAsyncAction.run(
      () => super.removerMovimentacao(movimentacao),
    );
  }

  late final _$onLogoutAsyncAction = AsyncAction(
    'HomeViewmodelBase.onLogout',
    context: context,
  );

  @override
  Future<void> onLogout() {
    return _$onLogoutAsyncAction.run(() => super.onLogout());
  }

  late final _$HomeViewmodelBaseActionController = ActionController(
    name: 'HomeViewmodelBase',
    context: context,
  );

  @override
  void setCarregou(bool value) {
    final _$actionInfo = _$HomeViewmodelBaseActionController.startAction(
      name: 'HomeViewmodelBase.setCarregou',
    );
    try {
      return super.setCarregou(value);
    } finally {
      _$HomeViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCanSeeValue(bool value) {
    final _$actionInfo = _$HomeViewmodelBaseActionController.startAction(
      name: 'HomeViewmodelBase.setCanSeeValue',
    );
    try {
      return super.setCanSeeValue(value);
    } finally {
      _$HomeViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setValor(double value) {
    final _$actionInfo = _$HomeViewmodelBaseActionController.startAction(
      name: 'HomeViewmodelBase.setValor',
    );
    try {
      return super.setValor(value);
    } finally {
      _$HomeViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setDataSelecionada(DateTime data) {
    final _$actionInfo = _$HomeViewmodelBaseActionController.startAction(
      name: 'HomeViewmodelBase.setDataSelecionada',
    );
    try {
      return super.setDataSelecionada(data);
    } finally {
      _$HomeViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCategoria(CategoriaModel? value) {
    final _$actionInfo = _$HomeViewmodelBaseActionController.startAction(
      name: 'HomeViewmodelBase.setCategoria',
    );
    try {
      return super.setCategoria(value);
    } finally {
      _$HomeViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNomeMovimentacao(String value) {
    final _$actionInfo = _$HomeViewmodelBaseActionController.startAction(
      name: 'HomeViewmodelBase.setNomeMovimentacao',
    );
    try {
      return super.setNomeMovimentacao(value);
    } finally {
      _$HomeViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setIsSaida(bool value) {
    final _$actionInfo = _$HomeViewmodelBaseActionController.startAction(
      name: 'HomeViewmodelBase.setIsSaida',
    );
    try {
      return super.setIsSaida(value);
    } finally {
      _$HomeViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSaldoAtual(double value) {
    final _$actionInfo = _$HomeViewmodelBaseActionController.startAction(
      name: 'HomeViewmodelBase.setSaldoAtual',
    );
    try {
      return super.setSaldoAtual(value);
    } finally {
      _$HomeViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void isDialogOpen(bool value) {
    final _$actionInfo = _$HomeViewmodelBaseActionController.startAction(
      name: 'HomeViewmodelBase.isDialogOpen',
    );
    try {
      return super.isDialogOpen(value);
    } finally {
      _$HomeViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCategorias(List<CategoriaModel> categorias) {
    final _$actionInfo = _$HomeViewmodelBaseActionController.startAction(
      name: 'HomeViewmodelBase.setCategorias',
    );
    try {
      return super.setCategorias(categorias);
    } finally {
      _$HomeViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addMovimentacao(MovimentacaoModel? movimentacao) {
    final _$actionInfo = _$HomeViewmodelBaseActionController.startAction(
      name: 'HomeViewmodelBase.addMovimentacao',
    );
    try {
      return super.addMovimentacao(movimentacao);
    } finally {
      _$HomeViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setMovimentacoes(List<MovimentacaoModel> movimentacoes) {
    final _$actionInfo = _$HomeViewmodelBaseActionController.startAction(
      name: 'HomeViewmodelBase.setMovimentacoes',
    );
    try {
      return super.setMovimentacoes(movimentacoes);
    } finally {
      _$HomeViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void adicionarCategoria(CategoriaModel categoria) {
    final _$actionInfo = _$HomeViewmodelBaseActionController.startAction(
      name: 'HomeViewmodelBase.adicionarCategoria',
    );
    try {
      return super.adicionarCategoria(categoria);
    } finally {
      _$HomeViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removerCategoria(CategoriaModel categoria) {
    final _$actionInfo = _$HomeViewmodelBaseActionController.startAction(
      name: 'HomeViewmodelBase.removerCategoria',
    );
    try {
      return super.removerCategoria(categoria);
    } finally {
      _$HomeViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void adicionarMovimentacao(MovimentacaoModel movimentacao) {
    final _$actionInfo = _$HomeViewmodelBaseActionController.startAction(
      name: 'HomeViewmodelBase.adicionarMovimentacao',
    );
    try {
      return super.adicionarMovimentacao(movimentacao);
    } finally {
      _$HomeViewmodelBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''

    ''';
  }
}
