import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/card.dart';
import '../models/game_state.dart';

class SolitaireProvider extends ChangeNotifier {
  SolitaireGameState _gameState = SolitaireGameState.newGame();
  bool _isLoading = false;
  int _gamesWon = 0;
  int _gamesPlayed = 0;
  int _bestScore = 0;
  Duration _bestTime = const Duration(hours: 1);

  SolitaireGameState get gameState => _gameState;
  bool get isLoading => _isLoading;
  int get gamesWon => _gamesWon;
  int get gamesPlayed => _gamesPlayed;
  int get bestScore => _bestScore;
  Duration get bestTime => _bestTime;

  double get winPercentage {
    if (_gamesPlayed == 0) return 0.0;
    return (_gamesWon / _gamesPlayed) * 100;
  }

  SolitaireProvider() {
    _loadStatistics();
  }

  void newGame() {
    _gameState = SolitaireGameState.newGame();
    notifyListeners();
  }

  void drawFromStock() {
    _gameState.drawFromStock();
    notifyListeners();
  }

  bool moveCardToFoundation(PlayingCard card, String fromLocation, int foundationIndex) {
    final success = _gameState.moveCardToFoundation(card, fromLocation, foundationIndex);
    if (success) {
      _checkAutoComplete();
      _checkWinCondition();
      notifyListeners();
    }
    return success;
  }

  bool moveCardsToTableau(List<PlayingCard> cards, String fromLocation, int tableauIndex) {
    final success = _gameState.moveCardsToTableau(cards, fromLocation, tableauIndex);
    if (success) {
      notifyListeners();
    }
    return success;
  }

  bool undoLastMove() {
    final success = _gameState.undoLastMove();
    if (success) {
      notifyListeners();
    }
    return success;
  }

  List<PlayingCard> getTableauSequence(int tableauIndex, int startIndex) {
    return _gameState.getTableauSequence(tableauIndex, startIndex);
  }

  void selectCard(PlayingCard card) {
    // Toggle card selection for hint system
    notifyListeners();
  }

  List<String> getHint() {
    final hints = <String>[];

    // Check for cards that can move to foundation
    for (int i = 0; i < _gameState.tableau.length; i++) {
      final pile = _gameState.tableau[i];
      if (pile.isNotEmpty && pile.last.isFaceUp) {
        final card = pile.last;
        for (int j = 0; j < 4; j++) {
          if (_gameState.canMoveToFoundation(card, j)) {
            hints.add('Move ${card.rankSymbol}${card.suitSymbol} to foundation');
          }
        }
      }
    }

    // Check waste pile
    if (_gameState.waste.isNotEmpty) {
      final card = _gameState.waste.last;
      for (int j = 0; j < 4; j++) {
        if (_gameState.canMoveToFoundation(card, j)) {
          hints.add('Move ${card.rankSymbol}${card.suitSymbol} from waste to foundation');
        }
      }
    }

    // Check for tableau moves
    for (int i = 0; i < _gameState.tableau.length; i++) {
      final pile = _gameState.tableau[i];
      if (pile.isNotEmpty && pile.last.isFaceUp) {
        final sequence = getTableauSequence(i, pile.length - 1);
        if (sequence.isNotEmpty) {
          for (int j = 0; j < _gameState.tableau.length; j++) {
            if (i != j && _gameState.canMoveToTableau(sequence, j)) {
              hints.add('Move ${sequence.first.rankSymbol}${sequence.first.suitSymbol} sequence to column ${j + 1}');
            }
          }
        }
      }
    }

    if (hints.isEmpty) {
      if (_gameState.stock.isNotEmpty || _gameState.waste.isNotEmpty) {
        hints.add('Draw from stock pile');
      } else {
        hints.add('No moves available');
      }
    }

    return hints;
  }

  void _checkAutoComplete() {
    // Auto-complete when only aces and twos are left in tableau
    bool canAutoComplete = true;
    for (final pile in _gameState.tableau) {
      for (final card in pile) {
        if (card.isFaceUp && card.rank.value > 2) {
          canAutoComplete = false;
          break;
        }
      }
      if (!canAutoComplete) break;
    }

    if (canAutoComplete && _gameState.waste.isEmpty) {
      _autoCompleteGame();
    }
  }

  void _autoCompleteGame() {
    // Automatically move all remaining cards to foundation
    bool madeMove;
    do {
      madeMove = false;
      
      // Check tableau piles
      for (int i = 0; i < _gameState.tableau.length; i++) {
        final pile = _gameState.tableau[i];
        if (pile.isNotEmpty && pile.last.isFaceUp) {
          final card = pile.last;
          for (int j = 0; j < 4; j++) {
            if (_gameState.canMoveToFoundation(card, j)) {
              _gameState.moveCardToFoundation(card, 'tableau_$i', j);
              madeMove = true;
              break;
            }
          }
          if (madeMove) break;
        }
      }
    } while (madeMove);
    
    notifyListeners();
  }

  void _checkWinCondition() {
    if (_gameState.isGameWon) {
      _gamesWon++;
      _gamesPlayed++;
      
      if (_gameState.score > _bestScore) {
        _bestScore = _gameState.score;
      }
      
      if (_gameState.gameTime != null && _gameState.gameTime! < _bestTime) {
        _bestTime = _gameState.gameTime!;
      }
      
      _saveStatistics();
    }
  }

  Future<void> _loadStatistics() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _gamesWon = prefs.getInt('games_won') ?? 0;
      _gamesPlayed = prefs.getInt('games_played') ?? 0;
      _bestScore = prefs.getInt('best_score') ?? 0;
      final bestTimeMs = prefs.getInt('best_time_ms') ?? 3600000; // 1 hour default
      _bestTime = Duration(milliseconds: bestTimeMs);
    } catch (e) {
      debugPrint('Error loading statistics: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('games_won', _gamesWon);
      await prefs.setInt('games_played', _gamesPlayed);
      await prefs.setInt('best_score', _bestScore);
      await prefs.setInt('best_time_ms', _bestTime.inMilliseconds);
    } catch (e) {
      debugPrint('Error saving statistics: $e');
    }
  }

  void resetStatistics() {
    _gamesWon = 0;
    _gamesPlayed = 0;
    _bestScore = 0;
    _bestTime = const Duration(hours: 1);
    _saveStatistics();
    notifyListeners();
  }

  String formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Auto-move cards to foundation when double-tapped
  bool tryAutoMoveToFoundation(PlayingCard card, String fromLocation) {
    for (int i = 0; i < 4; i++) {
      if (_gameState.canMoveToFoundation(card, i)) {
        return moveCardToFoundation(card, fromLocation, i);
      }
    }
    return false;
  }

  // Check if a move is valid before attempting
  bool canDropCard(PlayingCard card, String targetLocation) {
    if (targetLocation.startsWith('foundation_')) {
      final index = int.parse(targetLocation.split('_')[1]);
      return _gameState.canMoveToFoundation(card, index);
    } else if (targetLocation.startsWith('tableau_')) {
      final index = int.parse(targetLocation.split('_')[1]);
      return _gameState.canMoveToTableau([card], index);
    }
    return false;
  }
}