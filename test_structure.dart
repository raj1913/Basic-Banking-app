// Simple test to validate project structure
import 'lib/models/card.dart';
import 'lib/models/game_state.dart';

void main() {
  // Test card creation
  final card = PlayingCard(suit: Suit.hearts, rank: CardRank.ace);
  print('Card created: ${card.rankSymbol}${card.suitSymbol}');
  
  // Test game state creation
  final gameState = SolitaireGameState.newGame();
  print('Game state created with ${gameState.stock.length} cards in stock');
  print('Tableau has ${gameState.tableau.length} columns');
  
  print('✅ Project structure is valid!');
}