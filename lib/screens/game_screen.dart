import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../providers/solitaire_provider.dart';
import '../widgets/playing_card_widget.dart';
import '../models/card.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _winAnimationController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _winAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _winAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F5132),
      appBar: AppBar(
        backgroundColor: const Color(0xFF198754),
        title: const Text(
          'Solitaire',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Consumer<SolitaireProvider>(
            builder: (context, provider, child) {
              return Row(
                children: [
                  Text(
                    'Score: ${provider.gameState.score}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Moves: ${provider.gameState.moves}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                ],
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Consumer<SolitaireProvider>(
            builder: (context, provider, child) {
              if (provider.gameState.isGameWon) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _confettiController.play();
                  _winAnimationController.forward();
                });
              }

              return Column(
                children: [
                  // Top row: Stock, Waste, and Foundation piles
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Stock pile
                        _buildStockPile(provider),
                        const SizedBox(width: 16),
                        // Waste pile
                        _buildWastePile(provider),
                        const Spacer(),
                        // Foundation piles
                        ..._buildFoundationPiles(provider),
                      ],
                    ),
                  ),
                  // Tableau area
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildTableau(provider),
                    ),
                  ),
                  // Bottom controls
                  _buildBottomControls(provider),
                ],
              );
            },
          ),
          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 1.5708, // radians for down
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.05,
            ),
          ),
          // Win dialog
          Consumer<SolitaireProvider>(
            builder: (context, provider, child) {
              if (provider.gameState.isGameWon) {
                return _buildWinDialog(provider);
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStockPile(SolitaireProvider provider) {
    return GestureDetector(
      onTap: () => provider.drawFromStock(),
      child: Container(
        width: 70,
        height: 98,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: provider.gameState.stock.isEmpty
            ? const Icon(
                Icons.refresh,
                color: Colors.white54,
                size: 32,
              )
            : PlayingCardWidget(
                card: provider.gameState.stock.last,
                width: 70,
                height: 98,
              ),
      ),
    );
  }

  Widget _buildWastePile(SolitaireProvider provider) {
    return DragTarget<Map<String, dynamic>>(
      onAcceptWithDetails: (details) {
        // Waste pile doesn't accept cards
      },
      builder: (context, candidateData, rejectedData) {
        return SizedBox(
          width: 70,
          height: 98,
          child: Stack(
            children: provider.gameState.waste.asMap().entries.map((entry) {
              final index = entry.key;
              final card = entry.value;
              final isTop = index == provider.gameState.waste.length - 1;
              
              return Positioned(
                left: index * 2.0,
                top: index * 1.0,
                child: isTop
                    ? DraggableCardWidget(
                        card: card,
                        fromLocation: 'waste',
                        child: PlayingCardWidget(
                          card: card,
                          width: 70,
                          height: 98,
                          onTap: () => provider.tryAutoMoveToFoundation(card, 'waste'),
                        ),
                      )
                    : PlayingCardWidget(
                        card: card,
                        width: 70,
                        height: 98,
                      ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  List<Widget> _buildFoundationPiles(SolitaireProvider provider) {
    return List.generate(4, (index) {
      final pile = provider.gameState.foundation[index];
      return Padding(
        padding: const EdgeInsets.only(left: 8),
        child: DragTarget<Map<String, dynamic>>(
          onAcceptWithDetails: (details) {
            final card = details.data['card'] as PlayingCard;
            final from = details.data['from'] as String;
            provider.moveCardToFoundation(card, from, index);
          },
          builder: (context, candidateData, rejectedData) {
            final isHighlighted = candidateData.isNotEmpty;
            return Container(
              width: 70,
              height: 98,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isHighlighted 
                      ? Colors.yellow 
                      : Colors.white.withOpacity(0.3),
                  width: isHighlighted ? 3 : 1,
                ),
                color: isHighlighted 
                    ? Colors.yellow.withOpacity(0.2) 
                    : null,
              ),
              child: pile.isEmpty
                  ? PlayingCardWidget(
                      card: null,
                      isPlaceholder: true,
                      width: 70,
                      height: 98,
                    )
                  : PlayingCardWidget(
                      card: pile.last,
                      width: 70,
                      height: 98,
                    ),
            );
          },
        ),
      );
    });
  }

  Widget _buildTableau(SolitaireProvider provider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(7, (columnIndex) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildTableauColumn(provider, columnIndex),
          ),
        );
      }),
    );
  }

  Widget _buildTableauColumn(SolitaireProvider provider, int columnIndex) {
    final pile = provider.gameState.tableau[columnIndex];
    
    return DragTarget<Map<String, dynamic>>(
      onAcceptWithDetails: (details) {
        final card = details.data['card'] as PlayingCard;
        final from = details.data['from'] as String;
        provider.moveCardsToTableau([card], from, columnIndex);
      },
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;
        
        return Container(
          constraints: const BoxConstraints(minHeight: 400),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: pile.isEmpty && isHighlighted
                ? Border.all(color: Colors.yellow, width: 3)
                : null,
            color: pile.isEmpty && isHighlighted
                ? Colors.yellow.withOpacity(0.2)
                : null,
          ),
          child: pile.isEmpty
              ? PlayingCardWidget(
                  card: null,
                  isPlaceholder: true,
                  width: 50,
                  height: 70,
                )
              : Column(
                  children: pile.asMap().entries.map((entry) {
                    final index = entry.key;
                    final card = entry.value;
                    final isLast = index == pile.length - 1;
                    
                    return Padding(
                      padding: EdgeInsets.only(
                        top: index == 0 ? 0 : (card.isFaceUp ? 20 : 8),
                      ),
                      child: card.isFaceUp
                          ? DraggableCardWidget(
                              card: card,
                              fromLocation: 'tableau_$columnIndex',
                              child: PlayingCardWidget(
                                card: card,
                                width: 50,
                                height: 70,
                                onTap: () => provider.tryAutoMoveToFoundation(
                                  card, 
                                  'tableau_$columnIndex'
                                ),
                              ),
                            )
                          : GestureDetector(
                              onTap: isLast ? () {
                                card.isFaceUp = true;
                                provider.gameState.moves++;
                                provider.notifyListeners();
                              } : null,
                              child: PlayingCardWidget(
                                card: card,
                                width: 50,
                                height: 70,
                              ),
                            ),
                    );
                  }).toList(),
                ),
        );
      },
    );
  }

  Widget _buildBottomControls(SolitaireProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: () => provider.newGame(),
            icon: const Icon(Icons.refresh),
            label: const Text('New Game'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF198754),
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            onPressed: provider.gameState.moveHistory.isNotEmpty
                ? () => provider.undoLastMove()
                : null,
            icon: const Icon(Icons.undo),
            label: const Text('Undo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C757D),
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showHintDialog(provider),
            icon: const Icon(Icons.lightbulb),
            label: const Text('Hint'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC107),
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinDialog(SolitaireProvider provider) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.celebration,
                  size: 64,
                  color: Colors.amber,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Congratulations!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('You won the game!'),
                const SizedBox(height: 16),
                Text('Score: ${provider.gameState.score}'),
                Text('Moves: ${provider.gameState.moves}'),
                if (provider.gameState.gameTime != null)
                  Text('Time: ${provider.formatTime(provider.gameState.gameTime!)}'),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => provider.newGame(),
                      child: const Text('New Game'),
                    ),
                    ElevatedButton(
                      onPressed: () => _showStatsDialog(provider),
                      child: const Text('Statistics'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
            .animate()
            .scale(duration: const Duration(milliseconds: 500))
            .fadeIn(),
      ),
    );
  }

  void _showHintDialog(SolitaireProvider provider) {
    final hints = provider.getHint();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hint'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: hints.take(3).map((hint) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text('• $hint'),
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showStatsDialog(SolitaireProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Games Won: ${provider.gamesWon}'),
            Text('Games Played: ${provider.gamesPlayed}'),
            Text('Win Rate: ${provider.winPercentage.toStringAsFixed(1)}%'),
            Text('Best Score: ${provider.bestScore}'),
            Text('Best Time: ${provider.formatTime(provider.bestTime)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => provider.resetStatistics(),
            child: const Text('Reset'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}