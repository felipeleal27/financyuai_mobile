import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:neo_financyuai/app/utils/app_theme_helper.dart';
import 'package:neo_financyuai/app/service/auth_service.dart';
import 'package:neo_financyuai/app/utils/environments.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:neo_financyuai/app/repository/chat_repository.dart';

class ChatIAPage extends StatefulWidget {
  const ChatIAPage({super.key});

  @override
  State<ChatIAPage> createState() => _ChatIAPageState();
}

class _ChatIAPageState extends State<ChatIAPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;
  final ChatRepository _chatRepo = ChatRepository();
  String? _sessionId;
  bool _didInitialScroll = false;

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
      sessionId: 'mobile_${uid}_page',
    );
    _sessionId = session.id;
    final history = await _chatRepo.getMessages(session.id);
    final filtered = history.where((m) => !(m.isUser == false && m.content.trim() == 'Digitando…')).toList();
    setState(() {
      _messages.clear();
      if (filtered.isEmpty) {
        _messages.add(ChatMessage(text: 'Olá! 👋 Como posso te ajudar hoje?', isUser: false));
      } else {
        _messages.addAll(filtered.map((e) => ChatMessage(text: e.content, isUser: e.isUser)));
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
    if (persist) {
      final sid = _sessionId;
      if (sid != null) {
        _chatRepo.saveMessage(ChatMessageEntity(
          sessionId: sid,
          isUser: isUser,
          content: text,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ));
      }
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
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
    _addMessage('Digitando…', isUser: false, persist: false);

    final auth = AuthService();
    final uid = auth.userId ?? 'anonymous';
    final idToken = await auth.getIdToken();
    if (kDebugMode && idToken != null) {
      debugPrint('🔐 Firebase ID token para testes: $idToken');
    }
    final sid = _sessionId ?? (await _chatRepo.getOrCreateSession(uid)).id;
    _sessionId = sid;
    final body = <String, dynamic>{
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
      final resp = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));

      _removeLastAssistantTyping();

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        String reply;
        try {
          final data = jsonDecode(resp.body);
          reply = data['reply']?.toString() ?? data['message']?.toString() ?? resp.body;
        } catch (_) {
          reply = resp.body;
        }
        _addMessage(reply, isUser: false);
      } else if ((resp.statusCode == 401 || resp.statusCode == 403) && idToken == null) {
        _addMessage('Sua sessão expirou. Faça login novamente para liberar suas transações para a IA.', isUser: false);
      } else {
        _addMessage('Erro ${resp.statusCode}: não foi possível obter resposta da IA.', isUser: false);
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
    final path = (Environments.param('N8N_WEBHOOK_PATH') ?? '/webhook-test/ai/quest').trim();
    String baseUrl;
    if (base.isNotEmpty) {
      baseUrl = base;
    } else {
      if (Platform.isAndroid) {
        baseUrl = 'https://financyuai-n8n.onrender.com';
      } else {
        baseUrl = 'https://financyuai-n8n.onrender.com';
      }
    }
    final normalizedBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = ('$normalizedBase$normalizedPath');
    return Uri.parse(uri);
  }

  @override
  Widget build(BuildContext context) {
    final helper = AppThemeHelper.of(context);
    return Scaffold(
      backgroundColor: helper.surfaceColor,
      appBar: AppBar(
        backgroundColor: helper.surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'Assistente IA',
          style: TextStyle(
            color: helper.onSurfaceColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: helper.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.arrow_back_ios_new, color: helper.colorScheme.primary, size: 16),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
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
                    ..add(ChatMessage(text: 'Novo chat criado. Como posso ajudar?', isUser: false));
                });
                _scrollToBottom();
              },
              icon: Icon(LucideIcons.plus, color: helper.onSurfaceColor),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isTyping = index == _messages.length - 1 && !msg.isUser && msg.text == 'Digitando…';
                return isTyping ? _TypingRow(helper: helper) : _ChatBubble(message: msg, helper: helper);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: helper.colorScheme.surface,
              border: Border(top: BorderSide(color: helper.colorScheme.outline.withOpacity(0.2))),
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton.small(
                  onPressed: _isSending ? null : _sendMessage,
                  backgroundColor: helper.colorScheme.primary,
                  child: Icon(Icons.send, color: helper.colorScheme.onPrimary),
                ),
              ],
            ),
          ),
        ],
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
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: helper.colorScheme.primary,
              child: Icon(Icons.smart_toy, color: helper.colorScheme.onPrimary, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: message.isUser ? helper.colorScheme.primary : helper.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(18),
                  border: message.isUser ? null : Border.all(color: helper.colorScheme.outline.withOpacity(0.2)),
                  boxShadow: message.isUser ? null : [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: message.isUser
                    ? Text(message.text, style: TextStyle(color: helper.colorScheme.onPrimary, fontSize: 14))
                    : MarkdownBody(
                        selectable: true,
                        data: message.text,
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(color: helper.onSurfaceColor, fontSize: 14),
                          a: TextStyle(color: helper.colorScheme.primary),
                          listBullet: TextStyle(color: helper.onSurfaceColor, fontSize: 14),
                          code: TextStyle(backgroundColor: helper.colorScheme.surface, fontFamily: 'monospace', fontSize: 13, color: helper.colorScheme.primary),
                          codeblockPadding: const EdgeInsets.all(12),
                          codeblockDecoration: BoxDecoration(color: helper.colorScheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: helper.colorScheme.outline.withOpacity(0.2))),
                        ),
                      ),
              ),
            ),
          ),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(radius: 16, backgroundColor: helper.colorScheme.primary, child: Icon(Icons.smart_toy, color: helper.colorScheme.onPrimary, size: 16)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: helper.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: helper.colorScheme.outline.withOpacity(0.2)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Dot(),
              SizedBox(width: 4),
              _Dot(delay: 200),
              SizedBox(width: 4),
              _Dot(delay: 400),
            ],
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({this.delay = 0});
  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat();
    _animation = Tween<double>(begin: 0.4, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) setState(() {});
    });
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) { return FadeTransition(opacity: _animation, child: const Text('•', style: TextStyle(fontSize: 18))); }
}

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}
