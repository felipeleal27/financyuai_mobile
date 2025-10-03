import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:neo_financyuai/app/utils/app_theme_helper.dart';
import 'package:neo_financyuai/app/views/home/module/home_nome_rotas.dart';
import 'package:neo_financyuai/app/viewmodel/orcamento/orcamento_viewmodel.dart';
import 'package:neo_financyuai/app/widgets/bottom_navigation_bat.dart';

class OrcamentoPage extends StatefulWidget {
  final bool embedded;
  const OrcamentoPage({super.key, this.embedded = false});

  @override
  State<OrcamentoPage> createState() => _OrcamentoPageState();
}

class _OrcamentoPageState extends State<OrcamentoPage> {
  late final OrcamentoViewmodel vm;
  final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  final _savingsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    vm = Modular.get<OrcamentoViewmodel>();
    vm.load().then((_) {
      _savingsController.text = vm.savingsGoal?.toStringAsFixed(0) ?? '';
    });
  }

  @override
  void dispose() {
    _savingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final helper = AppThemeHelper.of(context);

    return Scaffold(
      backgroundColor: helper.surfaceColor,
      appBar: AppBar(
        backgroundColor: helper.surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'Orçamento',
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
            child: _monthChip(helper),
          )
        ],
      ),
      body: Observer(
        builder: (_) {
          if (vm.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: vm.load,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _card(
                  helper,
                  title: 'Limite mensal de gastos',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Defina um limite para seus gastos mensais. Ative o alerta para ser avisado quando estiver chegando perto ou ultrapassar o limite.',
                        style: TextStyle(color: helper.onSurfaceColor.withOpacity(0.8), fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Saldo atual', style: TextStyle(color: helper.onSurfaceColor.withOpacity(0.7), fontSize: 12)),
                          Text(currency.format(vm.saldoAtual), style: TextStyle(fontWeight: FontWeight.w700, color: helper.onSurfaceColor)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Limite', style: TextStyle(color: helper.onSurfaceColor.withOpacity(0.7), fontSize: 12)),
                          Text(currency.format(vm.monthlyLimit ?? 0), style: TextStyle(fontWeight: FontWeight.w700, color: helper.onSurfaceColor)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 6,
                          activeTrackColor: helper.colorScheme.primary,
                          inactiveTrackColor: helper.onSurfaceColor.withOpacity(0.25),
                          thumbColor: helper.colorScheme.primary,
                          overlayColor: helper.colorScheme.primary.withOpacity(0.12),
                          valueIndicatorColor: helper.colorScheme.primary,
                          trackShape: const RoundedRectSliderTrackShape(),
                        ),
                        child: Slider(
                          value: (vm.monthlyLimit ?? 0).clamp(0, 20000).toDouble(),
                          min: 0,
                          max: 20000,
                          divisions: 200,
                          label: currency.format(vm.monthlyLimit ?? 0),
                          onChanged: (v) {
                            setState(() => vm.monthlyLimit = v);
                          },
                          onChangeEnd: (v) => vm.saveMonthlyLimit(v),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _progressBar(
                        helper,
                        vm.limitProgress,
                        label: 'Gasto ${currency.format(vm.totalSpentThisMonth)} de ${currency.format(vm.monthlyLimit ?? 0)}',
                        color: vm.indicatorColorCode == 2
                            ? Colors.red
                            : (vm.indicatorColorCode == 1 ? Colors.orange : Colors.green),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Switch(
                              value: vm.limitEnabled,
                              onChanged: (v) => vm.setLimitEnabled(v),
                            ),
                            const SizedBox(width: 6),
                            Text('Alertas do limite', style: TextStyle(color: helper.onSurfaceColor)),
                          ]),
                          Text(
                            vm.monthlyLimit == null || vm.monthlyLimit == 0
                                ? 'Defina um limite'
                                : 'Usou ${(vm.limitProgress * 100).clamp(0, 999).toStringAsFixed(0)}%',
                            style: TextStyle(color: helper.onSurfaceColor.withOpacity(0.7)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _card(
                  helper,
                  title: 'Meta de economia',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _savingsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'Ex: 300'),
                        onSubmitted: (v) => vm.saveSavingsGoal(double.tryParse(v.replaceAll('.', '').replaceAll(',', '.'))),
                      ),
                      const SizedBox(height: 8),
                      _progressBar(helper, vm.savingsProgress, color: helper.receitaIconColor, label: 'Economizado ${currency.format(vm.savedSoFar)} de ${currency.format(vm.savingsGoal ?? 0)}'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _card(
                  helper,
                  title: 'Metas por categoria',
                  child: Column(
                    children: [
                      if (vm.spentByCategory.isEmpty)
                        Text('Sem gastos este mês.', style: TextStyle(color: helper.onSurfaceColor.withOpacity(0.7)))
                      else ...vm.spentByCategory.entries.map((e) {
                        final cap = vm.categoryCaps[e.key] ?? 0.0;
                        final progress = cap <= 0 ? 0.0 : (e.value / cap).clamp(0.0, 1.2);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    _progressBar(
                                      helper,
                                      progress,
                                      label: cap <= 0
                                          ? 'Sem meta. Gasto ${currency.format(e.value)}'
                                          : 'Gasto ${currency.format(e.value)} de ${currency.format(cap)}',
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 90,
                                child: TextField(
                                  decoration: const InputDecoration(
                                    hintText: 'Meta',
                                  ),
                                  keyboardType: TextInputType.number,
                                  onSubmitted: (v) {
                                    final val = double.tryParse(v.replaceAll('.', '').replaceAll(',', '.'));
                                    vm.saveCategoryCap(e.key, val);
                                  },
                                ),
                              )
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Alertas automáticos: 70%, 90% e 100% do limite mensal',
                  style: TextStyle(color: helper.onSurfaceColor.withOpacity(0.7), fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: widget.embedded ? null : const CustomBottomNavigationBar(currentIndex: 3),
    );
  }

  Widget _card(AppThemeHelper helper, {required String title, required Widget child}) {
    return Container(
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
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _progressBar(AppThemeHelper helper, double progress, {Color? color, String? label}) {
    final base = color ?? helper.despesaIconColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: base.withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation<Color>(base),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: helper.onSurfaceColor.withOpacity(0.8), fontSize: 12)),
        ]
      ],
    );
  }

  Widget _monthChip(AppThemeHelper helper) {
    final now = DateTime.now();
    const monthNames = [
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
}
