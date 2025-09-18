// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neo_financyuai/app/utils/app_theme_helper.dart';

/// Widget container customizado para seleção de datas.
/// 
/// Apresenta um campo com formato de data e ícone de calendário
/// que permite ao usuário selecionar uma data através de callback.
class CustomDateContainer extends StatelessWidget {
  /// Texto do label do campo.
  final String labelText;
  
  /// Data atualmente selecionada.
  DateTime? dataSelecionada = DateTime.now();
  
  /// Callback executado quando o campo é tocado.
  final VoidCallback onTap;

  /// Cor de fundo opcional para harmonizar com outros campos (ex.: branco).
  final Color? backgroundColor;

  /// Cria uma nova instância de [CustomDateContainer].
  /// 
  /// [labelText] é obrigatório para o rótulo do campo.
  /// [dataSelecionada] é a data inicial selecionada.
  /// [onTap] é obrigatório para tratar o toque no campo.
  CustomDateContainer({
    super.key,
    required this.labelText,
    required this.dataSelecionada,
    required this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final helper = AppThemeHelper.of(context);
    
    // Define a cor de fundo efetiva (usa a override se fornecida)
    final Color effectiveBg = backgroundColor ?? (
      helper.isDark 
          ? helper.colorScheme.surface.withOpacity(0.8)
          : helper.colorScheme.surface
    );

    return _buildLabelOverBorder(
      labelText,
      helper,
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          decoration: BoxDecoration(
            color: effectiveBg,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: helper.colorScheme.outline.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Ícone de calendário à esquerda
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Icon(
                  Icons.calendar_today,
                  color: helper.colorScheme.onSurface.withOpacity(0.7),
                  size: 20,
                ),
              ),
              Expanded(
                child: Text(
                  dataSelecionada != null 
                      ? DateFormat('dd/MM/yyyy').format(dataSelecionada!)
                      : 'Selecione uma data',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: dataSelecionada != null
                        ? helper.colorScheme.onSurface
                        : helper.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Constrói o widget com label posicionado sobre a borda.
  /// 
  /// [labelText] é o texto do label.
  /// [helper] é o helper de tema.
  /// [child] é o widget filho principal.
  Widget _buildLabelOverBorder(String labelText, AppThemeHelper helper, Widget child) {
    return Stack(
      children: [
        child,
        Positioned(
          left: 20,
          top: -8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            // Mantém a mesma cor de fundo do campo abaixo para efeito de "label flutuante"
            color: backgroundColor ?? (
              helper.isDark 
                  ? helper.colorScheme.surface.withOpacity(0.8)
                  : helper.colorScheme.surface
            ),
            child: Text(
              labelText,
              style: TextStyle(
                fontSize: 12.0,
                color: helper.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
