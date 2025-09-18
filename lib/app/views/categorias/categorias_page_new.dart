import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:neo_financyuai/app/data/model/categoria_model.dart';
import 'package:neo_financyuai/app/service/category_icon_service.dart';
import 'package:neo_financyuai/app/utils/app_theme_helper.dart';
import 'package:neo_financyuai/app/viewmodel/categorias/categorias_viewmodel.dart';
import 'package:neo_financyuai/app/widgets/category_icon_picker.dart';
import 'package:neo_financyuai/app/widgets/custom_text_form_field.dart';

class CategoriasPage extends StatefulWidget {
  const CategoriasPage({super.key});

  @override
  State<CategoriasPage> createState() => _CategoriasPageState();
}

class _CategoriasPageState extends State<CategoriasPage> {
  final viewmodel = Modular.get<CategoriasViewmodel>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewmodel.carregarCategorias();
    });
  }

  @override
  Widget build(BuildContext context) {
    final helper = AppThemeHelper.of(context);
    
    return Scaffold(
      backgroundColor: helper.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Gerenciar Categorias',
          style: TextStyle(
            color: helper.onSurfaceColor,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: helper.colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: helper.onSurfaceColor),
      ),
      body: Observer(
        builder: (_) {
          if (viewmodel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewmodel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: helper.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    viewmodel.errorMessage!,
                    style: TextStyle(
                      color: helper.colorScheme.error,
                      fontFamily: 'Poppins',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      viewmodel.clearError();
                      viewmodel.carregarCategorias();
                    },
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewmodel.categorias.length,
            itemBuilder: (context, index) {
              final categoria = viewmodel.categorias[index];
              return _buildCategoriaCard(categoria, helper);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAdicionarCategoriaDialog(context),
        backgroundColor: helper.colorScheme.primary,
        foregroundColor: helper.colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoriaCard(CategoriaModel categoria, AppThemeHelper helper) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: helper.brightness == Brightness.light
          ? Colors.white
          : helper.colorScheme.surface,
      elevation: helper.brightness == Brightness.light ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: helper.brightness == Brightness.dark
            ? BorderSide(
                color: helper.colorScheme.outline.withOpacity(0.2),
                width: 1,
              )
            : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: helper.colorScheme.primary.withOpacity(0.1),
          child: Icon(
            CategoryIconService.getIconData(categoria.icone),
            color: helper.colorScheme.primary,
            size: 24,
          ),
        ),
        title: Text(
          categoria.nome,
          style: TextStyle(
            color: helper.onSurfaceColor,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Ícone: ${categoria.icone}',
          style: TextStyle(
            color: helper.onSurfaceColor.withOpacity(0.6),
            fontFamily: 'Poppins',
            fontSize: 12,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _showEditarCategoriaDialog(context, categoria),
              icon: Icon(
                Icons.edit,
                color: helper.colorScheme.primary,
              ),
            ),
            IconButton(
              onPressed: () => _showRemoverCategoriaDialog(context, categoria),
              icon: Icon(
                Icons.delete,
                color: helper.colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdicionarCategoriaDialog(BuildContext context) {
    final nomeController = TextEditingController();
    String iconeSelecionado = 'category';
    bool usuarioEscolheuIcone = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final helper = AppThemeHelper.of(context);
          
          return AlertDialog(
            backgroundColor: helper.colorScheme.surface,
            title: Text(
              'Nova Categoria',
              style: TextStyle(
                color: helper.onSurfaceColor,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextFormField(
                  controller: nomeController,
                  labelText: 'Nome da Categoria',
                  hintText: 'Digite o nome da categoria',
                  prefixIcon: const Icon(Icons.category),
                  textCapitalization: TextCapitalization.words,
                  onChanged: (value) {
                    // Sugere um ícone automaticamente enquanto o usuário não escolheu manualmente
                    if (!usuarioEscolheuIcone) {
                      final suggestions = CategoryIconService.getSuggestedIcons(value);
                      if (suggestions.isNotEmpty) {
                        iconeSelecionado = suggestions.first;
                        // ignore: invalid_use_of_protected_member
                        (context as Element).markNeedsBuild();
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: helper.colorScheme.primary.withOpacity(0.1),
                      child: Icon(
                        CategoryIconService.getIconData(iconeSelecionado),
                        color: helper.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final icone = await CategoryIconHelper.showIconPicker(
                            context,
                            currentIcon: iconeSelecionado,
                            categoryName: nomeController.text,
                          );
                          if (icone != null) {
                            setState(() {
                              iconeSelecionado = icone;
                              usuarioEscolheuIcone = true;
                            });
                          }
                        },
                        icon: const Icon(Icons.palette),
                        label: const Text('Escolher Ícone'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: helper.onSurfaceColor.withOpacity(0.6)),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final nome = nomeController.text.trim();
                  if (nome.isNotEmpty) {
                    final sucesso = await viewmodel.adicionarCategoria(nome, iconeSelecionado);
                    if (sucesso && context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Categoria adicionada com sucesso!')),
                      );
                    }
                  }
                },
                child: const Text('Adicionar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditarCategoriaDialog(BuildContext context, CategoriaModel categoria) {
    final nomeController = TextEditingController(text: categoria.nome);
    String iconeSelecionado = categoria.icone;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final helper = AppThemeHelper.of(context);
          
          return AlertDialog(
            backgroundColor: helper.colorScheme.surface,
            title: Text(
              'Editar Categoria',
              style: TextStyle(
                color: helper.onSurfaceColor,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextFormField(
                  controller: nomeController,
                  labelText: 'Nome da Categoria',
                  hintText: 'Digite o nome da categoria',
                  prefixIcon: const Icon(Icons.category),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: helper.colorScheme.primary.withOpacity(0.1),
                      child: Icon(
                        CategoryIconService.getIconData(iconeSelecionado),
                        color: helper.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final icone = await CategoryIconHelper.showIconPicker(
                            context,
                            currentIcon: iconeSelecionado,
                            categoryName: nomeController.text,
                          );
                          if (icone != null) {
                            setState(() {
                              iconeSelecionado = icone;
                            });
                          }
                        },
                        icon: const Icon(Icons.palette),
                        label: const Text('Escolher Ícone'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: helper.onSurfaceColor.withOpacity(0.6)),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final nome = nomeController.text.trim();
                  if (nome.isNotEmpty) {
                    final categoriaAtualizada = CategoriaModel(
                      id: categoria.id,
                      nome: nome,
                      icone: iconeSelecionado,
                    );
                    
                    final sucesso = await viewmodel.atualizarCategoria(categoriaAtualizada);
                    if (sucesso && context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Categoria atualizada com sucesso!')),
                      );
                    }
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showRemoverCategoriaDialog(BuildContext context, CategoriaModel categoria) {
    final helper = AppThemeHelper.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: helper.colorScheme.surface,
        title: Text(
          'Remover Categoria',
          style: TextStyle(
            color: helper.onSurfaceColor,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Tem certeza que deseja remover a categoria "${categoria.nome}"?\n\nEsta ação não pode ser desfeita.',
          style: TextStyle(
            color: helper.onSurfaceColor,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: helper.onSurfaceColor.withOpacity(0.6)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final sucesso = await viewmodel.removerCategoria(categoria.id);
              if (context.mounted) {
                Navigator.of(context).pop();
                if (sucesso) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Categoria removida com sucesso!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(viewmodel.errorMessage ?? 'Erro ao remover categoria'),
                      backgroundColor: helper.colorScheme.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: helper.colorScheme.error,
              foregroundColor: helper.colorScheme.onError,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
}
