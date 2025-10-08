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

  String _formatarSaldo(double valor, {bool forceVisible = false}) {
    if (!forceVisible && !_mostrarSaldo) return '• • • • •';

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
                  transitionBuilder: _fadeSlideTransition,
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
                    final saldoAtual = viewmodelHome.saldoAtual;
                    final textStyle = TextStyle(
                      color: widget.helper.onSurfaceColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                      fontFamily: 'Poppins',
                      letterSpacing: 1.2,
                    );

                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      transitionBuilder: _fadeSlideTransition,
                      child:
                          _mostrarSaldo
                              ? _SaldoPulseText(
                                  key: const ValueKey('saldo_visivel'),
                                  saldo: saldoAtual,
                                  formatter: (valor) => _formatarSaldo(
                                    valor,
                                    forceVisible: true,
                                  ),
                                  style: textStyle,
                                )
                              : Text(
                                  _formatarSaldo(0),
                                  key: const ValueKey('saldo_oculto'),
                                  style: textStyle,
                                ),
                    );
                  },
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: _fadeSlideTransition,
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

  Widget _fadeSlideTransition(Widget child, Animation<double> animation) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

class _SaldoPulseText extends StatefulWidget {
  final double saldo;
  final TextStyle style;
  final String Function(double) formatter;

  const _SaldoPulseText({
    super.key,
    required this.saldo,
    required this.style,
    required this.formatter,
  });

  @override
  State<_SaldoPulseText> createState() => _SaldoPulseTextState();
}

class _SaldoPulseTextState extends State<_SaldoPulseText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..value = 1.0;

    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _opacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.55),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.55, end: 1.0),
        weight: 60,
      ),
    ]).animate(curved);

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.035),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.035, end: 1.0),
        weight: 50,
      ),
    ]).animate(curved);
  }

  @override
  void didUpdateWidget(covariant _SaldoPulseText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.saldo - oldWidget.saldo).abs() > 0.009) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.scale(
            scale: _scale.value,
            child: Text(
              widget.formatter(widget.saldo),
              style: widget.style,
            ),
          ),
        );
      },
    );
  }
}
