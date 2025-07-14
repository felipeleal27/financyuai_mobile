import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:neo_financyuai/app/utils/theme_manager.dart';
import 'package:neo_financyuai/app/widgets/theme_selector.dart';

/// Página para teste e demonstração dos temas da aplicação.
/// 
/// Permite visualizar diferentes componentes UI aplicados com os temas
/// disponíveis e fornece controles para alternar entre eles.
class ThemeTestPage extends StatefulWidget {
  /// Cria uma nova instância de [ThemeTestPage].
  const ThemeTestPage({super.key});

  @override
  State<ThemeTestPage> createState() => _ThemeTestPageState();
}

/// Estado da página de teste de temas.
/// 
/// Gerencia a integração com o ThemeManager e exibe componentes
/// de demonstração dos temas disponíveis.
class _ThemeTestPageState extends State<ThemeTestPage> {
  /// Gerenciador de temas da aplicação.
  late ThemeManager themeManager;

  @override
  void initState() {
    super.initState();
    themeManager = Modular.get<ThemeManager>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste de Tema', style: TextStyle(fontSize: 20, color: Colors.amber)),
        actions: const [
          ThemeToggleButton(), // Botão para alternar tema
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seletor de tema
            const ThemeSelector(),
            
            const SizedBox(height: 24),
            
            // Informações do tema atual
            AnimatedBuilder(
              animation: themeManager,
              builder: (context, child) {
                final isDark = themeManager.isDarkMode(context);
                
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status do Tema',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text('Preferência: ${themeManager.currentPreference.displayName}'),
                        Text('Modo atual: ${isDark ? 'Escuro' : 'Claro'}'),
                        Text('ThemeMode: ${themeManager.themeMode.name}'),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Exemplos de componentes
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Componentes de Teste',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    
                    // Botões
                    Wrap(
                      spacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('Elevated'),
                        ),
                        FilledButton(
                          onPressed: () {},
                          child: const Text('Filled'),
                        ),
                        OutlinedButton(
                          onPressed: () {},
                          child: const Text('Outlined'),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Text'),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Switch e Checkbox
                    Row(
                      children: [
                        Switch(
                          value: true,
                          onChanged: (value) {},
                        ),
                        const SizedBox(width: 16),
                        Checkbox(
                          value: true,
                          onChanged: (value) {},
                        ),
                        const SizedBox(width: 16),
                        Radio<int>(
                          value: 1,
                          groupValue: 1,
                          onChanged: (value) {},
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // TextField
                    const TextField(
                      decoration: InputDecoration(
                        labelText: 'Campo de texto',
                        hintText: 'Digite algo...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Cores do tema
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cores do Tema',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ColorSample('Primary', Theme.of(context).colorScheme.primary),
                        _ColorSample('Secondary', Theme.of(context).colorScheme.secondary),
                        _ColorSample('Surface', Theme.of(context).colorScheme.surface),
                        _ColorSample('Background', Theme.of(context).colorScheme.surface),
                        _ColorSample('Error', Theme.of(context).colorScheme.error),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget que exibe uma amostra de cor com nome.
/// 
/// Apresenta uma cor específica em um container com bordas arredondadas
/// e texto contrastante para facilitar a visualização.
class _ColorSample extends StatelessWidget {
  /// Nome da cor a ser exibido.
  final String _name;
  
  /// Cor a ser exibida na amostra.
  final Color _color;
  
  /// Cria uma nova instância de [_ColorSample].
  /// 
  /// [name] é o nome descritivo da cor.
  /// [color] é a cor a ser exibida.
  const _ColorSample(this._name, this._color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 60,
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Center(
        child: Text(
          _name,
          style: TextStyle(
            color: _getContrastingColor(_color),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  
  /// Calcula a cor contrastante baseada na luminância.
  /// 
  /// Retorna preto para cores claras e branco para cores escuras.
  Color _getContrastingColor(Color color) {
    // Calcula luminância para determinar se usar texto claro ou escuro
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
