import 'package:mobx/mobx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:neo_financyuai/app/repository/home_repository/home_repository.dart';
import 'package:neo_financyuai/app/service/auth_service.dart';
import 'package:neo_financyuai/app/service/saldo_service.dart';

part 'estatisticas_viewmodel.g.dart';

class EstatisticasViewmodel = EstatisticasViewmodelBase with _$EstatisticasViewmodel;

class MonthAgg {
  final String label;
  final double receita;
  final double despesa;
  const MonthAgg({required this.label, required this.receita, required this.despesa});
}

abstract class EstatisticasViewmodelBase with Store {
  final HomeRepository _repo = Modular.get<HomeRepository>();
  final AuthService _auth = Modular.get<AuthService>();
  final SaldoService _saldoService = Modular.get<SaldoService>();

  @observable
  bool loading = true;

  @observable
  double? saldoPrevistoFimMes;

  @observable
  Map<String, double> variacaoPorCategoria = {};

  @observable
  Map<String, double> composicaoAtualCategorias = {};

  @observable
  ObservableList<Map<String, dynamic>> topDespesas = ObservableList.of([]);

  @observable
  ObservableList<Map<String, dynamic>> recorrentes = ObservableList.of([]);

  // Novos dados
  @observable
  double totalReceitasMes = 0.0;

  @observable
  double totalDespesasMes = 0.0;

  @observable
  double saldoDoMes = 0.0;

  @observable
  ObservableList<MonthAgg> ultimos6Meses = ObservableList.of([]);

  @observable
  ObservableList<MapEntry<String, double>> topCategorias = ObservableList.of([]);

  @observable
  double? momDespesaPerc;

  @observable
  double? momReceitaPerc;

  @observable
  ObservableList<Map<String, dynamic>> alertas = ObservableList.of([]);

