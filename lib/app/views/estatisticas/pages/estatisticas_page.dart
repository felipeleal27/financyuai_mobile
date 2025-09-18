import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';
import 'package:neo_financyuai/app/repository/home_repository/home_repository.dart';
import 'package:neo_financyuai/app/service/auth_service.dart';
import 'package:neo_financyuai/app/service/saldo_service.dart';
import 'package:neo_financyuai/app/utils/app_theme_helper.dart';
import 'package:neo_financyuai/app/widgets/bottom_navigation_bat.dart';
import 'package:neo_financyuai/app/views/home/module/home_nome_rotas.dart';
import 'package:neo_financyuai/app/viewmodel/home/home_viewmodel.dart';

class EstatisticasPage extends StatefulWidget {
  const EstatisticasPage({super.key});

  @override
  State<EstatisticasPage> createState() => _EstatisticasPageState();
}

class _EstatisticasPageState extends State<EstatisticasPage> {
  final _saldoService = Modular.get<SaldoService>();
  final _repo = Modular.get<HomeRepository>();
  final _auth = Modular.get<AuthService>();

  bool _loading = true;
  double? _saldoPrevistoFimMes;
  Map<String, double> _variacaoPorCategoria = {};
  Map<String, double> _composicaoAtualCategorias = {};
  // Mapeamento de nomes é local ao carregamento; não precisamos manter no estado
  List<Map<String, dynamic>> _topDespesas = [];
  List<Map<String, dynamic>> _recorrentes = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final now = DateTime.now();
      final uid = _auth.userId;
      if (uid == null) {
        setState(() {
          _loading = false;
          _saldoPrevistoFimMes = null;
          _variacaoPorCategoria = {};
          _composicaoAtualCategorias = {};
          _topDespesas = [];
          _recorrentes = [];
        });
        return;
      }

      // Categorias para mapear id -> nome
      final categorias = await _repo.getCategorias();
      final catNomes = {for (final c in categorias) c.id: c.nome};

      // Saldo previsto (MVP usa saldo atual)
      final saldoAtual = await _saldoService.getSaldoAtual();

      // Movimentações: mês atual e três anteriores
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

      // Top 5 despesas do mês
      final despesas = atual.where((t) => t.isSaida).toList()
        ..sort((a, b) => b.valor.abs().compareTo(a.valor.abs()));
      final topDespesas = despesas.take(5).map((t) => {
            'nome': t.nome,
            'valor': t.valor.abs(),
            'dia': t.dataMovimentacao.day,
          }).toList();

      // Recorrentes heurística: nomes repetidos em >=3 meses, dia típico (moda)
      final byName = <String, List<DateTime>>{};
      for (final t in [...prev3, ...prev2, ...prev1, ...atual]) {
        if (!t.isSaida) continue;
        final key = t.nome.toLowerCase().trim();
        byName.putIfAbsent(key, () => []).add(t.dataMovimentacao);
      }
      final recorrentes = <Map<String, dynamic>>[];
      for (final e in byName.entries) {
        if (e.value.length >= 3) {
          final counts = <int, int>{};
          for (final d in e.value) {
            counts.update(d.day, (v) => v + 1, ifAbsent: () => 1);
          }
          final diaTipico = counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
          recorrentes.add({'nome': e.key, 'dia': diaTipico});
        }
      }

