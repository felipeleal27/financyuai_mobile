import 'package:mobx/mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:neo_financyuai/app/repository/orcamento_repository/orcamento_repository.dart';
import 'package:neo_financyuai/app/repository/home_repository/home_repository.dart';
import 'package:neo_financyuai/app/service/notification_service.dart';
import 'package:neo_financyuai/app/service/saldo_service.dart';
import 'package:neo_financyuai/app/service/auth_service.dart';
import 'package:neo_financyuai/app/viewmodel/settings/settings_viewmodel.dart';

part 'orcamento_viewmodel.g.dart';

class OrcamentoViewmodel = OrcamentoViewmodelBase with _$OrcamentoViewmodel;

abstract class OrcamentoViewmodelBase with Store {
  final OrcamentoRepository _repo = Modular.get<OrcamentoRepository>();
  final HomeRepository _home = Modular.get<HomeRepository>();
  final NotificationService _notifier = Modular.get<NotificationService>();
  final SaldoService _saldoService = Modular.get<SaldoService>();
  final AuthService _authService = Modular.get<AuthService>();
  final SettingsViewmodel _settings = Modular.get<SettingsViewmodel>();

  @observable
  bool loading = true;

  @observable
  double? monthlyLimit;

  @observable
  double? savingsGoal;

  @observable
  ObservableMap<String, double> categoryCaps = ObservableMap.of({});

  @observable
  double totalSpentThisMonth = 0.0;

  @observable
  double totalIncomeThisMonth = 0.0;

  @observable
  double savedSoFar = 0.0; // income - expenses

  @observable
  double saldoAtual = 0.0;

  @observable
  ObservableMap<String, double> spentByCategory = ObservableMap.of({});

  @observable
  List<double> thresholds = const [0.7, 0.9, 1.0];

  @observable
  bool limitEnabled = false;

  @observable
  double lastBandNotified = 0.0;

  @computed
  double get limitProgress => (monthlyLimit == null || monthlyLimit == 0) ? 0.0 : (totalSpentThisMonth / monthlyLimit!).clamp(0.0, 1.2);

  @computed
  double get savingsProgress => (savingsGoal == null || savingsGoal == 0) ? 0.0 : (savedSoFar / savingsGoal!).clamp(0.0, 1.2);

  /// 0 = green, 1 = yellow, 2 = red
  @computed
  int get indicatorColorCode {
    final ratio = limitProgress;
    if (ratio >= 1.0) return 2;
    if (ratio >= 0.9) return 1;
    if (ratio >= 0.7) return 1;
    return 0;
  }

  @action
  Future<void> load() async {
    loading = true;
    try {
      await _settings.load();
      monthlyLimit = await _repo.getMonthlyLimit();
      savingsGoal = await _repo.getSavingsGoal();
      categoryCaps = ObservableMap.of(await _repo.getCategoryCaps());
      thresholds = await _repo.getAlertThresholds();
      limitEnabled = await _repo.getLimitEnabled();
      lastBandNotified = await _repo.getLastBandNotified();

      // compute from repository
      final now = DateTime.now();
      final list = await _home.getMovimentacoes(now.month, now.year);
      double spent = 0.0, income = 0.0;
      final catAgg = <int, double>{};
      for (final t in list) {
        if (t.isSaida) {
          spent += t.valor.abs();
          catAgg.update(t.idCategoria, (v) => v + t.valor.abs(), ifAbsent: () => t.valor.abs());
        } else {
          income += t.valor.abs();
        }
      }
      totalSpentThisMonth = spent;
      totalIncomeThisMonth = income;
      savedSoFar = (income - spent).clamp(0.0, double.infinity);
  saldoAtual = await _saldoService.getSaldoAtual();

      // Map categories names lazily
      final cats = await _home.getCategorias();
      final names = {for (final c in cats) c.id: c.nome};
      spentByCategory = ObservableMap.of({
        for (final e in catAgg.entries) (names[e.key] ?? 'Categoria ${e.key}'): e.value
      });

      // Check thresholds and notify only if enabled and crossing bands
  if (_settings.notificationsEnabled && limitEnabled && monthlyLimit != null && monthlyLimit! > 0) {
        final ratio = totalSpentThisMonth / monthlyLimit!;
        final currentBand = ratio >= 1.0 ? 1.0 : (ratio >= 0.9 ? 0.9 : (ratio >= 0.7 ? 0.7 : 0.0));
        if (currentBand > lastBandNotified) {
          final pct = (currentBand * 100).toStringAsFixed(0);
          await _notifier.sendSimpleNotification(
            title: currentBand >= 1.0 ? '🚨 Limite mensal ultrapassado' : 'Atenção com seu orçamento',
            body: currentBand >= 1.0
                ? 'Você ultrapassou seu limite mensal de gastos.'
                : 'Você atingiu $pct% do seu limite mensal.',
          );
          lastBandNotified = currentBand;
          await _repo.setLastBandNotified(currentBand);
        }
      }

      // Background-friendly sync to Firestore
      final uid = _authService.userId;
      if (uid != null) {
        // fire-and-forget; Firestore offline will queue if needed
        // ignore: unawaited_futures
        _repo.syncToCloud(userId: uid);
      }
    } catch (e) {
      // ignore detailed log here
    } finally {
      loading = false;
    }
  }

  @action
  Future<void> saveMonthlyLimit(double? value) async {
    monthlyLimit = value;
    await _repo.setMonthlyLimit(value);
    // reset band when user changes limit
    lastBandNotified = 0.0;
    await _repo.setLastBandNotified(0.0);
  }

  @action
  Future<void> saveSavingsGoal(double? value) async {
    savingsGoal = value;
    await _repo.setSavingsGoal(value);
  }

  @action
  Future<void> saveCategoryCap(String category, double? value) async {
    if (value == null) {
      categoryCaps.remove(category);
    } else {
      categoryCaps[category] = value;
    }
    await _repo.setCategoryCaps(Map.from(categoryCaps));
  }

  @action
  Future<void> saveThresholds(List<double> values) async {
    thresholds = values;
    await _repo.setAlertThresholds(values);
  }

  @action
  Future<void> setLimitEnabled(bool enabled) async {
    limitEnabled = enabled;
    await _repo.setLimitEnabled(enabled);
  }
}
