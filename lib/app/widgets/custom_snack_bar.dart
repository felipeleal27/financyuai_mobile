import 'package:flutter/material.dart';
import 'package:neo_financyuai/app/utils/toastification_utils.dart';

/// Classe utilitária para exibir SnackBars customizados.
/// 
/// Fornece métodos estáticos para diferentes tipos de notificações
/// com cores e ícones apropriados para cada contexto.
class CustomSnackBar {
  /// Construtor privado para prevenir instanciação.
  const CustomSnackBar._();

  /// Exibe um SnackBar de sucesso.
  /// 
  /// [context] é o contexto da aplicação.
  /// [message] é a mensagem a ser exibida.
  static void success(BuildContext context, String message) {
    ToastificationUtils.success(title: message, context: context);
  }

  /// Exibe um SnackBar informativo.
  /// 
  /// [context] é o contexto da aplicação.
  /// [message] é a mensagem a ser exibida.
  static void info(BuildContext context, String message) {
    ToastificationUtils.info(title: message, context: context);
  }

  /// Exibe um SnackBar de aviso.
  /// 
  /// [context] é o contexto da aplicação.
  /// [message] é a mensagem a ser exibida.
  static void warning(BuildContext context, String message) {
    ToastificationUtils.warning(title: message, context: context);
  }

  /// Exibe um SnackBar de erro.
  /// 
  /// [context] é o contexto da aplicação.
  /// [message] é a mensagem a ser exibida.
  static void error(BuildContext context, String message) {
    ToastificationUtils.error(title: message, context: context);
  }

  /// Método privado para exibir o SnackBar.
  /// 
  /// [context] é o contexto da aplicação.
  /// [message] é a mensagem a ser exibida.
  /// [color] é a cor de fundo do SnackBar.
  /// [icon] é o ícone a ser exibido.
  // Mantido para compatibilidade: agora delega para ToastificationUtils.
}