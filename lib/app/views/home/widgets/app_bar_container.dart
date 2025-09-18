import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';
import 'package:neo_financyuai/app/utils/app_theme_helper.dart';
import 'package:neo_financyuai/app/service/auth_service.dart';
import 'package:neo_financyuai/app/viewmodel/home/home_viewmodel.dart';
import 'package:neo_financyuai/app/widgets/cached_user_avatar_sqlite.dart';

class AppBarContainer extends StatefulWidget {
  final AppThemeHelper helper;
  final Function(DateTime)? onMonthChanged;
  final VoidCallback? onFilterPressed;
  final VoidCallback? onSaldoUpdate; // Callback para atualizar saldo

  const AppBarContainer({
    super.key,
    required this.helper,
    this.onMonthChanged,
    this.onFilterPressed,
    this.onSaldoUpdate,
  });

  @override
  State<AppBarContainer> createState() => _AppBarContainerState();
}

class _AppBarContainerState extends State<AppBarContainer> {
  final AuthService _authService = Modular.get<AuthService>();
  final viewmodelHome = Modular.get<HomeViewmodel>();

  DateTime _mesAtual = DateTime.now();
  bool _mostrarSaldo = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    // await viewmodelHome.carregarSaldo();
  }

  // Future<void> _carregarSaldo() async {
  //   setState(() {
  //   });

  //   try {
  //     final saldo = await _saldoService.calculaSaldoExibido(_mesAtual);
  //     if (mounted) {
  //       setState(() {
  //         _saldoAtual = saldo;
  //       });
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Erro ao carregar saldo: $e');
  //     }
  //     if (mounted) {
  //     }
  //   }
  // }

  /// Método público para atualizar o saldo externamente
  void atualizarSaldo() {
    viewmodelHome.carregarSaldo(_mesAtual);
  }

  void _alterarMes(int incremento) {
    setState(() {
      _mesAtual = DateTime(_mesAtual.year, _mesAtual.month + incremento);
    });
    viewmodelHome.carregarSaldo(_mesAtual);
    widget.onMonthChanged?.call(_mesAtual);
  }

  void _alternarVisibilidadeSaldo() {
    setState(() {
      _mostrarSaldo = !_mostrarSaldo;
    });
  }

  String _formatarSaldo(double valor) {
    if (!_mostrarSaldo) return '• • • • •';

    final formato = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formato.format(valor);
  }

  String _formatarMes(DateTime data) {
    final meses = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    final nomeMes = meses[data.month - 1];
    final anoAtual = DateTime.now().year;
    if (data.year == anoAtual) {
      return nomeMes;
    } else {
      final anoAbreviado = data.year.toString().substring(2);
      return '$nomeMes/$anoAbreviado';
    }
  }

  String _obterTextoSaldo(DateTime mesAtual) {
    final agora = DateTime.now();
    final mesAtualNormalizado = DateTime(agora.year, agora.month);
    final mesSelecionadoNormalizado = DateTime(mesAtual.year, mesAtual.month);

    if (mesSelecionadoNormalizado.isAtSameMomentAs(mesAtualNormalizado)) {
      return 'Saldo atual';
    } else if (mesSelecionadoNormalizado.isBefore(mesAtualNormalizado)) {
      return 'Saldo mês de ${_formatarMes(mesAtual)}';
    } else {
      return 'Saldo previsto para ${_formatarMes(mesAtual)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = _authService.userName ?? 'Usuário';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: widget.helper.homeContainerColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const CachedUserAvatar(
                  radius: 24,
                  fallbackIcon: Icons.person,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  userName,
                  style: TextStyle(
                    color: widget.helper.onSurfaceColor,
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                    fontFamily: 'Poppins',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: widget.helper.onSurfaceColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _alternarVisibilidadeSaldo,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          _mostrarSaldo
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: widget.helper.onSurfaceColor,
                          size: 22,
                          key: ValueKey(_mostrarSaldo),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: widget.helper.onSurfaceColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: widget.onFilterPressed,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.tune,
                        color: widget.helper.onSurfaceColor,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _alterarMes(-1),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.helper.onSurfaceColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.chevron_left,
                        color: widget.helper.onSurfaceColor,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _formatarMes(_mesAtual),
                    key: ValueKey(_mesAtual.month),
                    style: TextStyle(
                      color: widget.helper.onSurfaceColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _alterarMes(1),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.helper.onSurfaceColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.chevron_right,
                        color: widget.helper.onSurfaceColor,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              children: [
                // _carregandoSaldo
                //     ? SizedBox(
                //       width: 24,
                //       height: 24,
                //       child: CircularProgressIndicator(
                //         strokeWidth: 2.5,
                //         valueColor: AlwaysStoppedAnimation<Color>(
                //           widget.helper.onSurfaceColor,
                //         ),
                //       ),
                //     )
                //     :
                Observer(
                  builder: (_) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Text(
                        _formatarSaldo(viewmodelHome.saldoAtual),
                        key: ValueKey('${viewmodelHome.saldoAtual}_$_mostrarSaldo'),
                        style: TextStyle(
                          color: widget.helper.onSurfaceColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                          fontFamily: 'Poppins',
                          letterSpacing: 1.2,
                        ),
                      ),
                    );
                  },
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _obterTextoSaldo(_mesAtual),
                    key: ValueKey(_obterTextoSaldo(_mesAtual)),
                    style: TextStyle(
                      color: widget.helper.onSurfaceColor.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Container(
              width: 80,
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.helper.onSurfaceColor.withOpacity(0.3),
                    widget.helper.onSurfaceColor.withOpacity(0.8),
                    widget.helper.onSurfaceColor.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
