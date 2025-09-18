import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastificationUtils {
  static void info({
    required String title,
    String? message,
    Duration duration = const Duration(seconds: 2),
    BuildContext? context,
    Alignment alignment = Alignment.topRight,
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.info,
      style: ToastificationStyle.flatColored,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      description: Text(message ?? ''),
  alignment: alignment,
  autoCloseDuration: duration,
      borderRadius: BorderRadius.circular(12),
      showProgressBar: true,
      closeButton: const ToastCloseButton(
        showType: CloseButtonShowType.onHover,
      ),
  // Evita erro de Dismissible ainda na árvore ao trocar de rota rapidamente
  dragToClose: false,
  closeOnClick: true,
    );
  }

  static void warning({
    required String title,
    String? message,
    Duration duration = const Duration(seconds: 2),
    BuildContext? context,
    Alignment alignment = Alignment.topRight,
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.warning,
      style: ToastificationStyle.flatColored,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      description: Text(message ?? ''),
  alignment: alignment,
  autoCloseDuration: duration,
      borderRadius: BorderRadius.circular(12),
      showProgressBar: true,
      closeButton: const ToastCloseButton(
        showType: CloseButtonShowType.onHover,
      ),
  dragToClose: false,
  closeOnClick: true,
    );
  }

  static void success({
    required String title,
    String? message,
    Duration duration = const Duration(seconds: 3),
    BuildContext? context,
    Alignment alignment = Alignment.topRight,
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      title: Text(title),
      description: message != null ? Text(message) : null,
  alignment: alignment,
  autoCloseDuration: duration,
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      showProgressBar: true,
  dragToClose: false,
  closeOnClick: true,
    );
  }

  static void error({
    required String title,
    String? message,
    Duration duration = const Duration(seconds: 2),
    BuildContext? context,
    Alignment alignment = Alignment.topRight,
  }) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.flatColored,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      description: Text(message ?? ''),
  alignment: alignment,
  autoCloseDuration: duration,
      borderRadius: BorderRadius.circular(12),
      showProgressBar: true,
      closeButton: const ToastCloseButton(
        showType: CloseButtonShowType.onHover,
      ),
  dragToClose: false,
  closeOnClick: true,
    );
  }
}
