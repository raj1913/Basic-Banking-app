enum Suit { hearts, diamonds, clubs, spades }

enum CardRank {
  ace(1),
  two(2),
  three(3),
  four(4),
  five(5),
  six(6),
  seven(7),
  eight(8),
  nine(9),
  ten(10),
  jack(11),
  queen(12),
  king(13);

  const CardRank(this.value);
  final int value;
}

class PlayingCard {
  final Suit suit;
  final CardRank rank;
  bool isFaceUp;
  bool isDragging;

  PlayingCard({
    required this.suit,
    required this.rank,
    this.isFaceUp = false,
    this.isDragging = false,
  });

  bool get isRed => suit == Suit.hearts || suit == Suit.diamonds;
  bool get isBlack => suit == Suit.clubs || suit == Suit.spades;

  String get suitSymbol {
    switch (suit) {
      case Suit.hearts:
        return '♥';
      case Suit.diamonds:
        return '♦';
      case Suit.clubs:
        return '♣';
      case Suit.spades:
        return '♠';
    }
  }

  String get rankSymbol {
    switch (rank) {
      case CardRank.ace:
        return 'A';
      case CardRank.jack:
        return 'J';
      case CardRank.queen:
        return 'Q';
      case CardRank.king:
        return 'K';
      default:
        return rank.value.toString();
    }
  }

  bool canPlaceOnFoundation(PlayingCard? topCard) {
    if (topCard == null) {
      return rank == CardRank.ace;
    }
    return suit == topCard.suit && rank.value == topCard.rank.value + 1;
  }

  bool canPlaceOnTableau(PlayingCard? topCard) {
    if (topCard == null) {
      return rank == CardRank.king;
    }
    return isRed != topCard.isRed && rank.value == topCard.rank.value - 1;
  }

  PlayingCard copyWith({
    bool? isFaceUp,
    bool? isDragging,
  }) {
    return PlayingCard(
      suit: suit,
      rank: rank,
      isFaceUp: isFaceUp ?? this.isFaceUp,
      isDragging: isDragging ?? this.isDragging,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlayingCard && 
           other.suit == suit && 
           other.rank == rank;
  }

  @override
  int get hashCode => suit.hashCode ^ rank.hashCode;

  @override
  String toString() {
    return '$rankSymbol$suitSymbol';
  }
}