      if (!mounted) return;
      setState(() {
        _saldoPrevistoFimMes = saldoAtual;
        _composicaoAtualCategorias = composicaoAtual;
        _variacaoPorCategoria = variacao;
        _topDespesas = topDespesas;
        _recorrentes = recorrentes;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final helper = AppThemeHelper.of(context);
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return Scaffold(
      backgroundColor: helper.surfaceColor,
      appBar: AppBar(
        backgroundColor: helper.surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'Estatísticas',
          style: TextStyle(
            color: helper.onSurfaceColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: helper.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: helper.colorScheme.primary,
              size: 16,
            ),
          ),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Modular.to.navigate(HomeNomeRotas.navigate);
            }
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _periodChip(helper),
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _card(
                    context,
                    title: 'Saldo previsto (MVP)',
                    icon: Icons.trending_up,
                    child: Text(
                      _saldoPrevistoFimMes == null ? '—' : currency.format(_saldoPrevistoFimMes),
                      style: TextStyle(
                        color: helper.onSurfaceColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _card(
                    context,
                    title: 'Composição do mês por categoria',
                    icon: Icons.pie_chart_outline,
                    child: _buildDonutChart(context),
                  ),
                  const SizedBox(height: 12),
                  _card(
                    context,
                    title: 'Variação vs. média 3 meses (por categoria)',
                    icon: Icons.analytics_outlined,
                    child: Column(
                      children: _variacaoPorCategoria.entries.map((e) {
                        final inc = e.value >= 0;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  e.key,
                                  style: TextStyle(
                                    color: helper.onSurfaceColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (inc ? helper.despesaIconColor : helper.receitaIconColor).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      inc ? Icons.north_east : Icons.south_east,
                                      size: 14,
                                      color: inc ? helper.despesaValueColor : helper.receitaValueColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${inc ? '+' : ''}${e.value.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        color: inc ? helper.despesaValueColor : helper.receitaValueColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _card(
                    context,
                    title: 'Top 5 despesas do mês',
                    icon: Icons.receipt_long_outlined,
                    child: Column(
                      children: _topDespesas.map((t) {
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 14,
                            backgroundColor: helper.despesaIconColor.withOpacity(0.15),
                            child: Icon(Icons.trending_down, size: 16, color: helper.despesaValueColor),
                          ),
                          title: Text(
                            '${t['nome']}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text('Dia ${t['dia']}'),
                          trailing: Text(
                            currency.format(t['valor']),
                            style: TextStyle(
                              color: helper.despesaValueColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _card(
                    context,
                    title: 'Possíveis recorrentes (heurística)',
                    icon: Icons.autorenew_outlined,
                    child: Column(
                      children: _recorrentes.map((r) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${r['nome']}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: helper.onSurfaceColor),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: helper.colorScheme.primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'Dia típico: ${r['dia']}',
                                  style: TextStyle(
                                    color: helper.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: SizedBox(
        width: 64,
        height: 64,
        child: FloatingActionButton(
          onPressed: _navigateToHomeAndOpenModal,
          backgroundColor: helper.colorScheme.primary,
          foregroundColor: helper.colorScheme.onPrimary,
          elevation: helper.brightness == Brightness.light ? 6 : 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          child: const Icon(Icons.add, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 1),
    );
  }

  void _navigateToHomeAndOpenModal() {
    debugPrint('Estatísticas: Iniciando navegação para Home com modal...');
    Modular.to.navigate(HomeNomeRotas.navigate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        try {
          final homeVm = Modular.get<HomeViewmodel>();
          homeVm.isDialogOpen(true);
        } catch (e) {
          debugPrint('Estatísticas: Erro ao abrir modal na Home: $e');
        }
      });
    });
  }

  Widget _card(
    BuildContext context, {
    required String title,
    IconData? icon,
    String? subtitle,
    required Widget child,
  }) {
    final helper = AppThemeHelper.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: helper.theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: helper.dividerColor),
        boxShadow: helper.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: helper.onSurfaceColor.withOpacity(0.8)),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: helper.onSurfaceColor,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: helper.onSurfaceColor.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _periodChip(AppThemeHelper helper) {
    final now = DateTime.now();
    final monthNames = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    final label = '${monthNames[now.month - 1]} ${now.year}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: helper.colorScheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: helper.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDonutChart(BuildContext context) {
    final helper = AppThemeHelper.of(context);
    if (_composicaoAtualCategorias.isEmpty) {
      return Text(
        'Sem dados de despesas no mês',
        style: TextStyle(color: helper.onSurfaceColor.withOpacity(0.7)),
      );
    }
    final total = _composicaoAtualCategorias.values
        .fold<double>(0.0, (a, b) => a + b);
    if (total <= 0) {
      return Text(
        'Sem dados de despesas no mês',
        style: TextStyle(color: helper.onSurfaceColor.withOpacity(0.7)),
      );
    }

    final colors = [
      helper.colorScheme.primary,
      helper.colorScheme.secondary,
      helper.despesaIconColor,
      helper.receitaIconColor,
      helper.warningColor,
      Colors.orange,
      Colors.purple,
      Colors.indigo,
      Colors.brown,
      Colors.cyan,
    ];
    final entries = _composicaoAtualCategorias.entries.toList();

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: CustomPaint(
            painter: _DonutPainter(entries: entries, colors: colors),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      color: helper.onSurfaceColor.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
                        .format(total),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: helper.onSurfaceColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            for (int i = 0; i < entries.length && i < 8; i++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colors[i % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    entries[i].key,
                    style: TextStyle(
                      color: helper.onSurfaceColor.withOpacity(0.8),
                    ),
                  ),
                ],
              )
          ],
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<MapEntry<String, double>> entries;
  final List<Color> colors;

  _DonutPainter({required this.entries, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = entries.fold<double>(0.0, (a, b) => a + b.value);
    if (total <= 0) return;

    const strokeWidth = 28.0;
    final rect = Offset.zero & size;
    final radius = (rect.shortestSide / 2) - 8;
    final center = rect.center;
    final rectArc = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -90 * 3.1415926535 / 180; // começa no topo
    int idx = 0;
    for (final e in entries) {
      final sweep = (e.value / total) * 2 * 3.1415926535;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt
        ..color = colors[idx++ % colors.length];
      canvas.drawArc(rectArc, startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.entries != entries;
  }
}
