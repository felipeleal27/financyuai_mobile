import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:neo_financyuai/app/utils/app_theme_helper.dart';
import 'package:neo_financyuai/app/service/auth_service.dart';
import 'package:neo_financyuai/app/utils/environments.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart';
import 'package:neo_financyuai/app/widgets/cached_user_avatar_sqlite.dart';
import 'package:neo_financyuai/app/repository/chat_repository.dart';
import 'package:neo_financyuai/app/utils/toastification_utils.dart';

class ChatIADialog extends StatefulWidget {
  const ChatIADialog({super.key});

  @override
  State<ChatIADialog> createState() => _ChatIADialogState();
}

class _ChatIADialogState extends State<ChatIADialog> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;
  final ChatRepository _chatRepo = ChatRepository();
  String? _sessionId;
  bool _didInitialScroll = false; // ensures first paint starts at bottom

  @override
  void initState() {
    super.initState();
    _bootstrapSessionAndLoadHistory();
  }

  Future<void> _bootstrapSessionAndLoadHistory() async {
    final auth = AuthService();
    final uid = auth.userId ?? 'anonymous';
    final session = await _chatRepo.getOrCreateSession(
      uid,
      sessionId: 'mobile_${uid}_default',
    );
    _sessionId = session.id;
    final history = await _chatRepo.getMessages(session.id);
    // Remove qualquer placeholder antigo de digitação salvo no passado
    final filtered =
        history
            .where(
              (m) => !(m.isUser == false && m.content.trim() == 'Digitando…'),
            )
            .toList();
    setState(() {
      _messages.clear();
      if (filtered.isEmpty) {
        _messages.add(
          ChatMessage(
            text: 'Olá! 👋 Como posso te ajudar hoje?',
            isUser: false,
          ),
        );
      } else {
        _messages.addAll(
          filtered.map((e) => ChatMessage(text: e.content, isUser: e.isUser)),
        );
      }
    });
    _jumpToBottom();
    _didInitialScroll = true;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addMessage(String text, {required bool isUser, bool persist = true}) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: isUser));
    });
    // Persist only real messages (skip typing placeholders)
    if (persist) {
      final sid = _sessionId;
      if (sid != null) {
        _chatRepo.saveMessage(
          ChatMessageEntity(
            sessionId: sid,
            isUser: isUser,
            content: text,
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        );
      }
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    // On first paint, prefer a jump to avoid long animations on big histories
    if (!_didInitialScroll) {
      _jumpToBottom();
      _didInitialScroll = true;
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _jumpToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        try {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        } catch (_) {}
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _addMessage(text, isUser: true);
    _messageController.clear();
    _callAgent(text);
  }

  Future<void> _callAgent(String userText) async {
    if (_isSending) return;
    setState(() => _isSending = true);

    // Mostrar indicador de digitação
    _addMessage('Digitando…', isUser: false, persist: false);

    final auth = AuthService();
    final uid = auth.userId ?? 'anonymous';
    final idToken = await auth.getIdToken();
    if (kDebugMode && idToken != null) {
      debugPrint('🔐 Firebase ID token (dialog): $idToken');
    }
    final sid = _sessionId ?? (await _chatRepo.getOrCreateSession(uid)).id;
    _sessionId = sid;
    final body = {
      'message': userText,
      'userId': uid,
      'sessionId': sid,
      'channel': 'mobile_app',
      'userName': auth.userName ?? 'Usuário',
      'dataAtual': DateTime.now().toIso8601String(),
    };
    if (idToken != null) {
      body['idToken'] = idToken;
    }

    try {
      final uri = _buildN8nUri();
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      // Remove a última mensagem (Digitando…)
      _removeLastAssistantTyping();

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        String reply;
        try {
          final data = jsonDecode(resp.body);
          reply =
              data['reply']?.toString() ??
              data['message']?.toString() ??
              resp.body;
        } catch (_) {
          reply = resp.body;
        }
        _addMessage(reply, isUser: false);
      } else if ((resp.statusCode == 401 || resp.statusCode == 403) && idToken == null) {
        _addMessage(
          'Sua sessão expirou. Faça login novamente para liberar suas transações para a IA.',
          isUser: false,
        );
      } else {
        _addMessage(
          'Erro ${resp.statusCode}: não foi possível obter resposta da IA.',
          isUser: false,
        );
      }
    } catch (_) {
      _removeLastAssistantTyping();
      _addMessage('Falha na conexão com o agente IA', isUser: false);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _removeLastAssistantTyping() {
    if (_messages.isNotEmpty) {
      final last = _messages.last;
      if (!last.isUser && (last.text == 'Digitando…')) {
        setState(() {
          _messages.removeLast();
        });
      }
    }
  }

  Uri _buildN8nUri() {
    final base = (Environments.param('N8N_BASE_URL') ?? '').trim();
    final path =
        (Environments.param('N8N_WEBHOOK_PATH') ?? '/webhook/ai/quest').trim();
    String baseUrl;
    if (base.isNotEmpty) {
      baseUrl = base;
    } else {
      if (Platform.isAndroid) {
        // baseUrl = 'http://10.0.2.2:5678';
        baseUrl = 'https://financyuai-n8n.onrender.com';
      } else {
        // baseUrl = 'http://localhost:5678';
        baseUrl = 'https://financyuai-n8n.onrender.com';
      }
    }

    final normalizedBase =
        baseUrl.endsWith('/')
            ? baseUrl.substring(0, baseUrl.length - 1)
            : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = ('$normalizedBase$normalizedPath');
    return Uri.parse(uri);
  }

  @override
  Widget build(BuildContext context) {
    final helper = AppThemeHelper.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.transparent,
      child: Container(
        height: helper.screenHeight * 0.7,
        decoration: BoxDecoration(
          color: helper.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: helper.colorScheme.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: helper.colorScheme.primary,
                    child: Icon(
                      LucideIcons.sparkle,
                      color: helper.colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assistente IA',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: helper.onSurfaceColor,
                          ),
                        ),
                        Text(
                          'Online',
                          style: TextStyle(
                            fontSize: 12,
                            color: helper.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tooltip(
                    message: 'Novo chat',
                    child: IconButton(
                      onPressed: () async {
                        final auth = AuthService();
                        final uid = auth.userId ?? 'anonymous';
                        final session = await _chatRepo.createNewSession(uid);
                        if (!mounted) return;
                        setState(() {
                          _sessionId = session.id;
                          _messages
                            ..clear()
                            ..add(
                              ChatMessage(
                                text: 'Novo chat criado. Como posso ajudar?',
                                isUser: false,
                              ),
                            );
                        });
                        _scrollToBottom();
                      },
                      icon: Icon(
                        LucideIcons.plus,
                        color: helper.onSurfaceColor,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: helper.onSurfaceColor),
                  ),
                ],
              ),
            ),
            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  // Só mostra indicador de digitação para a ÚLTIMA mensagem e somente se for o placeholder
                  final isTyping =
                      index == _messages.length - 1 &&
                      !msg.isUser &&
                      msg.text == 'Digitando…';
                  return isTyping
                      ? _TypingRow(helper: helper)
                      : _ChatBubble(message: msg, helper: helper);
                },
              ),
            ),
            // Input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: helper.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: helper.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 120),
                      child: TextField(
                        controller: _messageController,
                        maxLines: null,
                        minLines: 1,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        scrollPhysics: const BouncingScrollPhysics(),
                        decoration: InputDecoration(
                          hintText: 'Digite sua pergunta...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: helper.colorScheme.surfaceVariant,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton.small(
                    onPressed: _sendMessage,
                    backgroundColor: helper.colorScheme.primary,
                    child: Icon(
                      Icons.send,
                      color: helper.colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final AppThemeHelper helper;

  const _ChatBubble({required this.message, required this.helper});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: helper.colorScheme.primary,
              child: Icon(
                Icons.smart_toy,
                color: helper.colorScheme.onPrimary,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color:
                      message.isUser
                          ? helper.colorScheme.primary
                          : helper.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(18),
                  border:
                      message.isUser
                          ? null
                          : Border.all(
                            color: helper.colorScheme.outline.withOpacity(0.2),
                          ),
                  boxShadow:
                      message.isUser
                          ? null
                          : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                ),
                child:
                    message.isUser
                        ? Text(
                          message.text,
                          style: TextStyle(
                            color: helper.colorScheme.onPrimary,
                            fontSize: 14,
                          ),
                        )
                        : Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 28.0),
                              child: MarkdownBody(
                                selectable: true,
                                data: message.text,
                                styleSheet: MarkdownStyleSheet(
                                  p: TextStyle(
                                    color: helper.onSurfaceColor,
                                    fontSize: 14,
                                  ),
                                  a: TextStyle(
                                    color: helper.colorScheme.primary,
                                  ),
                                  listBullet: TextStyle(
                                    color: helper.onSurfaceColor,
                                    fontSize: 14,
                                  ),
                                  code: TextStyle(
                                    backgroundColor: helper.colorScheme.surface,
                                    fontFamily: 'monospace',
                                    fontSize: 13,
                                    color: helper.colorScheme.primary,
                                  ),
                                  strong: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  em: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                  blockquotePadding: const EdgeInsets.all(8),
                                  blockquoteDecoration: BoxDecoration(
                                    color: helper.colorScheme.surface,
                                    border: Border(
                                      left: BorderSide(
                                        color: helper.colorScheme.outline,
                                        width: 4,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Tooltip(
                                message: 'Copiar tudo',
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () async {
                                    final messenger = ScaffoldMessenger.maybeOf(
                                      context,
                                    );
                                    await Clipboard.setData(
                                      ClipboardData(text: message.text),
                                    );
                                    messenger?.clearSnackBars();
                                    if (!context.mounted) return;
                                    ToastificationUtils.info(
                                      title: 'Mensagem copiada',
                                      context: context,
                                    );
                                  },
                                  child: Icon(
                                    Icons.copy_rounded,
                                    size: 18,
                                    color: helper.onSurfaceColor.withOpacity(
                                      0.6,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            const CachedUserAvatar(
              radius: 16,
              fallbackIcon: Icons.person,
              fallbackIconSize: 16,
            ),
          ],
        ],
      ),
    );
  }
}

class _TypingRow extends StatelessWidget {
  final AppThemeHelper helper;
  const _TypingRow({required this.helper});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: helper.colorScheme.primary,
            child: Icon(
              Icons.smart_toy,
              color: helper.colorScheme.onPrimary,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: helper.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Dot(),
                SizedBox(width: 4),
                _Dot(),
                SizedBox(width: 4),
                _Dot(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  const _Dot();

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _a = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _a,
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: Colors.black38,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}
