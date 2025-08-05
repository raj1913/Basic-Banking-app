# Flutter Solitaire

A beautiful and feature-rich Solitaire card game built with Flutter, inspired by classic Klondike Solitaire games.

## Features

### 🎮 Game Features
- **Classic Klondike Solitaire** - Traditional 52-card deck gameplay
- **Smooth Drag & Drop** - Intuitive card movement with visual feedback
- **Auto-complete** - Automatically moves cards when only low cards remain
- **Undo System** - Undo your last move with the undo button
- **Hint System** - Get suggestions for your next move
- **Score Tracking** - Points awarded for moves to foundation piles
- **Move Counter** - Track the number of moves made
- **Timer** - Game duration tracking

### 🎨 Visual Features
- **Beautiful Card Design** - Custom-designed playing cards with proper suits and colors
- **Smooth Animations** - Card movements and interactions with flutter_animate
- **Win Celebration** - Confetti animation and celebration dialog on game completion
- **Responsive Layout** - Adapts to different screen sizes
- **Green Felt Background** - Classic casino-style appearance

### 📊 Statistics
- **Games Won/Played** - Track your overall performance
- **Win Percentage** - Calculate your success rate
- **Best Score** - Remember your highest score
- **Best Time** - Track your fastest completion time
- **Persistent Storage** - Statistics saved using SharedPreferences

## How to Play

### Objective
Move all 52 cards to the four foundation piles, sorted by suit from Ace to King.

### Game Layout
- **Stock Pile** (top-left): Draw cards from here (3 at a time)
- **Waste Pile** (next to stock): Cards drawn from stock appear here
- **Foundation Piles** (top-right): Four piles to build up from Ace to King by suit
- **Tableau** (main area): Seven columns where you build down in alternating colors

### Rules
1. **Foundation**: Build up from Ace to King in the same suit
2. **Tableau**: Build down in alternating colors (red on black, black on red)
3. **Moving Cards**: Only face-up cards can be moved
4. **King Placement**: Only Kings can be placed on empty tableau columns
5. **Face-down Cards**: Click to flip when they become the top card of a column

### Controls
- **Drag & Drop**: Drag cards to move them
- **Tap**: Double-tap cards to auto-move to foundation if possible
- **Stock**: Tap to draw 3 cards
- **New Game**: Start a fresh game
- **Undo**: Reverse your last move
- **Hint**: Get suggestions for possible moves

## Technical Details

### Architecture
- **Provider Pattern** - State management using the Provider package
- **Model-View Separation** - Clean separation of game logic and UI
- **Custom Widgets** - Reusable card and game components

### Key Components
- `PlayingCard` - Card model with suit, rank, and state
- `SolitaireGameState` - Game logic and state management
- `SolitaireProvider` - Provider for state management and business logic
- `PlayingCardWidget` - Custom card UI component with animations
- `GameScreen` - Main game interface

### Dependencies
- `provider: ^6.1.1` - State management
- `shared_preferences: ^2.2.2` - Persistent storage
- `flutter_animate: ^4.5.0` - Smooth animations
- `confetti: ^0.7.0` - Win celebration effects

## Getting Started

### Prerequisites
- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)

### Installation
1. Clone this repository
2. Navigate to the project directory
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

### Building for Release
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## Project Structure
```
lib/
├── main.dart                 # App entry point
├── models/
│   ├── card.dart            # Playing card model
│   └── game_state.dart      # Game state and logic
├── providers/
│   └── solitaire_provider.dart  # State management
├── screens/
│   └── game_screen.dart     # Main game interface
└── widgets/
    └── playing_card_widget.dart # Card UI components
```

## Features Comparison

This Flutter Solitaire implementation includes features similar to popular solitaire games:

- ✅ Classic Klondike gameplay
- ✅ Beautiful card graphics
- ✅ Smooth animations
- ✅ Drag and drop controls
- ✅ Score and move tracking
- ✅ Undo functionality
- ✅ Hint system
- ✅ Win detection and celebration
- ✅ Statistics tracking
- ✅ Auto-complete feature

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available under the [MIT License](LICENSE).

## Acknowledgments

- Inspired by classic Solitaire games
- Built with Flutter framework
- Uses Material Design principles
