import 'package:flutter/material.dart';
import 'package:neo_financyuai/app/utils/app_theme_helper.dart';

class DraggableChatBubble extends StatefulWidget {
  final VoidCallback onTap;

  const DraggableChatBubble({
    super.key,
    required this.onTap,
  });

  @override
  State<DraggableChatBubble> createState() => _DraggableChatBubbleState();
}

class _DraggableChatBubbleState extends State<DraggableChatBubble>
    with TickerProviderStateMixin {
  late Offset position;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    // Posição inicial será definida no didChangeDependencies para ter acesso ao tamanho da tela
    position = const Offset(0, 0);
    
    // Animação de pulsação
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Define posição inicial no canto inferior direito, abaixo do AppBarContainer
    final screenSize = MediaQuery.of(context).size;
    if (position == const Offset(0, 0)) {
      setState(() {
        position = Offset(
          screenSize.width - 80, // 56 (largura) + 24 (margem)
          screenSize.height - 200, // Posição próxima ao bottom navigation
        );
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final helper = AppThemeHelper.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanStart: (_) {
          setState(() {
            _isDragging = true;
          });
        },
        onPanUpdate: (details) {
          setState(() {
            final newX = position.dx + details.delta.dx;
            final newY = position.dy + details.delta.dy;
            
            position = Offset(
              newX.clamp(0, screenSize.width - 56),
              newY.clamp(200, screenSize.height - 150), // Limite superior: 200px (abaixo do AppBarContainer)
            );
          });
        },
        onPanEnd: (_) {
          setState(() {
            _isDragging = false;
          });
          // Snap para as bordas se estiver próximo
          _snapToEdge(screenSize);
        },
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {              return Transform.scale(
                scale: _isDragging ? 1.1 : _pulseAnimation.value,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        helper.colorScheme.primary,
                        helper.colorScheme.primary.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: helper.colorScheme.onSurface.withOpacity(0.1),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: helper.colorScheme.primary.withOpacity(0.4),
                        blurRadius: _isDragging ? 16 : 12,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.smart_toy,
                    color: helper.colorScheme.onPrimary,
                    size: 28,
                  ),
                ),
              );
          },
        ),
      ),
    );
  }

  void _snapToEdge(Size screenSize) {
    const margin = 16.0;
    final centerX = screenSize.width / 2;

    setState(() {
      // Só faz snap horizontal (esquerda ou direita)
      if (position.dx < centerX) {
        // Snap para a esquerda
        position = Offset(margin, position.dy);
      } else {
        // Snap para a direita
        position = Offset(screenSize.width - 56 - margin, position.dy);
      }
      
      // Garante que não saia dos limites verticais (abaixo do AppBarContainer)
      position = Offset(
        position.dx,
        position.dy.clamp(200, screenSize.height - 150),
      );
    });
  }
}
