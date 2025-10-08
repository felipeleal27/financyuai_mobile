import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:neo_financyuai/app/database/local_storage/local_storage.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:neo_financyuai/app/data/model/categoria_model.dart';
import 'package:neo_financyuai/app/data/model/movimentacao_model.dart';
import 'package:neo_financyuai/app/utils/app_theme_helper.dart';
import 'package:neo_financyuai/app/viewmodel/home/home_viewmodel.dart';
import 'package:neo_financyuai/app/views/home/module/home_nome_rotas.dart';
import 'package:neo_financyuai/app/views/home/widgets/app_bar_container.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:neo_financyuai/app/views/nova_transacao/module/nova_transacao_nome_rotas.dart';
import 'package:neo_financyuai/app/widgets/bottom_navigation_bat.dart';
import 'package:neo_financyuai/app/widgets/draggable_chat_bubble.dart';
import 'package:neo_financyuai/app/widgets/chat_ia_dialog.dart';
import 'package:neo_financyuai/app/service/category_icon_service.dart';
import 'package:neo_financyuai/app/utils/toastification_utils.dart';

class HomePage extends StatefulWidget {
  final bool embedded;
  const HomePage({super.key, this.embedded = false});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  void _showDetalhesTransacaoModal(
    BuildContext context,
    MovimentacaoModel movimentacao,
  ) {
    final helper = AppThemeHelper.of(context);
    final categoria = viewmodel.categoria.firstWhere(
      (e) => movimentacao.idCategoria == e.id,
      orElse:
          () => CategoriaModel(
            id: 0,
            nome: 'Categoria não encontrada',
            icone: 'category',
          ),
    );
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (modalContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: helper.onSurfaceColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor:
                        movimentacao.isSaida
                            ? helper.despesaIconColor
                            : helper.receitaIconColor,
                    child: Icon(
                      CategoryIconService.getIconData(categoria.icone),
                      color: helper.colorScheme.onPrimary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movimentacao.nome,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: helper.onSurfaceColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          categoria.nome,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: helper.onSurfaceColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: helper.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat(
                      'dd/MM/yyyy',
                    ).format(movimentacao.dataMovimentacao),
                    style: TextStyle(
                      fontSize: 14,
                      color: helper.onSurfaceColor,
                    ),
                  ),
                  // Se quiser mostrar recorrência/parcelamento, adicione lógica aqui conforme o modelo
                  // Exemplo: const SizedBox(width: 18), ...
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    size: 18,
                    color: helper.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    viewmodel.canSeeValue
                        ? NumberFormat.currency(
                          locale: 'pt_BR',
                          symbol: 'R\$',
                          decimalDigits: 2,
                        ).format(movimentacao.valor)
                        : 'R\$ ***',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          movimentacao.isSaida
                              ? helper.despesaValueColor
                              : helper.receitaValueColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(modalContext).pop();
                        _showRemoverTransacaoBottomSheet(context, movimentacao);
                      },
                      icon: Icon(
                        Icons.delete,
                        color: helper.colorScheme.onError,
                      ),
                      label: Text(
                        'Remover',
                        style: TextStyle(color: helper.colorScheme.onError),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: helper.colorScheme.error,
                        foregroundColor: helper.colorScheme.onError,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.of(modalContext).pop();
                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) {
                            return Container(
                              decoration: BoxDecoration(
                                color: helper.colorScheme.surface,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                              ),
                              child: SafeArea(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 24,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Handle
                                      Container(
                                        width: 40,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: helper.onSurfaceColor
                                              .withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        'Ações da Transação',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: helper.onSurfaceColor,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      // Botão Editar
                                      _buildActionButton(
                                        ctx,
                                        icon: Icons.edit_outlined,
                                        title: 'Editar Transação',
                                        subtitle:
                                            'Modificar dados desta transação',
                                        color: helper.colorScheme.primary,
                                        onTap: () {
                                          Navigator.of(ctx).pop();
                                          _editarTransacao(
                                            context,
                                            movimentacao,
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      // Botão Duplicar
                                      _buildActionButton(
                                        ctx,
                                        icon: Icons.copy_outlined,
                                        title: 'Duplicar Transação',
                                        subtitle:
                                            'Criar uma cópia desta transação',
                                        color: helper.colorScheme.secondary,
                                        onTap: () {
                                          Navigator.of(ctx).pop();
                                          ToastificationUtils.info(
                                            title:
                                                'Funcionalidade de duplicar em breve!',
                                            context: context,
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      // Botão Compartilhar
                                      _buildActionButton(
                                        ctx,
                                        icon: Icons.share_outlined,
                                        title: 'Compartilhar',
                                        subtitle:
                                            'Enviar detalhes por mensagem',
                                        color: Colors.blue,
                                        onTap: () {
                                          Navigator.of(ctx).pop();
                                          ToastificationUtils.info(
                                            title:
                                                'Funcionalidade de compartilhar em breve!',
                                            context: context,
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 24),
                                      // Botão Cancelar
                                      SizedBox(
                                        width: double.infinity,
                                        child: TextButton(
                                          onPressed:
                                              () => Navigator.of(ctx).pop(),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            'Cancelar',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: helper.onSurfaceColor
                                                  .withOpacity(0.7),
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      icon: Icon(
                        Icons.more_horiz,
                        color: helper.colorScheme.onSecondary,
                      ),
                      label: Text(
                        'Mais',
                        style: TextStyle(color: helper.colorScheme.onSecondary),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: helper.colorScheme.secondary,
                        foregroundColor: helper.colorScheme.onSecondary,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtonStatic(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color onSurfaceColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: onSurfaceColor,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: onSurfaceColor.withOpacity(0.7),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: onSurfaceColor.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final helper = AppThemeHelper.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: helper.onSurfaceColor,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: helper.onSurfaceColor.withOpacity(0.7),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: helper.onSurfaceColor.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRemoverTransacaoBottomSheet(
    BuildContext context,
    MovimentacaoModel movimentacao,
  ) {
    final id = movimentacao.id ?? '';
    final isRecorrente = id.contains('_parcela_') || id.contains('_fixa_');

    if (!isRecorrente) {
      _showConfirmDeleteDialog(context, movimentacao);
      return;
    }

    // Captura os valores do helper antes de abrir o modal
    final helper = AppThemeHelper.of(context);
    final surfaceColor = helper.colorScheme.surface;
    final onSurfaceColor = helper.onSurfaceColor;
    final errorColor = helper.colorScheme.error;

    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: onSurfaceColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Ícone de aviso
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Icon(
                      Icons.warning_rounded,
                      size: 32,
                      color: errorColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Remover Transação',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: onSurfaceColor,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Como você deseja remover esta transação?',
                    style: TextStyle(
                      fontSize: 14,
                      color: onSurfaceColor.withOpacity(0.7),
                      fontFamily: 'Poppins',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Opção: Apenas este mês
                  _buildRemoveOptionStatic(
                    modalContext,
                    icon: Icons.event_outlined,
                    title: 'Apenas este mês',
                    subtitle: 'Remove somente esta ocorrência',
                    color: Colors.orange,
                    value: 'apenas_esta',
                    onSurfaceColor: onSurfaceColor,
                  ),
                  const SizedBox(height: 12),
                  // Opção: A partir deste mês
                  _buildRemoveOptionStatic(
                    modalContext,
                    icon: Icons.arrow_forward_outlined,
                    title: 'A partir deste mês',
                    subtitle: 'Remove esta e as próximas ocorrências',
                    color: Colors.amber.shade700,
                    value: 'desta_pra_frente',
                    onSurfaceColor: onSurfaceColor,
                  ),
                  const SizedBox(height: 12),
                  // Opção: Todas relacionadas
                  _buildRemoveOptionStatic(
                    modalContext,
                    icon: Icons.delete_forever_outlined,
                    title: 'Excluir definitivamente',
                    subtitle: 'Remove todas as ocorrências relacionadas',
                    color: errorColor,
                    value: 'todas_relacionadas',
                    onSurfaceColor: onSurfaceColor,
                  ),
                  const SizedBox(height: 24),
                  // Botão Cancelar
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.of(modalContext).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 16,
                          color: onSurfaceColor.withOpacity(0.7),
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((result) async {
      if (result != null) {
        if (!context.mounted) return;
        // Mostra confirmação antes de executar a ação
        _showConfirmDeleteDialog(context, movimentacao, result);
      }
    });
  }

  void _editarTransacao(BuildContext context, MovimentacaoModel movimentacao) {
    // Agora sempre abrimos a tela de edição; o escopo da edição será
    // escolhido no momento de salvar na tela de edição.
    _abrirEdicaoTransacao(context, movimentacao);
  }

  void _abrirEdicaoTransacao(
    BuildContext context,
    MovimentacaoModel movimentacao, {
    String? tipoEdicao,
  }) {
    // Por enquanto, vamos navegar para a nova transação passando os dados
    // Em uma implementação futura, isso poderia ser uma página específica de edição
    final rota =
        movimentacao.isSaida
            ? '${HomeNomeRotas.navigate}${NovaTransacaoNomeRotas.navigateDespesa}'
            : '${HomeNomeRotas.navigate}${NovaTransacaoNomeRotas.navigateReceita}';

    // Navegar passando os dados da transação como argumentos
    Modular.to
        .pushNamed(
          rota,
          arguments: {
            'movimentacao': movimentacao,
            'isEdicao': true,
            'tipoEdicao': tipoEdicao,
          },
        )
        .then((_) async {
          // Recarrega as transações após a edição
          await viewmodel.carregarMovimentacoes();
          (_appBarKey.currentState as dynamic)?.atualizarSaldo();
        });
  }

  void _showConfirmDeleteDialog(
    BuildContext context,
    MovimentacaoModel movimentacao, [
    String? tipoRemocao,
  ]) {
    final helper = AppThemeHelper.of(context);

    // Define o texto baseado no tipo de remoção
    String titulo = 'Confirmar Exclusão';
    String mensagem;
    String botaoConfirmar = 'Excluir';

    switch (tipoRemocao) {
      case 'apenas_esta':
        mensagem =
            'Tem certeza que deseja excluir apenas esta ocorrência da transação "${movimentacao.nome}"?';
        break;
      case 'desta_pra_frente':
        mensagem =
            'Tem certeza que deseja excluir esta e todas as próximas ocorrências da transação "${movimentacao.nome}"?';
        break;
      case 'todas_relacionadas':
        mensagem =
            'Tem certeza que deseja excluir DEFINITIVAMENTE todas as ocorrências da transação "${movimentacao.nome}"?';
        botaoConfirmar = 'Excluir Tudo';
        break;
      default:
        mensagem =
            'Tem certeza que deseja excluir a transação "${movimentacao.nome}"?';
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: helper.colorScheme.error,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: helper.onSurfaceColor,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            mensagem,
            style: TextStyle(
              fontSize: 16,
              color: helper.onSurfaceColor.withOpacity(0.8),
              fontFamily: 'Poppins',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: helper.onSurfaceColor.withOpacity(0.7),
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                // Executa a remoção baseada no tipo
                switch (tipoRemocao) {
                  case 'apenas_esta':
                    await viewmodel.removerMovimentacao(movimentacao);
                    break;
                  case 'desta_pra_frente':
                    await viewmodel.removerTransacoesDestaPraFrente(
                      movimentacao,
                    );
                    break;
                  case 'todas_relacionadas':
                    await viewmodel.removerTransacoesRelacionadas(movimentacao);
                    break;
                  default:
                    // Transação única
                    await viewmodel.removerMovimentacao(movimentacao);
                }

                // Atualiza o saldo
                (_appBarKey.currentState as dynamic)?.atualizarSaldo();

                // Mostra confirmação
                if (context.mounted) {
                  final msg =
                      tipoRemocao == 'todas_relacionadas'
                          ? 'Todas as ocorrências foram excluídas'
                          : tipoRemocao == 'desta_pra_frente'
                          ? 'Transações a partir desta data foram excluídas'
                          : 'Transação excluída com sucesso';
                  ToastificationUtils.success(title: msg, context: context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: helper.colorScheme.error,
                foregroundColor: helper.colorScheme.onError,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                botaoConfirmar,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRemoveOptionStatic(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String value,
    required Color onSurfaceColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(value),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: onSurfaceColor,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: onSurfaceColor.withOpacity(0.7),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: onSurfaceColor.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final viewmodel = Modular.get<HomeViewmodel>();
  final GlobalKey<State<AppBarContainer>> _appBarKey =
      GlobalKey<State<AppBarContainer>>();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Remove observer ao sair da tela
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Quando a app volta para primeiro plano, recarrega categorias
    if (state == AppLifecycleState.resumed) {
      viewmodel.recarregarCategorias();
    }
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    initializeDateFormatting('pt_BR', null);

    if (!viewmodel.carregou) {
      await viewmodel.carregarCategorias();
      await viewmodel.carregarMovimentacoes();
      viewmodel.setCarregou(true);
      Future.microtask(() => viewmodel.initializeServices());
    }
  }

  void _openChatIA() {
    showDialog(context: context, builder: (context) => const ChatIADialog());
  }

  void showDialogDespesaReceita(BuildContext context) {
    final helper = AppThemeHelper.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        // Usa modalContext para evitar conflitos
        return Container(
          decoration: BoxDecoration(
            color: helper.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: helper.onSurfaceColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Nova Transação',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: helper.onSurfaceColor,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 32),
                // Botão Receita
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(modalContext).pop();
                      Modular.to
                          .pushNamed(
                            '${HomeNomeRotas.navigate}${NovaTransacaoNomeRotas.navigateReceita}',
                          )
                          .then((_) async {
                            await viewmodel.carregarMovimentacoes();
                            (_appBarKey.currentState as dynamic)
                                ?.atualizarSaldo();
                          });
                    },
                    icon: Icon(
                      Icons.trending_up,
                      color: helper.colorScheme.onPrimary,
                      size: 24,
                    ),
                    label: Text(
                      'Receita',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: helper.colorScheme.onPrimary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: helper.colorScheme.primary,
                      foregroundColor: helper.colorScheme.onPrimary,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Botão Despesa
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(modalContext).pop();
                      Modular.to
                          .pushNamed(
                            '${HomeNomeRotas.navigate}${NovaTransacaoNomeRotas.navigateDespesa}',
                          )
                          .then((_) async {
                            await viewmodel.carregarMovimentacoes();
                            (_appBarKey.currentState as dynamic)
                                ?.atualizarSaldo();
                          });
                    },
                    icon: Icon(
                      Icons.trending_down,
                      color: helper.colorScheme.onError,
                      size: 24,
                    ),
                    label: Text(
                      'Despesa',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: helper.colorScheme.onError,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: helper.colorScheme.error,
                      foregroundColor: helper.colorScheme.onError,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Botão Cancelar
                TextButton(
                  onPressed: () => Navigator.of(modalContext).pop(),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      fontSize: 16,
                      color: helper.onSurfaceColor.withOpacity(0.7),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFilterModal(BuildContext context) {
    final helper = AppThemeHelper.of(context);
    final vm = viewmodel;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return Container(
          decoration: BoxDecoration(
            color: helper.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: helper.onSurfaceColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Filtros',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: helper.onSurfaceColor,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 32),
                // Filtros por período
                _sectionHeader(helper, Icons.calendar_month, 'Período'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: modalContext,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) vm.setFilterPeriodo(inicio: date);
                        },
                        icon: const Icon(Icons.date_range),
                        label: Text(
                          'Início',
                          style: TextStyle(color: helper.onSurfaceColor),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: helper.colorScheme.primary,
                          side: BorderSide(
                            color: helper.onSurfaceColor.withOpacity(0.2),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: modalContext,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) vm.setFilterPeriodo(fim: date);
                        },
                        icon: const Icon(Icons.event),
                        label: Text(
                          'Fim',
                          style: TextStyle(color: helper.onSurfaceColor),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: helper.colorScheme.primary,
                          side: BorderSide(
                            color: helper.onSurfaceColor.withOpacity(0.2),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Switch(
                      value: vm.limitToCurrentMonth,
                      onChanged: (v) => vm.setLimitToCurrentMonth(v),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Limitar ao mês atual (AppBar)',
                        style: TextStyle(
                          color: helper.onSurfaceColor.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Filtros por tipo
                _sectionHeader(
                  helper,
                  Icons.swap_vert_circle_outlined,
                  'Tipo de Transação',
                ),
                const SizedBox(height: 10),
                Observer(
                  builder: (_) {
                    return Wrap(
                      spacing: 8,
                      children: [
                        _choiceChip(
                          helper,
                          label: 'Todas',
                          selected: vm.filterIsSaida == null,
                          onSelected: (_) => vm.setFilterTipo(null),
                        ),
                        _choiceChip(
                          helper,
                          label: 'Receitas',
                          selected: vm.filterIsSaida == false,
                          onSelected: (_) => vm.setFilterTipo(false),
                        ),
                        _choiceChip(
                          helper,
                          label: 'Despesas',
                          selected: vm.filterIsSaida == true,
                          onSelected: (_) => vm.setFilterTipo(true),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Filtro por categoria
                _sectionHeader(helper, Icons.category_outlined, 'Categoria'),
                const SizedBox(height: 10),
                Observer(
                  builder: (_) {
                    return Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int?>(
                            value: vm.filterCategoryId,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              hintText: 'Selecione uma categoria',
                            ),
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('Todas as categorias'),
                              ),
                              ...vm.categoria.map(
                                (c) => DropdownMenuItem<int?>(
                                  value: c.id,
                                  child: Text(c.nome),
                                ),
                              ),
                            ],
                            onChanged: (val) => vm.setFilterCategoria(val),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Limpar categoria',
                          onPressed: () => vm.setFilterCategoria(null),
                          icon: const Icon(Icons.clear),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Filtros por valor
                _sectionHeader(helper, Icons.attach_money, 'Faixa de Valor'),
                const SizedBox(height: 10),
                Observer(
                  builder: (_) {
                    return Row(
                      children: [
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Mínimo',
                            ),
                            onSubmitted: (v) {
                              final min = double.tryParse(
                                v.replaceAll('.', '').replaceAll(',', '.'),
                              );
                              vm.setFilterValor(
                                min: min,
                                max: vm.maxValueFilter,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Máximo',
                            ),
                            onSubmitted: (v) {
                              final max = double.tryParse(
                                v.replaceAll('.', '').replaceAll(',', '.'),
                              );
                              vm.setFilterValor(
                                min: vm.minValueFilter,
                                max: max,
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),
                // Botões de ação
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          vm.limparFiltros();
                          Navigator.of(modalContext).pop();
                        },
                        child: Text(
                          'Limpar',
                          style: TextStyle(
                            color: helper.onSurfaceColor.withOpacity(0.7),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(modalContext).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: helper.colorScheme.primary,
                          foregroundColor: helper.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Aplicar',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Constrói a lista de transações agrupadas por data e ordenadas como pilha
  Widget _buildTransactionsList() {
    final list = viewmodel.filteredMovimentacoes;
    if (list.isEmpty) {
      return const SizedBox.shrink();
    }

    // 1. Agrupa as transações por data (sem ordenar ainda)
    final Map<String, List<MovimentacaoModel>> groupedByDate = {};

    for (final transaction in list) {
      String dayName = DateFormat(
        'EEEE',
        'pt_BR',
      ).format(transaction.dataMovimentacao);
      dayName = dayName.replaceAll('-feira', '');
      dayName = dayName[0].toUpperCase() + dayName.substring(1);

      final dateKey =
          '$dayName, ${DateFormat('dd', 'pt_BR').format(transaction.dataMovimentacao)}';

      if (!groupedByDate.containsKey(dateKey)) {
        groupedByDate[dateKey] = [];
      }
      groupedByDate[dateKey]!.add(transaction);
    }

    // 2. Ordena cada grupo por data/hora completa decrescente (pilha - último primeiro)
    for (final group in groupedByDate.values) {
      group.sort((a, b) => b.dataMovimentacao.compareTo(a.dataMovimentacao));
    }

    // 3. Ordena os grupos de datas por data decrescente (data mais recente primeiro)
    final sortedDateKeys =
        groupedByDate.keys.toList()..sort((a, b) {
          // Pega a primeira transação de cada grupo para comparar as datas
          final dateA = groupedByDate[a]!.first.dataMovimentacao;
          final dateB = groupedByDate[b]!.first.dataMovimentacao;
          return dateB.compareTo(dateA); // Decrescente
        });

    // 4. Constrói a lista de widgets
    final List<Widget> widgets = [];

    for (final dateKey in sortedDateKeys) {
      final transactions = groupedByDate[dateKey]!;

      // Header da data
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateKey,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppThemeHelper.of(context).onSurfaceColor,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              // Divider/underline mais grosso e da mesma cor do texto
              Container(
                height: 3,
                width: 80,
                decoration: BoxDecoration(
                  color: AppThemeHelper.of(
                    context,
                  ).onSurfaceColor.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ],
          ),
        ),
      );

      // Transações do dia (já ordenadas como pilha)
      for (final transaction in transactions) {
        widgets.add(_cardTransacao(transaction));
      }
    }

    // Adiciona espaço para o FAB
    widgets.add(const SizedBox(height: 100));

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    final helper = AppThemeHelper.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Observer para detectar mudanças no shouldOpenDialog
          Observer(
            builder: (_) {
              // Lógica igual ao app antigo: verifica shouldOpenDialog no build e abre instantaneamente
              debugPrint(
                '🏠 Home Observer: shouldOpenDialog = ${viewmodel.shouldOpenDialog}',
              );
              if (viewmodel.shouldOpenDialog) {
                debugPrint(
                  '🏠 Home Observer: Flag detectada, abrindo modal...',
                );
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  debugPrint(
                    '🏠 Home Observer: PostFrameCallback executando...',
                  );
                  showDialogDespesaReceita(context);
                  viewmodel.isDialogOpen(false);
                  debugPrint('🏠 Home Observer: Modal aberto e flag resetada');
                });
              }
              return const SizedBox.shrink();
            },
          ),

          // Conteúdo principal com header fixo
          Column(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    AppBarContainer(
                      key: _appBarKey,
                      helper: helper,
                      onMonthChanged: (novoMes) {
                        // Atualiza o mês e recarrega as transações
                        viewmodel.setDataSelecionada(novoMes);
                        viewmodel.carregarMovimentacoes();
                      },
                      onFilterPressed: () {
                        _showFilterModal(context);
                      },
                    ),
                    //if (kDebugMode)
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(
                    //     horizontal: 16,
                    //     vertical: 8,
                    //   ),
                    //   child: Align(
                    //     alignment: Alignment.centerRight,
                    //     child: Wrap(
                    //       spacing: 8,
                    //       runSpacing: 8,
                    //       children: [
                    //         ElevatedButton.icon(
                    //           onPressed: () async {
                    //             await NotificationService()
                    //                 .sendTestNotification();
                    //           },
                    //           icon: const Icon(
                    //             Icons.notifications_active_outlined,
                    //           ),
                    //           label: const Text('Testar notificação'),
                    //           style: ElevatedButton.styleFrom(
                    //             elevation: 0,
                    //             visualDensity: VisualDensity.compact,
                    //             padding: const EdgeInsets.symmetric(
                    //               horizontal: 12,
                    //               vertical: 8,
                    //             ),
                    //           ),
                    //         ),
                    //         // Debug IA: Rodar agora
                    //         ElevatedButton.icon(
                    //           onPressed: () async {
                    //             await AiDebugService().runAllNow();
                    //             if (!context.mounted) return;
                    //             ToastificationUtils.info(
                    //               title:
                    //                   'IA executada agora (rotinas, feriados, previsão)',
                    //               context: context,
                    //             );
                    //           },
                    //           icon: const Icon(Icons.play_circle_outline),
                    //           label: const Text('Rodar IA agora'),
                    //           style: ElevatedButton.styleFrom(
                    //             elevation: 0,
                    //             visualDensity: VisualDensity.compact,
                    //             padding: const EdgeInsets.symmetric(
                    //               horizontal: 12,
                    //               vertical: 8,
                    //             ),
                    //           ),
                    //         ),
                    //         // Debug IA: Reset flags
                    //         OutlinedButton.icon(
                    //           onPressed: () async {
                    //             final removed =
                    //                 await AiDebugService().resetIaFlags();
                    //             if (!context.mounted) return;
                    //             ToastificationUtils.info(
                    //               title: 'Flags de IA limpas: $removed',
                    //               context: context,
                    //             );
                    //           },
                    //           icon: const Icon(
                    //             Icons.cleaning_services_outlined,
                    //           ),
                    //           label: const Text('Resetar flags IA'),
                    //           style: OutlinedButton.styleFrom(
                    //             visualDensity: VisualDensity.compact,
                    //             padding: const EdgeInsets.symmetric(
                    //               horizontal: 12,
                    //               vertical: 8,
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    barraDePesquisa(helper),
                  ],
                ),
              ),
              // Lista de transações expansível
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await viewmodel.carregarMovimentacoes();
                  },
                  child: Observer(
                    builder: (_) {
                      if (viewmodel.carregou) {
                        if (viewmodel.movimentacoes.isEmpty) {
                          return ListView(
                            padding: const EdgeInsets.all(0),
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.receipt_long_outlined,
                                        size: 64,
                                        color: helper.onSurfaceColor
                                            .withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Nenhuma transação ainda',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: helper.onSurfaceColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Toque no + para adicionar sua primeira transação',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: helper.onSurfaceColor
                                              .withOpacity(0.7),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        final transactionsList = _buildTransactionsList();
                        return transactionsList;
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          // Chat bubble (já é Positioned internamente)
          FutureBuilder<bool>(
            future: _shouldShowChatBubble(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const SizedBox.shrink();
              }
              if (snapshot.data == false) return const SizedBox.shrink();
              return DraggableChatBubble(onTap: _openChatIA);
            },
          ),
        ],
      ),
      floatingActionButton:
          widget.embedded
              ? null
              : SizedBox(
                width: 64,
                height: 64,
                child: FloatingActionButton(
                  onPressed: () {
                    showDialogDespesaReceita(context);
                  },
                  backgroundColor: helper.colorScheme.primary,
                  foregroundColor: helper.colorScheme.onPrimary,
                  elevation: helper.brightness == Brightness.light ? 6 : 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Icon(Icons.add, size: 28),
                ),
              ),
      floatingActionButtonLocation:
          widget.embedded ? null : FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar:
          widget.embedded
              ? null
              : const CustomBottomNavigationBar(currentIndex: 0),
    );
  }

  Future<bool> _shouldShowChatBubble() async {
    try {
      final storage = Modular.get<LocalStorage>();
      final saved = await storage.read<bool>('settings.chatbot.enabled');
      // Por padrão, habilitado caso nunca tenha sido salvo
      return saved ?? true;
    } catch (_) {
      return true;
    }
  }

  Padding barraDePesquisa(AppThemeHelper helper) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Material(
        elevation: helper.brightness == Brightness.light ? 2 : 0,
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: TextField(
          style: TextStyle(
            color: helper.onSurfaceColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          cursorColor: helper.colorScheme.primary,
          onChanged: (v) => viewmodel.setSearchQuery(v),
          decoration: InputDecoration(
            filled: true,
            fillColor:
                helper.brightness == Brightness.light
                    ? const Color(0xFFECF3FB)
                    : helper.colorScheme.onSurface.withOpacity(0.08),
            prefixIcon: Icon(
              Icons.search,
              color: helper.onSurfaceColor,
              size: 22,
            ),
            hintText: 'Buscar',
            hintStyle: TextStyle(
              color: helper.onSurfaceColor.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(
                color: helper.colorScheme.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helpers visuais do filter sheet
  Widget _sectionHeader(AppThemeHelper helper, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: helper.colorScheme.primary, size: 20),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: helper.onSurfaceColor,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _choiceChip(
    AppThemeHelper helper, {
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: helper.colorScheme.primary.withOpacity(0.15),
      labelStyle: TextStyle(
        color: selected ? helper.colorScheme.primary : helper.onSurfaceColor,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor:
          helper.brightness == Brightness.light
              ? const Color(0xFFEFF3F7)
              : helper.colorScheme.onSurface.withOpacity(0.06),
    );
  }

  Widget _cardTransacao(MovimentacaoModel movimentacao) {
    final helper = AppThemeHelper.of(context);
    final isSaida = movimentacao.isSaida;

    // Cores adaptativas baseadas no tema
    final cardColor =
        isSaida
            ? helper
                .despesaCardColor // Vermelho adaptativo para DESPESAS
            : helper.receitaCardColor; // Verde adaptativo para RECEITAS

    final iconBg =
        isSaida
            ? helper
                .despesaIconColor // Ícone vermelho adaptativo para DESPESAS
            : helper.receitaIconColor; // Ícone verde adaptativo para RECEITAS

    final valueColor =
        isSaida
            ? helper
                .despesaValueColor // Valor vermelho adaptativo para DESPESA
            : helper.receitaValueColor; // Valor verde adaptativo para RECEITA

    // Captura as cores necessárias para o Slidable para evitar problemas de contexto
    final errorColor = helper.colorScheme.error;
    final onErrorColor = helper.colorScheme.onError;
    final secondaryColor = helper.colorScheme.secondary;
    final onSecondaryColor = helper.colorScheme.onSecondary;
    final surfaceColor = helper.colorScheme.surface;
    final onSurfaceColor = helper.onSurfaceColor;
    final primaryColor = helper.colorScheme.primary;
    final brightness = helper.brightness;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.4,
          children: [
            CustomSlidableAction(
              onPressed: (slidableContext) async {
                _showRemoverTransacaoBottomSheet(context, movimentacao);
              },
              padding: EdgeInsets.zero,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: errorColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete, color: onErrorColor, size: 24),
                    const SizedBox(height: 5),
                    Text(
                      'Remover',
                      style: TextStyle(color: onErrorColor, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            CustomSlidableAction(
              onPressed: (slidableContext) async {
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) {
                    return Container(
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 24,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Handle
                              Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: onSurfaceColor.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Ações da Transação',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: onSurfaceColor,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Botão Editar
                              _buildActionButtonStatic(
                                ctx,
                                icon: Icons.edit_outlined,
                                title: 'Editar Transação',
                                subtitle: 'Modificar dados desta transação',
                                color: primaryColor,
                                onSurfaceColor: onSurfaceColor,
                                onTap: () {
                                  Navigator.of(ctx).pop();
                                  _editarTransacao(context, movimentacao);
                                },
                              ),
                              const SizedBox(height: 12),
                              // Botão Duplicar
                              _buildActionButtonStatic(
                                ctx,
                                icon: Icons.copy_outlined,
                                title: 'Duplicar Transação',
                                subtitle: 'Criar uma cópia desta transação',
                                color: secondaryColor,
                                onSurfaceColor: onSurfaceColor,
                                onTap: () {
                                  Navigator.of(ctx).pop();
                                  ToastificationUtils.info(
                                    title:
                                        'Funcionalidade de duplicar em breve!',
                                    context: context,
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              // Botão Compartilhar
                              _buildActionButtonStatic(
                                ctx,
                                icon: Icons.share_outlined,
                                title: 'Compartilhar',
                                subtitle: 'Enviar detalhes por mensagem',
                                color: Colors.blue,
                                onSurfaceColor: onSurfaceColor,
                                onTap: () {
                                  Navigator.of(ctx).pop();
                                  ToastificationUtils.info(
                                    title:
                                        'Funcionalidade de compartilhar em breve!',
                                    context: context,
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                              // Botão Cancelar
                              SizedBox(
                                width: double.infinity,
                                child: TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Cancelar',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: onSurfaceColor.withOpacity(0.7),
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              padding: EdgeInsets.zero,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.more_horiz, color: onSecondaryColor, size: 24),
                    const SizedBox(height: 5),
                    Text(
                      'Mais',
                      style: TextStyle(color: onSecondaryColor, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        child: Material(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          elevation: brightness == Brightness.light ? 2 : 0,
          shadowColor: Colors.black.withOpacity(0.07),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              _showDetalhesTransacaoModal(context, movimentacao);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // Left side (icon + title/category) takes remaining width
                  Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: iconBg,
                          child: Icon(
                            CategoryIconService.getIconData(
                              viewmodel.categoria
                                  .firstWhere(
                                    (e) => movimentacao.idCategoria == e.id,
                                    orElse:
                                        () => CategoriaModel(
                                          id: 0,
                                          nome: 'Categoria não encontrada',
                                          icone: 'category',
                                        ),
                                  )
                                  .icone,
                            ),
                            color: helper.colorScheme.onPrimary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Make the text column flexible so long names ellipsize
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                movimentacao.nome,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: helper.onSurfaceColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                viewmodel.categoria
                                    .firstWhere(
                                      (e) => movimentacao.idCategoria == e.id,
                                      orElse:
                                          () => CategoriaModel(
                                            id: 0,
                                            nome: 'Categoria não encontrada',
                                          ),
                                    )
                                    .nome,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: helper.onSurfaceColor.withOpacity(0.7),
                                ),
                              ),
                              if (movimentacao.idCategoria == 9)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: helper.colorScheme.primary
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Sugestão de IA',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 10,
                                      color: helper.colorScheme.primary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Ensure a small gap between title area and value
                  const SizedBox(width: 8),
                  Text(
                    viewmodel.canSeeValue
                        ? NumberFormat.currency(
                          locale: 'pt_BR',
                          symbol: 'R\$',
                          decimalDigits: 2,
                        ).format(movimentacao.valor)
                        : 'R\$ ***',
                    style: TextStyle(
                      color: valueColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
