import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:neo_financyuai/app/service/notification_service.dart';
import 'package:neo_financyuai/app/utils/app_theme_helper.dart';
import 'package:neo_financyuai/app/viewmodel/settings/settings_viewmodel.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class NotificationsSettingsPage extends StatefulWidget {
  const NotificationsSettingsPage({super.key});

  @override
  State<NotificationsSettingsPage> createState() =>
      _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState extends State<NotificationsSettingsPage> {
  final _settingsVm = Modular.get<SettingsViewmodel>();
  final _notifier = Modular.get<NotificationService>();

  @override
  void initState() {
    super.initState();
    // Garante que o estado esteja carregado
    _settingsVm.load();
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
          'Notificações',
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
          onPressed: () => Modular.to.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildCard(
              helper,
              title: 'Geral',
              children: [
                Observer(
                  builder:
                      (_) => _tile(
                        helper,
                        icon: Icons.notifications_active_outlined,
                        title: 'Ativar notificações',
                        subtitle: 'Receber alertas do app e lembretes',
                        trailing: Switch(
                          value: _settingsVm.notificationsEnabled,
                          onChanged: (v) async {
                            if (v) {
                              final hasPerm =
                                  await _notifier.hasSystemPermission();
                              if (!hasPerm) {
                                final granted =
                                    await _notifier.requestSystemPermission();
                                if (!granted) {
                                  return; // Não liga se o usuário não concedeu
                                }
                              }
                            }
                            _settingsVm.setNotificationsEnabled(v);
                            await _notifier.setEnabled(v);
                          },
                          activeColor: helper.colorScheme.primary,
                        ),
                      ),
                ),
                const Divider(height: 1),
                Observer(
                  builder:
                      (_) => _tile(
                        helper,
                        icon: Icons.schedule_outlined,
                        title: 'Lembretes diários',
                        subtitle: 'Sugestões às 20:00 e 22:00',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'O que é isso?',
                              icon: const Icon(Icons.info_outline, size: 20),
                              color: helper.onSurfaceColor.withOpacity(0.6),
                              onPressed:
                                  () => _showInfoDialog(
                                    context,
                                    title: 'Lembretes diários',
                                    message:
                                        'Envia lembretes simples diariamente às 20:00 para registrar transações e às 22:00 para revisar seus gastos.',
                                  ),
                            ),
                            Switch(
                              value: _settingsVm.dailyRemindersEnabled,
                              onChanged:
                                  _settingsVm.notificationsEnabled
                                      ? (v) async {
                                        if (v) {
                                          final hasPerm =
                                              await _notifier
                                                  .hasSystemPermission();
                                          if (!hasPerm) {
                                            final granted =
                                                await _notifier
                                                    .requestSystemPermission();
                                            if (!granted) return;
                                          }
                                        }
                                        _settingsVm.setDailyRemindersEnabled(v);
                                        await _notifier
                                            .toggleDefaultDailyReminders(v);
                                      }
                                      : null,
                              activeColor: helper.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            _buildCard(
              helper,
              title: 'Categorias',
              children: [
                Observer(
                  builder:
                      (_) => _tile(
                        helper,
                        icon: Icons.memory_outlined,
                        title: 'IA Rotinas',
                        subtitle:
                            'Lembretes de compromissos recorrentes atrasados',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'O que é isso?',
                              icon: const Icon(Icons.info_outline, size: 20),
                              color: helper.onSurfaceColor.withOpacity(0.6),
                              onPressed:
                                  () => _showInfoDialog(
                                    context,
                                    title: 'IA Rotinas',
                                    message:
                                        'Analisa suas despesas anteriores e lembra quando um compromisso recorrente pode ter sido esquecido este mês.',
                                  ),
                            ),
                            Switch(
                              value: _settingsVm.aiRoutineEnabled,
                              onChanged:
                                  _settingsVm.notificationsEnabled
                                      ? (v) async {
                                        if (v) {
                                          final hasPerm =
                                              await _notifier
                                                  .hasSystemPermission();
                                          if (!hasPerm) {
                                            final granted =
                                                await _notifier
                                                    .requestSystemPermission();
                                            if (!granted) return;
                                          }
                                        }
                                        _settingsVm.setAiRoutineEnabled(v);
                                      }
                                      : null,
                              activeColor: helper.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                ),
                const Divider(height: 1),
                Observer(
                  builder:
                      (_) => _tile(
                        helper,
                        icon: Icons.celebration_outlined,
                        title: 'IA Feriados',
                        subtitle: 'Avisos próximos a datas comemorativas',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'O que é isso?',
                              icon: const Icon(Icons.info_outline, size: 20),
                              color: helper.onSurfaceColor.withOpacity(0.6),
                              onPressed:
                                  () => _showInfoDialog(
                                    context,
                                    title: 'IA Feriados',
                                    message:
                                        'Te lembra antes de datas como Natal, Carnaval e Páscoa, ajudando a se planejar para gastos típicos.',
                                  ),
                            ),
                            Switch(
                              value: _settingsVm.aiHolidayEnabled,
                              onChanged:
                                  _settingsVm.notificationsEnabled
                                      ? (v) async {
                                        if (v) {
                                          final hasPerm =
                                              await _notifier
                                                  .hasSystemPermission();
                                          if (!hasPerm) {
                                            final granted =
                                                await _notifier
                                                    .requestSystemPermission();
                                            if (!granted) return;
                                          }
                                        }
                                        _settingsVm.setAiHolidayEnabled(v);
                                      }
                                      : null,
                              activeColor: helper.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                ),
                const Divider(height: 1),
                Observer(
                  builder:
                      (_) => _tile(
                        helper,
                        icon: Icons.stacked_line_chart_outlined,
                        title: 'IA Previsão de Saldo',
                        subtitle: 'Alertas de saldo baixo previsto no mês',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'O que é isso?',
                              icon: const Icon(Icons.info_outline, size: 20),
                              color: helper.onSurfaceColor.withOpacity(0.6),
                              onPressed:
                                  () => _showInfoDialog(
                                    context,
                                    title: 'IA Previsão de Saldo',
                                    message:
                                        'Usa seu histórico para prever o saldo no fim do mês e avisa quando o cenário está arriscado.',
                                  ),
                            ),
                            Switch(
                              value: _settingsVm.aiBalanceForecastEnabled,
                              onChanged:
                                  _settingsVm.notificationsEnabled
                                      ? (v) async {
                                        if (v) {
                                          final hasPerm =
                                              await _notifier
                                                  .hasSystemPermission();
                                          if (!hasPerm) {
                                            final granted =
                                                await _notifier
                                                    .requestSystemPermission();
                                            if (!granted) return;
                                          }
                                        }
                                        _settingsVm.setAiBalanceForecastEnabled(
                                          v,
                                        );
                                      }
                                      : null,
                              activeColor: helper.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                ),
                const Divider(height: 1),
                Observer(
                  builder:
                      (_) => _tile(
                        helper,
                        icon: Icons.warning_amber_outlined,
                        title: 'Gasto alto',
                        subtitle: 'Notificar compras acima de um valor',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'O que é isso?',
                              icon: const Icon(Icons.info_outline, size: 20),
                              color: helper.onSurfaceColor.withOpacity(0.6),
                              onPressed:
                                  () => _showInfoDialog(
                                    context,
                                    title: 'Gasto alto',
                                    message:
                                        'Avisa quando uma despesa ultrapassa um valor significativo (por padrão R\$ 500).',
                                  ),
                            ),
                            Switch(
                              value: _settingsVm.highExpenseEnabled,
                              onChanged:
                                  _settingsVm.notificationsEnabled
                                      ? (v) async {
                                        if (v) {
                                          final hasPerm =
                                              await _notifier
                                                  .hasSystemPermission();
                                          if (!hasPerm) {
                                            final granted =
                                                await _notifier
                                                    .requestSystemPermission();
                                            if (!granted) return;
                                          }
                                        }
                                        _settingsVm.setHighExpenseEnabled(v);
                                      }
                                      : null,
                              activeColor: helper.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                ),
                const Divider(height: 1),
                Observer(
                  builder:
                      (_) => _tile(
                        helper,
                        icon: Icons.assignment_outlined,
                        title: 'Relatório mensal',
                        subtitle: 'Quando um resumo mensal estiver disponível',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'O que é isso?',
                              icon: const Icon(Icons.info_outline, size: 20),
                              color: helper.onSurfaceColor.withOpacity(0.6),
                              onPressed:
                                  () => _showInfoDialog(
                                    context,
                                    title: 'Relatório mensal',
                                    message:
                                        'Notifica quando um resumo mensal estiver pronto para você conferir.',
                                  ),
                            ),
                            Switch(
                              value: _settingsVm.monthlyReportEnabled,
                              onChanged:
                                  _settingsVm.notificationsEnabled
                                      ? (v) async {
                                        if (v) {
                                          final hasPerm =
                                              await _notifier
                                                  .hasSystemPermission();
                                          if (!hasPerm) {
                                            final granted =
                                                await _notifier
                                                    .requestSystemPermission();
                                            if (!granted) return;
                                          }
                                        }
                                        _settingsVm.setMonthlyReportEnabled(v);
                                      }
                                      : null,
                              activeColor: helper.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                ),
                const Divider(height: 1),
                Observer(
                  builder:
                      (_) => _tile(
                        helper,
                        icon: Icons.savings_outlined,
                        title: 'Economia conquistada',
                        subtitle: 'Celebrar quando você atingir uma meta',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'O que é isso?',
                              icon: const Icon(Icons.info_outline, size: 20),
                              color: helper.onSurfaceColor.withOpacity(0.6),
                              onPressed:
                                  () => _showInfoDialog(
                                    context,
                                    title: 'Economia conquistada',
                                    message:
                                        'Te avisa e comemora quando você atingir uma meta de economia.',
                                  ),
                            ),
                            Switch(
                              value: _settingsVm.savingsAchievedEnabled,
                              onChanged:
                                  _settingsVm.notificationsEnabled
                                      ? (v) async {
                                        if (v) {
                                          final hasPerm =
                                              await _notifier
                                                  .hasSystemPermission();
                                          if (!hasPerm) {
                                            final granted =
                                                await _notifier
                                                    .requestSystemPermission();
                                            if (!granted) return;
                                          }
                                        }
                                        _settingsVm.setSavingsAchievedEnabled(
                                          v,
                                        );
                                      }
                                      : null,
                              activeColor: helper.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                ),
              ],
            ),

            if (kDebugMode) ...[
              const SizedBox(height: 16),
              _buildCard(
                helper,
                title: 'Testes',
                children: [
                  _tile(
                    helper,
                    icon: Icons.play_circle_outline,
                    title: 'Enviar notificação de teste',
                    subtitle: 'Verifique se tudo está funcionando',
                    trailing: ElevatedButton.icon(
                      onPressed:
                          _settingsVm.notificationsEnabled
                              ? () async {
                                await _notifier.sendTestNotification();
                              }
                              : null,
                      icon: const Icon(
                        Icons.notifications_active_outlined,
                        size: 18,
                      ),
                      label: const Text('Testar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: helper.colorScheme.primary,
                        foregroundColor: helper.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    AppThemeHelper helper, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color:
            helper.brightness == Brightness.light
                ? Colors.white
                : helper.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow:
            helper.brightness == Brightness.light
                ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
        border:
            helper.brightness == Brightness.dark
                ? Border.all(
                  color: helper.colorScheme.outline.withOpacity(0.2),
                  width: 1,
                )
                : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: helper.onSurfaceColor,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _tile(
    AppThemeHelper helper, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: helper.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: helper.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: helper.onSurfaceColor,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: helper.onSurfaceColor.withOpacity(0.6),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Future<void> _showInfoDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    final helper = AppThemeHelper.of(context);
    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: helper.surfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.info_outline, color: helper.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: helper.onSurfaceColor,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              message,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: helper.onSurfaceColor.withOpacity(0.8),
              ),
            ),
            actionsPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  'Entendi',
                  style: TextStyle(
                    color: helper.colorScheme.primary,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
