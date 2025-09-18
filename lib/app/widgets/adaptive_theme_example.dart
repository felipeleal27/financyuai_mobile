import 'package:flutter/material.dart';
import 'package:neo_financyuai/app/utils/toastification_utils.dart';
import 'package:neo_financyuai/app/utils/ui_config_theme.dart';

/// Widget de exemplo que demonstra como usar os temas adaptativos.
/// 
/// Apresenta diversos componentes UI aplicados com as configurações
/// de tema atual e fornece informações sobre o estado do tema.
class AdaptiveThemeExample extends StatelessWidget {
  /// Cria uma nova instância de [AdaptiveThemeExample].
  const AdaptiveThemeExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Detecta se está no modo escuro
    final isDark = UiConfigTheme.isDarkMode(context);
    
    // Obtém cores do tema atual
    final primaryColor = UiConfigTheme.getPrimaryColor(context);
    final surfaceColor = UiConfigTheme.getSurfaceColor(context);
    final textColor = UiConfigTheme.getTextColor(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tema ${isDark ? 'Escuro' : 'Claro'}'),
      ),
      body: Container(
        color: surfaceColor,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exemplo de Tema Adaptativo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Container com cor primária',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Card adaptativo',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Este card se adapta automaticamente ao tema do sistema.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Exemplo de como acessar o tema atual
                final currentTheme = UiConfigTheme.getCurrentTheme(context);
                ToastificationUtils.info(
                  title: 'Tema atual: ${currentTheme.brightness == Brightness.dark ? 'Escuro' : 'Claro'}',
                  context: context,
                );
              },
              child: const Text('Mostrar Tema Atual'),
            ),
            const SizedBox(height: 16),
            Text(
              'Dica: Altere o tema do sistema nas configurações do seu dispositivo para ver a mudança automática!',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
