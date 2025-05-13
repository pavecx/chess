# Chess Game

A Ruby implementation of the classic game of chess with a command-line interface.

## Features

- Complete chess rules implementation
- Command-line interface with colored output
- Move validation
- Check and checkmate detection
- Castling
- En passant
- Pawn promotion
- Game state saving/loading
- Move history

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/chess.git
cd chess
```

2. Install dependencies:
```bash
bundle install
```

## Usage

To start a new game:
```bash
ruby main.rb
```

## Game Controls

- Enter moves in algebraic notation (e.g., "e2e4", "Nf3", "O-O" for castling)
- Type 'save' to save the current game
- Type 'load' to load a saved game
- Type 'quit' to exit the game
- Type 'help' to see available commands

## Development

Run tests:
```bash
bundle exec rspec
```

Run code style checks:
```bash
bundle exec rubocop
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.
