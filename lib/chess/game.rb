# frozen_string_literal: true

require_relative 'board'
require 'colorize'

module Chess
  # Manages the game state and user interaction
  class Game
    def initialize
      @board = Board.new
      @game_over = false
    end

    def play
      display_welcome_message
      
      until @game_over
        display_board
        handle_turn
        check_game_over
      end
    end

    private

    def display_welcome_message
      puts "\nWelcome to Chess!".colorize(:green)
      puts "Enter moves in algebraic notation (e.g., 'e2e4', 'Nf3', 'O-O' for castling)"
      puts "Type 'help' for available commands\n\n"
    end

    def display_board
      puts "\n  a b c d e f g h"
      puts "  ---------------"
      
      8.times do |row|
        print "#{8 - row} "
        8.times do |col|
          piece = @board.piece_at(Position.new(row, col))
          if piece
            print "#{piece.symbol} "
          else
            print (row + col).even? ? "□ " : "■ "
          end
        end
        puts " #{8 - row}"
      end
      
      puts "  ---------------"
      puts "  a b c d e f g h\n"
      
      display_status
    end

    def display_status
      if @board.in_check?
        puts "#{@board.current_player.capitalize} is in check!".colorize(:red)
      end
      
      if @board.checkmate?
        puts "Checkmate! #{opponent_color.capitalize} wins!".colorize(:green)
        @game_over = true
      end
    end

    def handle_turn
      loop do
        print "#{@board.current_player.capitalize}'s turn: "
        input = gets.chomp.downcase

        case input
        when 'help'
          display_help
        when 'quit'
          exit_game
        when 'save'
          save_game
        when 'load'
          load_game
        else
          if make_move(input)
            break
          else
            puts "Invalid move. Try again or type 'help' for available commands.".colorize(:red)
          end
        end
      end
    end

    def make_move(input)
      # Handle castling notation
      if input == 'o-o' || input == '0-0'
        return handle_castling(:kingside)
      elsif input == 'o-o-o' || input == '0-0-0'
        return handle_castling(:queenside)
      end

      # Handle regular moves
      begin
        from, to = parse_move(input)
        return false unless from && to

        @board.move_piece(from, to)
        true
      rescue ArgumentError
        false
      end
    end

    def parse_move(input)
      return nil unless input.match?(/^[a-h][1-8][a-h][1-8]$/)

      from = Position.from_notation(input[0..1])
      to = Position.from_notation(input[2..3])
      [from, to]
    end

    def handle_castling(side)
      king_pos = @board.find_king(@board.current_player)
      return false unless king_pos

      king = @board.piece_at(king_pos)
      return false unless king.is_a?(King)

      target_col = side == :kingside ? king_pos.col + 2 : king_pos.col - 2
      target_pos = Position.new(king_pos.row, target_col)

      @board.move_piece(king_pos, target_pos)
    end

    def display_help
      puts "\nAvailable commands:"
      puts "  <from><to>  - Make a move (e.g., 'e2e4')"
      puts "  o-o        - Kingside castling"
      puts "  o-o-o      - Queenside castling"
      puts "  save       - Save the current game"
      puts "  load       - Load a saved game"
      puts "  help       - Show this help message"
      puts "  quit       - Exit the game\n"
    end

    def save_game
      filename = "chess_save_#{Time.now.strftime('%Y%m%d_%H%M%S')}.yaml"
      File.open(filename, 'w') do |file|
        file.write(@board.to_yaml)
      end
      puts "Game saved to #{filename}".colorize(:green)
    end

    def load_game
      saves = Dir.glob('chess_save_*.yaml')
      if saves.empty?
        puts "No saved games found.".colorize(:yellow)
        return
      end

      puts "\nAvailable saves:"
      saves.each_with_index do |save, index|
        puts "#{index + 1}. #{save}"
      end

      print "\nSelect a save file (number): "
      choice = gets.chomp.to_i - 1

      if choice.between?(0, saves.length - 1)
        @board = YAML.load_file(saves[choice])
        puts "Game loaded from #{saves[choice]}".colorize(:green)
      else
        puts "Invalid selection.".colorize(:red)
      end
    end

    def exit_game
      print "Are you sure you want to quit? (y/n): "
      exit if gets.chomp.downcase == 'y'
    end

    def opponent_color
      @board.current_player == :white ? :black : :white
    end

    def check_game_over
      @game_over = true if @board.checkmate?
    end
  end
end 