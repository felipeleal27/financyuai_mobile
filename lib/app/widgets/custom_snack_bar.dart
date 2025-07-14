import 'package:flutter/material.dart';

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
    _showSnackBar(context, message, Colors.green, Icons.check_circle);
  }

  /// Exibe um SnackBar informativo.
  /// 
  /// [context] é o contexto da aplicação.
  /// [message] é a mensagem a ser exibida.
  static void info(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.blue, Icons.info);
  }

  /// Exibe um SnackBar de aviso.
  /// 
  /// [context] é o contexto da aplicação.
  /// [message] é a mensagem a ser exibida.
  static void warning(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.orange, Icons.warning);
  }

  /// Exibe um SnackBar de erro.
  /// 
  /// [context] é o contexto da aplicação.
  /// [message] é a mensagem a ser exibida.
  static void error(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.red, Icons.error);
  }

  /// Método privado para exibir o SnackBar.
  /// 
  /// [context] é o contexto da aplicação.
  /// [message] é a mensagem a ser exibida.
  /// [color] é a cor de fundo do SnackBar.
  /// [icon] é o ícone a ser exibido.
  static void _showSnackBar(BuildContext context, String message, Color color, IconData icon) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}