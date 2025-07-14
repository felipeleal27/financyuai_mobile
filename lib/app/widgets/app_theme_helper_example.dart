import 'package:flutter/material.dart';
import 'package:neo_financyuai/app/utils/app_theme_helper.dart';

/// Widget de exemplo que demonstra como usar o AppThemeHelper.
/// 
/// Apresenta diversos componentes UI utilizando o helper de tema
/// para garantir consistência visual em toda a aplicação.
class AppThemeHelperExample extends StatelessWidget {
  /// Cria uma nova instância de [AppThemeHelperExample].
  const AppThemeHelperExample({super.key});

  @override
  Widget build(BuildContext context) {
    final helper = AppThemeHelper.of(context);

    return Scaffold(
      backgroundColor: helper.surfaceColor,
      appBar: AppBar(
        backgroundColor: helper.homeContainerColor,
        title: Text(
          'AppThemeHelper Demo',
          style: TextStyle(
            color: helper.onSurfaceColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(helper),
            const SizedBox(height: 24),
            _buildColorDemo(helper),
            const SizedBox(height: 24),
            _buildContainerDemo(helper),
            const SizedBox(height: 24),
            _buildInfoSection(helper),
          ],
        ),
      ),
    );
  }

  /// Constrói a seção de cabeçalho.
  Widget _buildHeaderSection(AppThemeHelper helper) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Demonstração do AppThemeHelper',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: helper.onSurfaceColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Este widget demonstra como usar o helper de tema para manter consistência visual.',
          style: TextStyle(
            fontSize: 16,
            color: helper.onSurfaceColor.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  /// Constrói a demonstração de cores.
  Widget _buildColorDemo(AppThemeHelper helper) {
    return Card(
      color: helper.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cores do Tema',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: helper.onSurfaceColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildColorItem('Surface', helper.surfaceColor),
            _buildColorItem('Primary', helper.colorScheme.primary),
            _buildColorItem('Secondary', helper.colorScheme.secondary),
            _buildColorItem('Container Home', helper.homeContainerColor),
          ],
        ),
      ),
    );
  }

  /// Constrói um item individual de cor.
  Widget _buildColorItem(String name, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            name,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  /// Constrói a demonstração de containers temáticos.
  Widget _buildContainerDemo(AppThemeHelper helper) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: helper.homeContainerColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Container Temático',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: helper.onSurfaceColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Este container usa as cores definidas no helper de tema.',
            style: TextStyle(
              fontSize: 14,
              color: helper.onSurfaceColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói a seção informativa.
  Widget _buildInfoSection(AppThemeHelper helper) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: helper.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: helper.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: helper.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Informações do Tema',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: helper.onSurfaceColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Modo:', helper.isDark ? 'Escuro' : 'Claro'),
          _buildInfoRow('Brightness:', helper.brightness.name),
          _buildInfoRow('Largura da Tela:', '${helper.screenWidth.toInt()}px'),
          _buildInfoRow('Altura da Tela:', '${helper.screenHeight.toInt()}px'),
        ],
      ),
    );
  }

  /// Constrói uma linha de informação.
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
