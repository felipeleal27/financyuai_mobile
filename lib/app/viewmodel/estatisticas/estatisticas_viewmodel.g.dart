// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'estatisticas_viewmodel.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$EstatisticasViewmodel on EstatisticasViewmodelBase, Store {
  late final _$loadingAtom = Atom(
    name: 'EstatisticasViewmodelBase.loading',
    context: context,
  );

  @override
  bool get loading {
    _$loadingAtom.reportRead();
    return super.loading;
  }

  @override
  set loading(bool value) {
    _$loadingAtom.reportWrite(value, super.loading, () {
      super.loading = value;
    });
  }

  late final _$saldoPrevistoFimMesAtom = Atom(
    name: 'EstatisticasViewmodelBase.saldoPrevistoFimMes',
    context: context,
  );

  @override
  double? get saldoPrevistoFimMes {
    _$saldoPrevistoFimMesAtom.reportRead();
    return super.saldoPrevistoFimMes;
  }

  @override
  set saldoPrevistoFimMes(double? value) {
    _$saldoPrevistoFimMesAtom.reportWrite(value, super.saldoPrevistoFimMes, () {
      super.saldoPrevistoFimMes = value;
    });
  }

  late final _$variacaoPorCategoriaAtom = Atom(
    name: 'EstatisticasViewmodelBase.variacaoPorCategoria',
    context: context,
  );

  @override
  Map<String, double> get variacaoPorCategoria {
    _$variacaoPorCategoriaAtom.reportRead();
    return super.variacaoPorCategoria;
  }

  @override
  set variacaoPorCategoria(Map<String, double> value) {
    _$variacaoPorCategoriaAtom.reportWrite(
      value,
      super.variacaoPorCategoria,
      () {
        super.variacaoPorCategoria = value;
      },
    );
  }

  late final _$composicaoAtualCategoriasAtom = Atom(
    name: 'EstatisticasViewmodelBase.composicaoAtualCategorias',
    context: context,
  );

  @override
  Map<String, double> get composicaoAtualCategorias {
    _$composicaoAtualCategoriasAtom.reportRead();
    return super.composicaoAtualCategorias;
  }

  @override
  set composicaoAtualCategorias(Map<String, double> value) {
    _$composicaoAtualCategoriasAtom.reportWrite(
      value,
      super.composicaoAtualCategorias,
      () {
        super.composicaoAtualCategorias = value;
      },
    );
  }

  late final _$topDespesasAtom = Atom(
    name: 'EstatisticasViewmodelBase.topDespesas',
    context: context,
  );

  @override
  ObservableList<Map<String, dynamic>> get topDespesas {
    _$topDespesasAtom.reportRead();
    return super.topDespesas;
  }

  @override
  set topDespesas(ObservableList<Map<String, dynamic>> value) {
    _$topDespesasAtom.reportWrite(value, super.topDespesas, () {
      super.topDespesas = value;
    });
  }

  late final _$recorrentesAtom = Atom(
    name: 'EstatisticasViewmodelBase.recorrentes',
    context: context,
  );

  @override
  ObservableList<Map<String, dynamic>> get recorrentes {
    _$recorrentesAtom.reportRead();
    return super.recorrentes;
  }

  @override
  set recorrentes(ObservableList<Map<String, dynamic>> value) {
    _$recorrentesAtom.reportWrite(value, super.recorrentes, () {
      super.recorrentes = value;
    });
  }

  late final _$totalReceitasMesAtom = Atom(
    name: 'EstatisticasViewmodelBase.totalReceitasMes',
    context: context,
  );

  @override
  double get totalReceitasMes {
    _$totalReceitasMesAtom.reportRead();
    return super.totalReceitasMes;
  }

  @override
  set totalReceitasMes(double value) {
    _$totalReceitasMesAtom.reportWrite(value, super.totalReceitasMes, () {
      super.totalReceitasMes = value;
    });
  }

  late final _$totalDespesasMesAtom = Atom(
    name: 'EstatisticasViewmodelBase.totalDespesasMes',
    context: context,
  );

  @override
  double get totalDespesasMes {
    _$totalDespesasMesAtom.reportRead();
    return super.totalDespesasMes;
  }

  @override
  set totalDespesasMes(double value) {
    _$totalDespesasMesAtom.reportWrite(value, super.totalDespesasMes, () {
      super.totalDespesasMes = value;
    });
  }

  late final _$saldoDoMesAtom = Atom(
    name: 'EstatisticasViewmodelBase.saldoDoMes',
    context: context,
  );

  @override
  double get saldoDoMes {
    _$saldoDoMesAtom.reportRead();
    return super.saldoDoMes;
  }

  @override
  set saldoDoMes(double value) {
    _$saldoDoMesAtom.reportWrite(value, super.saldoDoMes, () {
      super.saldoDoMes = value;
    });
  }

  late final _$ultimos6MesesAtom = Atom(
    name: 'EstatisticasViewmodelBase.ultimos6Meses',
    context: context,
  );

  @override
  ObservableList<MonthAgg> get ultimos6Meses {
    _$ultimos6MesesAtom.reportRead();
    return super.ultimos6Meses;
  }

  @override
  set ultimos6Meses(ObservableList<MonthAgg> value) {
    _$ultimos6MesesAtom.reportWrite(value, super.ultimos6Meses, () {
      super.ultimos6Meses = value;
    });
  }

  late final _$topCategoriasAtom = Atom(
    name: 'EstatisticasViewmodelBase.topCategorias',
    context: context,
  );

  @override
  ObservableList<MapEntry<String, double>> get topCategorias {
    _$topCategoriasAtom.reportRead();
    return super.topCategorias;
  }

  @override
  set topCategorias(ObservableList<MapEntry<String, double>> value) {
    _$topCategoriasAtom.reportWrite(value, super.topCategorias, () {
      super.topCategorias = value;
    });
  }

  late final _$momDespesaPercAtom = Atom(
    name: 'EstatisticasViewmodelBase.momDespesaPerc',
    context: context,
  );

  @override
  double? get momDespesaPerc {
    _$momDespesaPercAtom.reportRead();
    return super.momDespesaPerc;
  }

  @override
  set momDespesaPerc(double? value) {
    _$momDespesaPercAtom.reportWrite(value, super.momDespesaPerc, () {
      super.momDespesaPerc = value;
    });
  }

  late final _$momReceitaPercAtom = Atom(
    name: 'EstatisticasViewmodelBase.momReceitaPerc',
    context: context,
  );

  @override
  double? get momReceitaPerc {
    _$momReceitaPercAtom.reportRead();
    return super.momReceitaPerc;
  }

  @override
  set momReceitaPerc(double? value) {
    _$momReceitaPercAtom.reportWrite(value, super.momReceitaPerc, () {
      super.momReceitaPerc = value;
    });
  }

  late final _$alertasAtom = Atom(
    name: 'EstatisticasViewmodelBase.alertas',
    context: context,
  );

  @override
  ObservableList<Map<String, dynamic>> get alertas {
    _$alertasAtom.reportRead();
    return super.alertas;
  }

  @override
  set alertas(ObservableList<Map<String, dynamic>> value) {
    _$alertasAtom.reportWrite(value, super.alertas, () {
      super.alertas = value;
    });
  }

  late final _$loadAsyncAction = AsyncAction(
    'EstatisticasViewmodelBase.load',
    context: context,
  );

  @override
  Future<void> load() {
    return _$loadAsyncAction.run(() => super.load());
  }

  @override
  String toString() {
    return '''
loading: ${loading},
saldoPrevistoFimMes: ${saldoPrevistoFimMes},
variacaoPorCategoria: ${variacaoPorCategoria},
composicaoAtualCategorias: ${composicaoAtualCategorias},
topDespesas: ${topDespesas},
recorrentes: ${recorrentes},
totalReceitasMes: ${totalReceitasMes},
totalDespesasMes: ${totalDespesasMes},
saldoDoMes: ${saldoDoMes},
ultimos6Meses: ${ultimos6Meses},
topCategorias: ${topCategorias},
momDespesaPerc: ${momDespesaPerc},
momReceitaPerc: ${momReceitaPerc},
alertas: ${alertas}
    ''';
  }
}
