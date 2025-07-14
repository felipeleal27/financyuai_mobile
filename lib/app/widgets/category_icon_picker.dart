import 'package:flutter/material.dart';
import 'package:neo_financyuai/app/service/category_icon_service.dart';
import 'package:neo_financyuai/app/utils/app_theme_helper.dart';

/// Widget para seleção de ícones de categoria
/// 
/// Exibe uma grade de ícones organizados por categoria,
/// permitindo ao usuário selecionar um ícone para sua categoria.
class CategoryIconPicker extends StatefulWidget {
  /// Ícone atualmente selecionado
  final String selectedIcon;
  
  /// Callback chamado quando um ícone é selecionado
  final ValueChanged<String> onIconSelected;
  
  /// Nome da categoria (para sugestões inteligentes)
  final String? categoryName;

  const CategoryIconPicker({
    super.key,
    required this.selectedIcon,
    required this.onIconSelected,
    this.categoryName,
  });

  @override
  State<CategoryIconPicker> createState() => _CategoryIconPickerState();
}

class _CategoryIconPickerState extends State<CategoryIconPicker>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, List<MapEntry<String, IconData>>> _iconsByCategory = 
      CategoryIconService.getIconsByCategory();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _iconsByCategory.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final helper = AppThemeHelper.of(context);
    
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: helper.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: helper.onSurfaceColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'Escolha um ícone',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: helper.onSurfaceColor,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                if (widget.categoryName != null) ...[
                  Text(
                    'para a categoria "${widget.categoryName}"',
                    style: TextStyle(
                      fontSize: 14,
                      color: helper.onSurfaceColor.withOpacity(0.7),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSuggestedIcons(helper),
                ],
              ],
            ),
          ),
          
          // Tabs
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: helper.colorScheme.primary,
            unselectedLabelColor: helper.onSurfaceColor.withOpacity(0.6),
            indicatorColor: helper.colorScheme.primary,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              fontFamily: 'Poppins',
            ),
            tabs: _iconsByCategory.keys
                .map((category) => Tab(text: category))
                .toList(),
          ),
          
          // Grid de ícones
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _iconsByCategory.entries
                  .map((entry) => _buildIconGrid(helper, entry.value))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói a seção de ícones sugeridos
  Widget _buildSuggestedIcons(AppThemeHelper helper) {
    if (widget.categoryName == null) return const SizedBox.shrink();
    
    final suggestions = CategoryIconService.getSuggestedIcons(widget.categoryName!);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sugestões:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: helper.onSurfaceColor,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: suggestions.map((iconName) {
            final isSelected = widget.selectedIcon == iconName;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _buildIconItem(helper, iconName, 
                  CategoryIconService.getIconData(iconName), isSelected),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Constrói a grade de ícones para uma categoria
  Widget _buildIconGrid(AppThemeHelper helper, List<MapEntry<String, IconData>> icons) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: icons.length,
        itemBuilder: (context, index) {
          final icon = icons[index];
          final isSelected = widget.selectedIcon == icon.key;
          return _buildIconItem(helper, icon.key, icon.value, isSelected);
        },
      ),
    );
  }

  /// Constrói um item de ícone individual
  Widget _buildIconItem(AppThemeHelper helper, String iconName, 
      IconData iconData, bool isSelected) {
    return InkWell(
      onTap: () => widget.onIconSelected(iconName),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected 
              ? helper.colorScheme.primary.withOpacity(0.1)
              : helper.colorScheme.surface,
          border: Border.all(
            color: isSelected 
                ? helper.colorScheme.primary
                : helper.colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconData,
              size: 24,
              color: isSelected 
                  ? helper.colorScheme.primary
                  : helper.onSurfaceColor,
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: helper.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget simples para exibir um ícone de categoria
class CategoryIcon extends StatelessWidget {
  /// Nome do ícone
  final String iconName;
  
  /// Tamanho do ícone
  final double size;
  
  /// Cor do ícone
  final Color? color;

  const CategoryIcon({
    super.key,
    required this.iconName,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      CategoryIconService.getIconData(iconName),
      size: size,
      color: color,
    );
  }
}

/// Extensão para facilitar o uso em formulários
extension CategoryIconHelper on Widget {
  /// Mostra o seletor de ícones como modal bottom sheet
  static Future<String?> showIconPicker(
    BuildContext context, {
    required String currentIcon,
    String? categoryName,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategoryIconPicker(
        selectedIcon: currentIcon,
        categoryName: categoryName,
        onIconSelected: (iconName) {
          Navigator.of(context).pop(iconName);
        },
      ),
    );
  }
}
