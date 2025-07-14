import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:neo_financyuai/app/utils/app_theme_helper.dart';

class ChatIADialog extends StatefulWidget {
  const ChatIADialog({super.key});

  @override
  State<ChatIADialog> createState() => _ChatIADialogState();
}

class _ChatIADialogState extends State<ChatIADialog> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Mensagem de boas-vindas simples
    _addMessage(
      'Olá! 👋 Chat IA em desenvolvimento. Por enquanto só recebo suas mensagens!',
      isUser: false,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addMessage(String text, {required bool isUser}) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: isUser));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _addMessage(text, isUser: true);
    _messageController.clear();

    // Por enquanto só ecoa a mensagem até integrar IA real
    Future.delayed(const Duration(milliseconds: 1000), () {
      _addMessage(
        '\nAinda estou aprendendo! Em breve terei respostas inteligentes. 🤖',
        isUser: false,
      );
    });
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
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: helper.onSurfaceColor,
                    ),
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
                  return _ChatBubble(
                    message: _messages[index],
                    helper: helper,
                  );
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
                      constraints: const BoxConstraints(
                        maxHeight: 120, // Limite máximo de altura (aproximadamente 4-5 linhas)
                      ),
                      child: TextField(
                        controller: _messageController,
                        maxLines: null, // Permite múltiplas linhas
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

  const _ChatBubble({
    required this.message,
    required this.helper,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: message.isUser
                    ? helper.colorScheme.primary
                    : helper.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser
                      ? helper.colorScheme.onPrimary
                      : helper.onSurfaceColor,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: helper.colorScheme.secondary,
              child: Icon(
                Icons.person,
                color: helper.colorScheme.onSecondary,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({
    required this.text,
    required this.isUser,
  });
}