  @action
  Future<void> load() async {
    loading = true;
    try {
      final now = DateTime.now();
      final uid = _auth.userId;
      if (uid == null) {
        saldoPrevistoFimMes = null;
        variacaoPorCategoria = {};
        composicaoAtualCategorias = {};
        topDespesas = ObservableList.of([]);
        recorrentes = ObservableList.of([]);
        totalReceitasMes = 0.0;
        totalDespesasMes = 0.0;
        saldoDoMes = 0.0;
        ultimos6Meses = ObservableList.of([]);
        topCategorias = ObservableList.of([]);
        momDespesaPerc = null;
        momReceitaPerc = null;
        alertas = ObservableList.of([]);
        return;
      }

      final categorias = await _repo.getCategorias();
      final catNomes = {for (final c in categorias) c.id: c.nome};

      final saldoAtual = await _saldoService.getSaldoAtual();

      final atual = await _repo.getMovimentacoes(now.month, now.year);
      final prev1Date = DateTime(now.year, now.month - 1, 1);
      final prev2Date = DateTime(now.year, now.month - 2, 1);
      final prev3Date = DateTime(now.year, now.month - 3, 1);
      final prev1 = await _repo.getMovimentacoes(prev1Date.month, prev1Date.year);
      final prev2 = await _repo.getMovimentacoes(prev2Date.month, prev2Date.year);
      final prev3 = await _repo.getMovimentacoes(prev3Date.month, prev3Date.year);

      Map<int, double> somaPorCategoria(List lista, {bool apenasSaida = true}) {
        final map = <int, double>{};
        for (final t in lista) {
          if (apenasSaida && !t.isSaida) continue;
          final catId = t.idCategoria;
          final valorAbs = t.valor.abs();
          map.update(catId, (v) => v + valorAbs, ifAbsent: () => valorAbs);
        }
        return map;
      }

      double receitas = 0.0;
      double despesas = 0.0;
      for (final t in atual) {
        if (t.isSaida) {
          despesas += t.valor.abs();
        } else {
          receitas += t.valor.abs();
        }
      }
      final saldoMes = receitas - despesas;

      final atualMap = somaPorCategoria(atual);
      final composicaoAtual = {
        for (final e in atualMap.entries) (catNomes[e.key] ?? 'Categoria ${e.key}'): e.value,
      };

      final mediaAnteriorPorCategoria = <int, double>{};
      for (final lista in [prev1, prev2, prev3]) {
        final m = somaPorCategoria(lista);
        for (final e in m.entries) {
          mediaAnteriorPorCategoria.update(e.key, (v) => v + e.value, ifAbsent: () => e.value);
        }
      }
      for (final k in mediaAnteriorPorCategoria.keys.toList()) {
        mediaAnteriorPorCategoria[k] = mediaAnteriorPorCategoria[k]! / 3.0;
      }

      final variacao = <String, double>{};
      for (final e in atualMap.entries) {
        final media = mediaAnteriorPorCategoria[e.key] ?? 0.0;
        final deltaPerc = media == 0 ? 100.0 : ((e.value - media) / media * 100.0);
        final nome = catNomes[e.key] ?? 'Categoria ${e.key}';
        variacao[nome] = double.parse(deltaPerc.toStringAsFixed(1));
      }

      final despesasList = atual.where((t) => t.isSaida).toList()
        ..sort((a, b) => b.valor.abs().compareTo(a.valor.abs()));
      final topDespesasCalc = despesasList.take(5).map((t) => {
            'nome': t.nome,
            'valor': t.valor.abs(),
            'dia': t.dataMovimentacao.day,
          }).toList();

      final byName = <String, List<DateTime>>{};
      for (final t in [...prev3, ...prev2, ...prev1, ...atual]) {
        if (!t.isSaida) continue;
        final key = t.nome.toLowerCase().trim();
        byName.putIfAbsent(key, () => []).add(t.dataMovimentacao);
      }
      final recorrentesCalc = <Map<String, dynamic>>[];
      for (final e in byName.entries) {
        if (e.value.length >= 3) {
          final counts = <int, int>{};
          for (final d in e.value) {
            counts.update(d.day, (v) => v + 1, ifAbsent: () => 1);
          }
          final diaTipico = counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
          recorrentesCalc.add({'nome': e.key, 'dia': diaTipico});
        }
      }

      const monthNamesShort = ['Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'];
      Future<MonthAgg> aggFor(DateTime ref, [List? cached]) async {
        final list = cached ?? await _repo.getMovimentacoes(ref.month, ref.year);
        double rec = 0.0;
        double desp = 0.0;
        for (final t in list) {
          if (t.isSaida) {
            desp += t.valor.abs();
          } else {
            rec += t.valor.abs();
          }
        }
        return MonthAgg(label: monthNamesShort[ref.month - 1], receita: rec, despesa: desp);
      }

      final prev4Date = DateTime(now.year, now.month - 4, 1);
      final prev5Date = DateTime(now.year, now.month - 5, 1);
      final aggAtual = await aggFor(now, atual);
      final aggPrev1 = await aggFor(prev1Date, prev1);
      final aggPrev2 = await aggFor(prev2Date, prev2);
      final aggPrev3 = await aggFor(prev3Date, prev3);
      final aggPrev4 = await aggFor(prev4Date);
      final aggPrev5 = await aggFor(prev5Date);
      final ultimos6 = [aggPrev5, aggPrev4, aggPrev3, aggPrev2, aggPrev1, aggAtual];

      double? momDesp;
      if (aggPrev1.despesa > 0) {
        momDesp = ((aggAtual.despesa - aggPrev1.despesa) / aggPrev1.despesa) * 100.0;
      }
      double? momRec;
      if (aggPrev1.receita > 0) {
        momRec = ((aggAtual.receita - aggPrev1.receita) / aggPrev1.receita) * 100.0;
      }

      final alertasCalc = <Map<String, dynamic>>[];
      composicaoAtual.forEach((nome, valorAtual) {
        final idCat = catNomes.entries.firstWhere(
          (e) => e.value == nome,
          orElse: () => const MapEntry(-1, ''),
        ).key;
        final media = idCat == -1 ? 0.0 : (mediaAnteriorPorCategoria[idCat] ?? 0.0);
        if (media > 0) {
          final deltaPerc = ((valorAtual - media) / media) * 100.0;
          if (deltaPerc > 30.0 && valorAtual > 100.0) {
            alertasCalc.add({
              'categoria': nome,
              'aumento': double.parse(deltaPerc.toStringAsFixed(1)),
              'valor': valorAtual,
            });
          }
        }
      });

      // Top categorias (despesas)
      final topCategoriasCalc = composicaoAtual.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Commit state
      saldoPrevistoFimMes = saldoAtual;
      composicaoAtualCategorias = composicaoAtual;
      variacaoPorCategoria = variacao;
      topDespesas = ObservableList.of(topDespesasCalc);
      recorrentes = ObservableList.of(recorrentesCalc);
      totalReceitasMes = receitas;
      totalDespesasMes = despesas;
      saldoDoMes = saldoMes;
      ultimos6Meses = ObservableList.of(ultimos6);
      topCategorias = ObservableList.of(topCategoriasCalc.take(5).toList());
      momDespesaPerc = momDesp == null ? null : double.parse(momDesp.toStringAsFixed(1));
      momReceitaPerc = momRec == null ? null : double.parse(momRec.toStringAsFixed(1));
      alertas = ObservableList.of(alertasCalc);
    } catch (e) {
      if (kDebugMode) debugPrint('Erro ao carregar estatísticas: $e');
    } finally {
      loading = false;
    }
  }
}
