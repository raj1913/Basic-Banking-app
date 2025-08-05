import 'dart:math';
import 'card.dart';

class GameMove {
  final String from;
  final String to;
  final List<PlayingCard> cards;
  final bool wasFlipped;

  GameMove({
    required this.from,
    required this.to,
    required this.cards,
    this.wasFlipped = false,
  });
}

class SolitaireGameState {
  List<PlayingCard> stock;
  List<PlayingCard> waste;
  List<List<PlayingCard>> tableau;
  List<List<PlayingCard>> foundation;
  List<GameMove> moveHistory;
  int score;
  int moves;
  DateTime? startTime;
  Duration? gameTime;
  bool isGameWon;

  SolitaireGameState({
    required this.stock,
    required this.waste,
    required this.tableau,
    required this.foundation,
    required this.moveHistory,
    this.score = 0,
    this.moves = 0,
    this.startTime,
    this.gameTime,
    this.isGameWon = false,
  });

  factory SolitaireGameState.newGame() {
    final deck = _createShuffledDeck();
    final tableau = List.generate(7, (index) => <PlayingCard>[]);
    final foundation = List.generate(4, (index) => <PlayingCard>[]);
    
    // Deal cards to tableau
    int cardIndex = 0;
    for (int col = 0; col < 7; col++) {
      for (int row = 0; row <= col; row++) {
        final card = deck[cardIndex++];
        if (row == col) {
          card.isFaceUp = true; // Top card is face up
        }
        tableau[col].add(card);
      }
    }

    // Remaining cards go to stock
    final stock = deck.sublist(cardIndex);

    return SolitaireGameState(
      stock: stock,
      waste: [],
      tableau: tableau,
      foundation: foundation,
      moveHistory: [],
      startTime: DateTime.now(),
    );
  }

  static List<PlayingCard> _createShuffledDeck() {
    final deck = <PlayingCard>[];
    for (final suit in Suit.values) {
      for (final rank in CardRank.values) {
        deck.add(PlayingCard(suit: suit, rank: rank));
      }
    }
    deck.shuffle(Random());
    return deck;
  }

  bool canMoveToFoundation(PlayingCard card, int foundationIndex) {
    final foundationPile = foundation[foundationIndex];
    if (foundationPile.isEmpty) {
      return card.rank == CardRank.ace;
    }
    final topCard = foundationPile.last;
    return card.canPlaceOnFoundation(topCard);
  }

  bool canMoveToTableau(List<PlayingCard> cards, int tableauIndex) {
    if (cards.isEmpty) return false;
    
    final tableauPile = tableau[tableauIndex];
    final cardToPlace = cards.first;
    
    if (tableauPile.isEmpty) {
      return cardToPlace.rank == CardRank.king;
    }
    
    final topCard = tableauPile.last;
    return cardToPlace.canPlaceOnTableau(topCard);
  }

  void drawFromStock() {
    if (stock.isEmpty) {
      // Flip waste back to stock
      stock = waste.reversed.map((card) => card.copyWith(isFaceUp: false)).toList();
      waste.clear();
    } else {
      // Draw 3 cards (or remaining cards if less than 3)
      final cardsToDraw = min(3, stock.length);
      for (int i = 0; i < cardsToDraw; i++) {
        final card = stock.removeLast();
        card.isFaceUp = true;
        waste.add(card);
      }
    }
    moves++;
  }

  bool moveCardToFoundation(PlayingCard card, String fromLocation, int foundationIndex) {
    if (!canMoveToFoundation(card, foundationIndex)) return false;

    // Remove card from source
    _removeCardFromLocation(card, fromLocation);
    
    // Add to foundation
    foundation[foundationIndex].add(card);
    
    // Record move
    moveHistory.add(GameMove(
      from: fromLocation,
      to: 'foundation_$foundationIndex',
      cards: [card],
    ));
    
    score += 10;
    moves++;
    _checkForWin();
    return true;
  }

