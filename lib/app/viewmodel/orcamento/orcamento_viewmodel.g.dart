// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orcamento_viewmodel.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$OrcamentoViewmodel on OrcamentoViewmodelBase, Store {
  Computed<double>? _$limitProgressComputed;

  @override
  double get limitProgress =>
      (_$limitProgressComputed ??= Computed<double>(
            () => super.limitProgress,
            name: 'OrcamentoViewmodelBase.limitProgress',
          ))
          .value;
  Computed<double>? _$savingsProgressComputed;

  @override
  double get savingsProgress =>
      (_$savingsProgressComputed ??= Computed<double>(
            () => super.savingsProgress,
            name: 'OrcamentoViewmodelBase.savingsProgress',
          ))
          .value;
  Computed<int>? _$indicatorColorCodeComputed;

  @override
  int get indicatorColorCode =>
      (_$indicatorColorCodeComputed ??= Computed<int>(
            () => super.indicatorColorCode,
            name: 'OrcamentoViewmodelBase.indicatorColorCode',
          ))
          .value;

  late final _$loadingAtom = Atom(
    name: 'OrcamentoViewmodelBase.loading',
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

  late final _$monthlyLimitAtom = Atom(
    name: 'OrcamentoViewmodelBase.monthlyLimit',
    context: context,
  );

  @override
  double? get monthlyLimit {
    _$monthlyLimitAtom.reportRead();
    return super.monthlyLimit;
  }

  @override
  set monthlyLimit(double? value) {
    _$monthlyLimitAtom.reportWrite(value, super.monthlyLimit, () {
      super.monthlyLimit = value;
    });
  }

  late final _$savingsGoalAtom = Atom(
    name: 'OrcamentoViewmodelBase.savingsGoal',
    context: context,
  );

  @override
  double? get savingsGoal {
    _$savingsGoalAtom.reportRead();
    return super.savingsGoal;
  }

  @override
  set savingsGoal(double? value) {
    _$savingsGoalAtom.reportWrite(value, super.savingsGoal, () {
      super.savingsGoal = value;
    });
  }

  late final _$categoryCapsAtom = Atom(
    name: 'OrcamentoViewmodelBase.categoryCaps',
    context: context,
  );

  @override
  ObservableMap<String, double> get categoryCaps {
    _$categoryCapsAtom.reportRead();
    return super.categoryCaps;
  }

  @override
  set categoryCaps(ObservableMap<String, double> value) {
    _$categoryCapsAtom.reportWrite(value, super.categoryCaps, () {
      super.categoryCaps = value;
    });
  }

  late final _$totalSpentThisMonthAtom = Atom(
    name: 'OrcamentoViewmodelBase.totalSpentThisMonth',
    context: context,
  );

  @override
  double get totalSpentThisMonth {
    _$totalSpentThisMonthAtom.reportRead();
    return super.totalSpentThisMonth;
  }

  @override
  set totalSpentThisMonth(double value) {
    _$totalSpentThisMonthAtom.reportWrite(value, super.totalSpentThisMonth, () {
      super.totalSpentThisMonth = value;
    });
  }

  late final _$totalIncomeThisMonthAtom = Atom(
    name: 'OrcamentoViewmodelBase.totalIncomeThisMonth',
    context: context,
  );

  @override
  double get totalIncomeThisMonth {
    _$totalIncomeThisMonthAtom.reportRead();
    return super.totalIncomeThisMonth;
  }

  @override
  set totalIncomeThisMonth(double value) {
    _$totalIncomeThisMonthAtom.reportWrite(
      value,
      super.totalIncomeThisMonth,
      () {
        super.totalIncomeThisMonth = value;
      },
    );
  }

  late final _$savedSoFarAtom = Atom(
    name: 'OrcamentoViewmodelBase.savedSoFar',
    context: context,
  );

  @override
  double get savedSoFar {
    _$savedSoFarAtom.reportRead();
    return super.savedSoFar;
  }

  @override
  set savedSoFar(double value) {
    _$savedSoFarAtom.reportWrite(value, super.savedSoFar, () {
      super.savedSoFar = value;
    });
  }

  late final _$saldoAtualAtom = Atom(
    name: 'OrcamentoViewmodelBase.saldoAtual',
    context: context,
  );

  @override
  double get saldoAtual {
    _$saldoAtualAtom.reportRead();
    return super.saldoAtual;
  }

  @override
  set saldoAtual(double value) {
    _$saldoAtualAtom.reportWrite(value, super.saldoAtual, () {
      super.saldoAtual = value;
    });
  }

  late final _$spentByCategoryAtom = Atom(
    name: 'OrcamentoViewmodelBase.spentByCategory',
    context: context,
  );

  @override
  ObservableMap<String, double> get spentByCategory {
    _$spentByCategoryAtom.reportRead();
    return super.spentByCategory;
  }

  @override
  set spentByCategory(ObservableMap<String, double> value) {
    _$spentByCategoryAtom.reportWrite(value, super.spentByCategory, () {
      super.spentByCategory = value;
    });
  }

  late final _$thresholdsAtom = Atom(
    name: 'OrcamentoViewmodelBase.thresholds',
    context: context,
  );

  @override
  List<double> get thresholds {
    _$thresholdsAtom.reportRead();
    return super.thresholds;
  }

  @override
  set thresholds(List<double> value) {
    _$thresholdsAtom.reportWrite(value, super.thresholds, () {
      super.thresholds = value;
    });
  }

  late final _$limitEnabledAtom = Atom(
    name: 'OrcamentoViewmodelBase.limitEnabled',
    context: context,
  );

  @override
  bool get limitEnabled {
    _$limitEnabledAtom.reportRead();
    return super.limitEnabled;
  }

  @override
  set limitEnabled(bool value) {
    _$limitEnabledAtom.reportWrite(value, super.limitEnabled, () {
      super.limitEnabled = value;
    });
  }

  late final _$lastBandNotifiedAtom = Atom(
    name: 'OrcamentoViewmodelBase.lastBandNotified',
    context: context,
  );

  @override
  double get lastBandNotified {
    _$lastBandNotifiedAtom.reportRead();
    return super.lastBandNotified;
  }

  @override
  set lastBandNotified(double value) {
    _$lastBandNotifiedAtom.reportWrite(value, super.lastBandNotified, () {
      super.lastBandNotified = value;
    });
  }

  late final _$loadAsyncAction = AsyncAction(
    'OrcamentoViewmodelBase.load',
    context: context,
  );

  @override
  Future<void> load() {
    return _$loadAsyncAction.run(() => super.load());
  }

  late final _$saveMonthlyLimitAsyncAction = AsyncAction(
    'OrcamentoViewmodelBase.saveMonthlyLimit',
    context: context,
  );

  @override
  Future<void> saveMonthlyLimit(double? value) {
    return _$saveMonthlyLimitAsyncAction.run(
      () => super.saveMonthlyLimit(value),
    );
  }

  late final _$saveSavingsGoalAsyncAction = AsyncAction(
    'OrcamentoViewmodelBase.saveSavingsGoal',
    context: context,
  );

  @override
  Future<void> saveSavingsGoal(double? value) {
    return _$saveSavingsGoalAsyncAction.run(() => super.saveSavingsGoal(value));
  }

  late final _$saveCategoryCapAsyncAction = AsyncAction(
    'OrcamentoViewmodelBase.saveCategoryCap',
    context: context,
  );

  @override
  Future<void> saveCategoryCap(String category, double? value) {
    return _$saveCategoryCapAsyncAction.run(
      () => super.saveCategoryCap(category, value),
    );
  }

  late final _$saveThresholdsAsyncAction = AsyncAction(
    'OrcamentoViewmodelBase.saveThresholds',
    context: context,
  );

  @override
  Future<void> saveThresholds(List<double> values) {
    return _$saveThresholdsAsyncAction.run(() => super.saveThresholds(values));
  }

  late final _$setLimitEnabledAsyncAction = AsyncAction(
    'OrcamentoViewmodelBase.setLimitEnabled',
    context: context,
  );

  @override
  Future<void> setLimitEnabled(bool enabled) {
    return _$setLimitEnabledAsyncAction.run(
      () => super.setLimitEnabled(enabled),
    );
  }

  @override
  String toString() {
    return '''
loading: ${loading},
monthlyLimit: ${monthlyLimit},
savingsGoal: ${savingsGoal},
categoryCaps: ${categoryCaps},
totalSpentThisMonth: ${totalSpentThisMonth},
totalIncomeThisMonth: ${totalIncomeThisMonth},
savedSoFar: ${savedSoFar},
saldoAtual: ${saldoAtual},
spentByCategory: ${spentByCategory},
thresholds: ${thresholds},
limitEnabled: ${limitEnabled},
lastBandNotified: ${lastBandNotified},
limitProgress: ${limitProgress},
savingsProgress: ${savingsProgress},
indicatorColorCode: ${indicatorColorCode}
    ''';
  }
}
