import 'package:flutter/material.dart';
import 'package:neo_financyuai/app/utils/app_theme_helper.dart';

/// Widget container customizado para a AppBar da Home.
/// 
/// Apresenta informações do usuário, controles de navegação mensal
/// e resumo de saldos financeiros com design arredondado.
class AppBarContainer extends StatefulWidget {
  /// Helper para acesso às configurações de tema.
  final AppThemeHelper helper;

  /// Cria uma nova instância de [AppBarContainer].
  /// 
  /// [helper] é obrigatório para aplicar o tema adequado.
  const AppBarContainer({super.key, required this.helper});

  @override
  State<AppBarContainer> createState() => _AppBarContainerState();
}

class _AppBarContainerState extends State<AppBarContainer> {
  @override
  Widget build(BuildContext context) {
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
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: widget.helper.homeContainerColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Felipe da Silva Leal',
                  style: TextStyle(
                    color: widget.helper.onSurfaceColor,
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.remove_red_eye_outlined,
                color: widget.helper.onSurfaceColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.filter_alt_outlined,
                color: widget.helper.onSurfaceColor,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Linha do mês
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chevron_left, color: widget.helper.onSurfaceColor, size: 22),
              const SizedBox(width: 4),
              Text(
                'Agosto',
                style: TextStyle(
                  color: widget.helper.onSurfaceColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: widget.helper.onSurfaceColor, size: 22),
            ],
          ),
          const SizedBox(height: 18),
          // Saldos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'R\$ 204,00',
                    style: TextStyle(
                      color: widget.helper.onSurfaceColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Saldo atual',
                    style: TextStyle(
                      color: widget.helper.onSurfaceColor,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'R\$ 134,87',
                    style: TextStyle(
                      color: widget.helper.onSurfaceColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Limite disponível',
                    style: TextStyle(
                      color: widget.helper.onSurfaceColor,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Barra inferior
          Center(
            child: Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                color: widget.helper.onSurfaceColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
