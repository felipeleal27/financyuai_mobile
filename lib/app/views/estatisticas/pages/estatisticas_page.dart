import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:neo_financyuai/app/viewmodel/estatisticas/estatisticas_viewmodel.dart';
import 'package:neo_financyuai/app/utils/app_theme_helper.dart';
import 'package:neo_financyuai/app/widgets/bottom_navigation_bat.dart';
import 'package:neo_financyuai/app/views/home/module/home_nome_rotas.dart';
import 'package:neo_financyuai/app/viewmodel/home/home_viewmodel.dart';

class EstatisticasPage extends StatefulWidget {
  final bool embedded;
  const EstatisticasPage({super.key, this.embedded = false});

  @override
  State<EstatisticasPage> createState() => _EstatisticasPageState();
}

class _EstatisticasPageState extends State<EstatisticasPage> with SingleTickerProviderStateMixin {
  late final EstatisticasViewmodel vm;
  late final AnimationController _donutController;

  @override
  void initState() {
    super.initState();
    vm = EstatisticasViewmodel();
    _donutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    vm.load().then((_) {
      if (mounted) {
        _donutController.forward(from: 0);
      }
    });
  }
  
  @override
  void dispose() {
    _donutController.dispose();
    super.dispose();
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
        automaticallyImplyLeading: !widget.embedded,
        leading: widget.embedded
            ? null
            : IconButton(
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
      body: Observer(builder: (_) {
        if (vm.loading) return const Center(child: CircularProgressIndicator());
        return RefreshIndicator(
          onRefresh: () async {
            await vm.load();
            if (mounted) _donutController.forward(from: 0);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _card(
                context,
                title: 'Resumo do mês',
                icon: Icons.summarize_outlined,
                child: _buildResumoMes(context),
              ),
              const SizedBox(height: 12),
              _card(
                context,
                title: 'Saldo previsto no fim do mês',
                subtitle: 'Estimativa com base nos gastos até hoje e possíveis entradas.',
                icon: Icons.trending_up,
                child: Text(
                  vm.saldoPrevistoFimMes == null ? '—' : currency.format(vm.saldoPrevistoFimMes),
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
                subtitle: 'Percentual de despesas por categoria neste mês.',
                icon: Icons.pie_chart_outline,
                child: _buildDonutChart(context),
              ),
              const SizedBox(height: 12),
                  _card(
                    context,
                    title: 'Receitas x Despesas\n(últimos 5 meses)',
                    subtitle: 'Série mensal para acompanhar tendência.',
                    icon: Icons.bar_chart,
                    child: _buildMonthlyBarChart(context),
                  ),
                  const SizedBox(height: 12),
                  _card(
                    context,
                    title: 'Comparativo mês a mês',
                    subtitle: 'Variação deste mês vs o mês anterior.',
                    icon: Icons.compare_arrows_outlined,
                    child: _buildMomComparison(context),
                  ),
                  const SizedBox(height: 12),
                  _card(
                    context,
                    title: 'Top 5 categorias do mês',
                    subtitle: 'Categorias onde você mais gastou no mês.',
                    icon: Icons.leaderboard_outlined,
                    child: _buildTopCategoriasList(context),
                  ),
                  const SizedBox(height: 12),
                  _card(
                    context,
                    title: 'Alertas de variação',
                    subtitle: 'Picos de gasto acima de 30% da média recente.',
                    icon: Icons.warning_amber_rounded,
                    child: _buildAlertas(context),
                  ),
                  const SizedBox(height: 12),
                  _card(
                    context,
                    title: 'Variação por categoria (3 meses)',
                    subtitle: 'Comparação com a média dos últimos 3 meses.',
                    icon: Icons.analytics_outlined,
                    child: Column(
                      children: vm.variacaoPorCategoria.entries.map((e) {
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
                    title: 'Metas do mês',
                    subtitle: 'Em breve: metas por categoria e progresso.',
                    icon: Icons.flag_outlined,
                    child: _buildMetasPlaceholder(context),
                  ),
            ],
          ),
        );
      }),
      floatingActionButton: widget.embedded ? null : SizedBox(
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
      floatingActionButtonLocation:
          widget.embedded ? null : FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar:
          widget.embedded ? null : const CustomBottomNavigationBar(currentIndex: 1),
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
    if (vm.composicaoAtualCategorias.isEmpty) {
      return Text(
        'Sem dados de despesas no mês',
        style: TextStyle(color: helper.onSurfaceColor.withOpacity(0.7)),
      );
    }
    final total = vm.composicaoAtualCategorias.values
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
  final entries = vm.composicaoAtualCategorias.entries.toList();

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: AnimatedBuilder(
            animation: _donutController,
            builder: (context, _) {
              return CustomPaint(
                painter: _DonutPainter(
                  entries: entries,
                  colors: colors,
                  progress: _donutController.value,
                ),
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
              );
            },
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

  Widget _buildResumoMes(BuildContext context) {
    final helper = AppThemeHelper.of(context);
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _kpiTile(
          context,
          label: 'Receitas',
          value: currency.format(vm.totalReceitasMes),
          color: helper.receitaIconColor,
        ),
        const SizedBox(height: 8),
        _kpiTile(
          context,
          label: 'Despesas',
          value: currency.format(vm.totalDespesasMes),
          color: helper.despesaIconColor,
        ),
        const SizedBox(height: 8),
        _kpiTile(
          context,
          label: 'Saldo',
          value: currency.format(vm.saldoDoMes),
          color: vm.saldoDoMes >= 0 ? helper.receitaValueColor : helper.despesaValueColor,
        ),
      ],
    );
  }

  Widget _kpiTile(BuildContext context, {required String label, required String value, required Color color}) {
    final helper = AppThemeHelper.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: helper.surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: helper.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: helper.onSurfaceColor.withOpacity(0.7))),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  Widget _buildMonthlyBarChart(BuildContext context) {
    final helper = AppThemeHelper.of(context);
    if (vm.ultimos6Meses.isEmpty) {
      return Text('Sem dados suficientes', style: TextStyle(color: helper.onSurfaceColor.withOpacity(0.7)));
    }
    // Use only the last 5 months to improve readability on small screens
    final data = vm.ultimos6Meses.length > 5
        ? vm.ultimos6Meses.sublist(vm.ultimos6Meses.length - 5)
        : vm.ultimos6Meses;

    final bars = <BarChartGroupData>[];
    for (int i = 0; i < data.length; i++) {
      final m = data[i];
      bars.add(
        BarChartGroupData(
          x: i,
          barsSpace: 10,
          barRods: [
            BarChartRodData(
              toY: m.receita,
              color: helper.receitaIconColor,
              borderRadius: BorderRadius.circular(4),
              width: 10,
            ),
            BarChartRodData(
              toY: m.despesa,
              color: helper.despesaIconColor,
              borderRadius: BorderRadius.circular(4),
              width: 10,
            ),
          ],
        ),
      );
    }

    // Determine a nice Y-axis max and interval
    final rawMax = data
        .map((e) => e.receita > e.despesa ? e.receita : e.despesa)
        .fold<double>(0.0, (a, b) => a > b ? a : b);
    final nice = _niceScale(0, rawMax <= 0 ? 100 : rawMax, targetTicks: 5);
    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: nice.max,
          gridData: FlGridData(show: true, horizontalInterval: nice.interval),
          borderData: FlBorderData(show: false),
          barGroups: bars,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                interval: nice.interval,
                getTitlesWidget: (value, meta) {
                  return Text(
                    _formatCompact(value),
                    style: TextStyle(fontSize: 10, color: helper.onSurfaceColor.withOpacity(0.8)),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      data[idx].label,
                      style: TextStyle(fontSize: 10, color: helper.onSurfaceColor.withOpacity(0.8)),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(enabled: true),
          alignment: BarChartAlignment.spaceBetween,
          groupsSpace: 14,
        ),
        swapAnimationDuration: const Duration(milliseconds: 700),
        swapAnimationCurve: Curves.easeOutCubic,
      ),
    );
  }

  // Returns a compact number like 1500 -> 1.5k, 12000 -> 12k, 2500000 -> 2.5M
  String _formatCompact(double value) {
    final abs = value.abs();
    if (abs >= 1000000) {
      return '${(value / 1000000).toStringAsFixed((abs < 10000000) ? 1 : 0)}M';
    } else if (abs >= 1000) {
      return '${(value / 1000).toStringAsFixed((abs < 10000) ? 1 : 0)}k';
    }
    // show integers for small values to avoid visual noise
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(0);
  }

  // Compute a "nice" axis scale: a rounded max and interval with ~targetTicks grid lines
  _NiceScale _niceScale(double min, double max, {int targetTicks = 5}) {
    if (max <= min) {
      // fallback scale
  return const _NiceScale(0, 100, 20);
    }
    final range = _niceNum(max - min, false);
    final step = _niceNum(range / (targetTicks - 1), true);
    final niceMin = (min / step).floor() * step;
    double niceMax = (max / step).ceil() * step;
    if (niceMax == niceMin) {
      niceMax = niceMin + step;
    }
    return _NiceScale(niceMin.toDouble(), niceMax.toDouble(), step.toDouble());
  }

  double _niceNum(double range, bool round) {
    final exponent = (range == 0) ? 0 : (math.log(range) / math.ln10).floor();
    final fraction = range / math.pow(10, exponent);
    double niceFraction;
    if (round) {
      if (fraction < 1.5) {
        niceFraction = 1;
      } else if (fraction < 3) {
        niceFraction = 2;
      } else if (fraction < 7) {
        niceFraction = 5;
      } else {
        niceFraction = 10;
      }
    } else {
      if (fraction <= 1) {
        niceFraction = 1;
      } else if (fraction <= 2) {
        niceFraction = 2;
      } else if (fraction <= 5) {
        niceFraction = 5;
      } else {
        niceFraction = 10;
      }
    }
    return niceFraction * math.pow(10, exponent);
  }

  Widget _buildTopCategoriasList(BuildContext context) {
    final helper = AppThemeHelper.of(context);
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    if (vm.topCategorias.isEmpty) {
      return Text('Sem despesas no mês', style: TextStyle(color: helper.onSurfaceColor.withOpacity(0.7)));
    }
    return Column(
      children: vm.topCategorias.map((e) {
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            radius: 14,
            backgroundColor: helper.despesaIconColor.withOpacity(0.15),
            child: Icon(Icons.category_outlined, size: 16, color: helper.despesaValueColor),
          ),
          title: Text(e.key, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Text(
            currency.format(e.value),
            style: TextStyle(color: helper.despesaValueColor, fontWeight: FontWeight.w700),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMomComparison(BuildContext context) {
    final helper = AppThemeHelper.of(context);
    Widget chip(String label, double? perc, {required bool isDespesa}) {
      final inc = (perc ?? 0) >= 0;
      final baseColor = isDespesa ? (inc ? helper.despesaValueColor : helper.receitaValueColor) : (inc ? helper.receitaValueColor : helper.despesaValueColor);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: baseColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(inc ? Icons.north_east : Icons.south_east, size: 14, color: baseColor),
            const SizedBox(width: 6),
            Text(
              perc == null ? '—' : '${inc ? '+' : ''}${perc.toStringAsFixed(1)}%',
              style: TextStyle(color: baseColor, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Despesas', style: TextStyle(color: helper.onSurfaceColor.withOpacity(0.7), fontSize: 12)),
          const SizedBox(height: 6),
          chip('Despesas', vm.momDespesaPerc, isDespesa: true),
        ])),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Receitas', style: TextStyle(color: helper.onSurfaceColor.withOpacity(0.7), fontSize: 12)),
          const SizedBox(height: 6),
          chip('Receitas', vm.momReceitaPerc, isDespesa: false),
        ])),
      ],
    );
  }

  Widget _buildAlertas(BuildContext context) {
    final helper = AppThemeHelper.of(context);
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  if (vm.alertas.isEmpty) {
      return Text('Sem alertas no momento', style: TextStyle(color: helper.onSurfaceColor.withOpacity(0.7)));
    }
    return Column(
      children: vm.alertas.map((a) {
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.warning_amber_rounded, color: helper.warningColor),
          title: Text('${a['categoria']}', maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text('Aumento de ${a['aumento']}%'),
          trailing: Text(currency.format(a['valor'])),
        );
      }).toList(),
    );
  }

  Widget _buildMetasPlaceholder(BuildContext context) {
    return const Text(
      'Nenhuma meta configurada por enquanto. Em breve: metas por categoria e progresso automáticos.',
      // Color derived from theme cannot be const, so keep plain const Text; color will fallback to default.
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<MapEntry<String, double>> entries;
  final List<Color> colors;
  final double progress; // 0.0..1.0

  _DonutPainter({
    required this.entries,
    required this.colors,
    this.progress = 1.0,
  });

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
      final fullSweep = (e.value / total) * 2 * 3.1415926535;
      final sweep = fullSweep * progress.clamp(0.0, 1.0);
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
    return oldDelegate.entries != entries || oldDelegate.progress != progress;
  }
}

// MonthAgg moved to viewmodel as MonthAgg

class _NiceScale {
  final double min;
  final double max;
  final double interval;
  const _NiceScale(this.min, this.max, this.interval);
}
