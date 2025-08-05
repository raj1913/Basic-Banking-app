import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/card.dart';

class PlayingCardWidget extends StatelessWidget {
  final PlayingCard? card;
  final bool isPlaceholder;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool showShadow;
  final double width;
  final double height;

  const PlayingCardWidget({
    super.key,
    this.card,
    this.isPlaceholder = false,
    this.onTap,
    this.isSelected = false,
    this.showShadow = true,
    this.width = 60,
    this.height = 84,
  });

  @override
  Widget build(BuildContext context) {
    if (isPlaceholder) {
      return _buildPlaceholder();
    }

    if (card == null) {
      return SizedBox(width: width, height: height);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: showShadow && !card!.isDragging
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
          border: isSelected
              ? Border.all(color: Colors.blue, width: 2)
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: card!.isFaceUp ? _buildFaceUpCard() : _buildFaceDownCard(),
        ),
      )
          .animate(target: card!.isDragging ? 1 : 0)
          .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1))
          .elevation(begin: 0, end: 8),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 2,
          style: BorderStyle.solid,
        ),
        color: Colors.grey.withOpacity(0.1),
      ),
    );
  }

  Widget _buildFaceDownCard() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E3A8A),
            const Color(0xFF3B82F6),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Stack(
        children: [
          // Pattern background
          Positioned.fill(
            child: CustomPaint(
              painter: CardBackPainter(),
            ),
          ),
          // Center design
          Center(
            child: Container(
              width: width * 0.6,
              height: height * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.star,
                color: Colors.white.withOpacity(0.4),
                size: width * 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaceUpCard() {
    final isRed = card!.isRed;
    final textColor = isRed ? Colors.red[700]! : Colors.black87;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Stack(
        children: [
          // Top left corner
          Positioned(
            top: 4,
            left: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  card!.rankSymbol,
                  style: TextStyle(
                    fontSize: width * 0.2,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 0.9,
                  ),
                ),
                Text(
                  card!.suitSymbol,
                  style: TextStyle(
                    fontSize: width * 0.2,
                    color: textColor,
                    height: 0.8,
                  ),
                ),
              ],
            ),
          ),
          // Bottom right corner (rotated)
          Positioned(
            bottom: 4,
            right: 4,
            child: Transform.rotate(
              angle: 3.14159, // 180 degrees
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    card!.rankSymbol,
                    style: TextStyle(
                      fontSize: width * 0.2,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      height: 0.9,
                    ),
                  ),
                  Text(
                    card!.suitSymbol,
                    style: TextStyle(
                      fontSize: width * 0.2,
                      color: textColor,
                      height: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Center suit symbol
          Center(
            child: Text(
              card!.suitSymbol,
              style: TextStyle(
                fontSize: width * 0.4,
                color: textColor.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CardBackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;

    // Draw diamond pattern
    final path = Path();
    final stepX = size.width / 8;
    final stepY = size.height / 10;

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 10; j++) {
        final x = i * stepX + stepX / 2;
        final y = j * stepY + stepY / 2;

        path.moveTo(x, y - stepY / 4);
        path.lineTo(x + stepX / 4, y);
        path.lineTo(x, y + stepY / 4);
        path.lineTo(x - stepX / 4, y);
        path.close();
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DraggableCardWidget extends StatelessWidget {
  final PlayingCard card;
  final Widget child;
  final String fromLocation;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnd;

  const DraggableCardWidget({
    super.key,
    required this.card,
    required this.child,
    required this.fromLocation,
    this.onDragStarted,
    this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<Map<String, dynamic>>(
      data: {
        'card': card,
        'from': fromLocation,
      },
      feedback: Transform.scale(
        scale: 1.1,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: child,
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: child,
      ),
      onDragStarted: () {
        card.isDragging = true;
        onDragStarted?.call();
      },
      onDragEnd: (_) {
        card.isDragging = false;
        onDragEnd?.call();
      },
      child: child,
    );
  }
}