import 'package:flutter/material.dart';
import 'package:neo_financyuai/app/service/connectivity_service.dart';
import 'package:neo_financyuai/app/utils/app_theme_helper.dart';

/// Widget que exibe o status de conectividade de rede
/// 
/// Mostra um banner discreto quando está offline e pode ser usado
/// em qualquer tela para informar sobre problemas de conectividade.
class ConnectivityIndicator extends StatefulWidget {
  /// Se deve mostrar sempre ou apenas quando offline
  final bool showOnlyWhenOffline;
  
  /// Altura do indicador
  final double height;
  
  /// Se deve mostrar ícone
  final bool showIcon;

  const ConnectivityIndicator({
    super.key,
    this.showOnlyWhenOffline = true,
    this.height = 32,
    this.showIcon = true,
  });

  @override
  State<ConnectivityIndicator> createState() => _ConnectivityIndicatorState();
}

class _ConnectivityIndicatorState extends State<ConnectivityIndicator> {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isOnline = true;
  String _connectionDescription = '';

  @override
  void initState() {
    super.initState();
    _checkInitialConnectivity();
    _listenToConnectivityChanges();
  }

  /// Verifica conectividade inicial
  Future<void> _checkInitialConnectivity() async {
    final isOnline = await _connectivityService.hasInternetConnection();
    final description = await _connectivityService.getConnectionDescription();
    
    if (mounted) {
      setState(() {
        _isOnline = isOnline;
        _connectionDescription = description;
      });
    }
  }

  /// Escuta mudanças de conectividade
  void _listenToConnectivityChanges() {
    _connectivityService.connectivityStream.listen((isOnline) async {
      final description = await _connectivityService.getConnectionDescription();
      
      if (mounted) {
        setState(() {
          _isOnline = isOnline;
          _connectionDescription = description;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final helper = AppThemeHelper.of(context);
    
    // Se configurado para mostrar apenas offline e está online, não mostra nada
    if (widget.showOnlyWhenOffline && _isOnline) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _isOnline 
            ? helper.colorScheme.primary.withOpacity(0.1)
            : helper.colorScheme.error.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: _isOnline 
                ? helper.colorScheme.primary.withOpacity(0.3)
                : helper.colorScheme.error.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.showIcon) ...[
              Icon(
                _isOnline ? Icons.wifi : Icons.wifi_off,
                size: 16,
                color: _isOnline 
                    ? helper.colorScheme.primary
                    : helper.colorScheme.error,
              ),
              const SizedBox(width: 8),
            ],
            
            Text(
              _connectionDescription,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _isOnline 
                    ? helper.colorScheme.primary
                    : helper.colorScheme.error,
              ),
            ),
            
            if (!_isOnline) ...[
              const SizedBox(width: 8),
              Text(
                '• Modo offline ativo',
                style: TextStyle(
                  fontSize: 11,
                  color: helper.colorScheme.error.withOpacity(0.8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // O ConnectivityService é singleton, não precisa fazer dispose
    super.dispose();
  }
}

/// Widget wrapper que adiciona o indicador de conectividade em uma tela
class PageWithConnectivityIndicator extends StatelessWidget {
  final Widget child;
  final bool showIndicator;

  const PageWithConnectivityIndicator({
    super.key,
    required this.child,
    this.showIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!showIndicator) {
      return child;
    }

    return Column(
      children: [
        const ConnectivityIndicator(),
        Expanded(child: child),
      ],
    );
  }
}