  bool moveCardsToTableau(List<PlayingCard> cards, String fromLocation, int tableauIndex) {
    if (!canMoveToTableau(cards, tableauIndex)) return false;

    // Remove cards from source
    for (final card in cards) {
      _removeCardFromLocation(card, fromLocation);
    }
    
    // Add to tableau
    tableau[tableauIndex].addAll(cards);
    
    // Record move
    moveHistory.add(GameMove(
      from: fromLocation,
      to: 'tableau_$tableauIndex',
      cards: cards,
    ));
    
    moves++;
    return true;
  }

  void _removeCardFromLocation(PlayingCard card, String location) {
    if (location == 'waste') {
      waste.remove(card);
    } else if (location.startsWith('tableau_')) {
      final index = int.parse(location.split('_')[1]);
      tableau[index].remove(card);
      // Flip the next card if it exists and is face down
      if (tableau[index].isNotEmpty && !tableau[index].last.isFaceUp) {
        tableau[index].last.isFaceUp = true;
      }
    } else if (location.startsWith('foundation_')) {
      final index = int.parse(location.split('_')[1]);
      foundation[index].remove(card);
    }
  }

  void _checkForWin() {
    final totalFoundationCards = foundation.fold(0, (sum, pile) => sum + pile.length);
    if (totalFoundationCards == 52) {
      isGameWon = true;
      gameTime = DateTime.now().difference(startTime!);
    }
  }

  bool undoLastMove() {
    if (moveHistory.isEmpty) return false;

    final lastMove = moveHistory.removeLast();
    
    // Remove cards from destination
    if (lastMove.to.startsWith('foundation_')) {
      final index = int.parse(lastMove.to.split('_')[1]);
      for (final card in lastMove.cards) {
        foundation[index].remove(card);
      }
    } else if (lastMove.to.startsWith('tableau_')) {
      final index = int.parse(lastMove.to.split('_')[1]);
      for (final card in lastMove.cards) {
        tableau[index].remove(card);
      }
    }

    // Add cards back to source
    if (lastMove.from == 'waste') {
      waste.addAll(lastMove.cards);
    } else if (lastMove.from.startsWith('tableau_')) {
      final index = int.parse(lastMove.from.split('_')[1]);
      tableau[index].addAll(lastMove.cards);
    } else if (lastMove.from.startsWith('foundation_')) {
      final index = int.parse(lastMove.from.split('_')[1]);
      foundation[index].addAll(lastMove.cards);
    }

    moves++;
    return true;
  }

  List<PlayingCard> getTableauSequence(int tableauIndex, int startIndex) {
    final pile = tableau[tableauIndex];
    if (startIndex >= pile.length) return [];
    
    final sequence = <PlayingCard>[];
    for (int i = startIndex; i < pile.length; i++) {
      final card = pile[i];
      if (!card.isFaceUp) break;
      
      sequence.add(card);
      
      // Check if sequence is valid (alternating colors, descending ranks)
      if (sequence.length > 1) {
        final prevCard = sequence[sequence.length - 2];
        if (!card.canPlaceOnTableau(prevCard)) {
          sequence.removeLast();
          break;
        }
      }
    }
    
    return sequence;
  }

  SolitaireGameState copyWith({
    List<PlayingCard>? stock,
    List<PlayingCard>? waste,
    List<List<PlayingCard>>? tableau,
    List<List<PlayingCard>>? foundation,
    List<GameMove>? moveHistory,
    int? score,
    int? moves,
    DateTime? startTime,
    Duration? gameTime,
    bool? isGameWon,
  }) {
    return SolitaireGameState(
      stock: stock ?? this.stock,
      waste: waste ?? this.waste,
      tableau: tableau ?? this.tableau,
      foundation: foundation ?? this.foundation,
      moveHistory: moveHistory ?? this.moveHistory,
      score: score ?? this.score,
      moves: moves ?? this.moves,
      startTime: startTime ?? this.startTime,
      gameTime: gameTime ?? this.gameTime,
      isGameWon: isGameWon ?? this.isGameWon,
    );
  }
}