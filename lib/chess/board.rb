# frozen_string_literal: true

require_relative 'position'
require_relative 'pieces/piece'
require_relative 'pieces/pawn'
require_relative 'pieces/rook'
require_relative 'pieces/knight'
require_relative 'pieces/bishop'
require_relative 'pieces/queen'
require_relative 'pieces/king'

module Chess
  # Represents the chess board and manages the game state
  class Board
    attr_reader :current_player, :move_history

    def initialize
      @board = Array.new(8) { Array.new(8) }
      @current_player = :white
      @move_history = []
      @en_passant_target = nil
      setup_board
    end

    # @param position [Position] the position to check
    # @return [Piece, nil] the piece at the given position
    def piece_at(position)
      @board[position.row][position.col]
    end

    # @param position [Position] the position to check
    # @return [Boolean] true if the position is empty
    def empty?(position)
      piece_at(position).nil?
    end

    # @param position [Position] the position to check
    # @param color [Symbol] the color to check against
    # @return [Boolean] true if the position contains an enemy piece
    def enemy_piece?(position, color)
      piece = piece_at(position)
      piece && piece.color != color
    end

    # @param from [Position] the starting position
    # @param to [Position] the destination position
    # @return [Boolean] true if the move was successful
    def move_piece(from, to)
      piece = piece_at(from)
      return false unless piece && piece.color == @current_player

      valid_moves = piece.valid_moves(self)
      return false unless valid_moves.include?(to)

      # Handle special moves
      handle_special_moves(piece, from, to)

      # Make the move
      @board[to.row][to.col] = piece
      @board[from.row][from.col] = nil
      piece.move_to(to)

      # Record the move
      @move_history << { from: from, to: to, piece: piece }

      # Switch players
      @current_player = @current_player == :white ? :black : :white

      true
    end

    # @return [Boolean] true if the current player is in check
    def in_check?
      king_position = find_king(@current_player)
      return false unless king_position

      opponent_pieces.any? do |piece|
        piece.valid_moves(self).include?(king_position)
      end
    end

    # @return [Boolean] true if the current player is in checkmate
    def checkmate?
      return false unless in_check?

      current_pieces.none? do |piece|
        piece.valid_moves(self).any? do |move|
          # Try the move
          original_piece = piece_at(move)
          @board[move.row][move.col] = piece
          @board[piece.position.row][piece.position.col] = nil
          original_position = piece.position
          piece.move_to(move)

          # Check if still in check
          result = !in_check?

          # Undo the move
          @board[original_position.row][original_position.col] = piece
          @board[move.row][move.col] = original_piece
          piece.move_to(original_position)

          result
        end
      end
    end

    private

    def setup_board
      setup_pawns
      setup_major_pieces
    end

    def setup_pawns
      # White pawns
      8.times do |col|
        @board[6][col] = Pawn.new(:white, Position.new(6, col))
      end

      # Black pawns
      8.times do |col|
        @board[1][col] = Pawn.new(:black, Position.new(1, col))
      end
    end

    def setup_major_pieces
      # White pieces
      @board[7][0] = Rook.new(:white, Position.new(7, 0))
      @board[7][1] = Knight.new(:white, Position.new(7, 1))
      @board[7][2] = Bishop.new(:white, Position.new(7, 2))
      @board[7][3] = Queen.new(:white, Position.new(7, 3))
      @board[7][4] = King.new(:white, Position.new(7, 4))
      @board[7][5] = Bishop.new(:white, Position.new(7, 5))
      @board[7][6] = Knight.new(:white, Position.new(7, 6))
      @board[7][7] = Rook.new(:white, Position.new(7, 7))

      # Black pieces
      @board[0][0] = Rook.new(:black, Position.new(0, 0))
      @board[0][1] = Knight.new(:black, Position.new(0, 1))
      @board[0][2] = Bishop.new(:black, Position.new(0, 2))
      @board[0][3] = Queen.new(:black, Position.new(0, 3))
      @board[0][4] = King.new(:black, Position.new(0, 4))
      @board[0][5] = Bishop.new(:black, Position.new(0, 5))
      @board[0][6] = Knight.new(:black, Position.new(0, 6))
      @board[0][7] = Rook.new(:black, Position.new(0, 7))
    end

    def handle_special_moves(piece, from, to)
      # Handle castling
      if piece.is_a?(King) && (to.col - from.col).abs == 2
        handle_castling(from, to)
      end

      # Handle en passant
      if piece.is_a?(Pawn) && to == @en_passant_target
        handle_en_passant(from, to)
      end

      # Handle pawn promotion
      if piece.is_a?(Pawn) && (to.row == 0 || to.row == 7)
        handle_pawn_promotion(to)
      end

      # Update en passant target
      @en_passant_target = if piece.is_a?(Pawn) && (to.row - from.row).abs == 2
                            Position.new((from.row + to.row) / 2, from.col)
                          else
                            nil
                          end
    end

    def handle_castling(from, to)
      rook_col = to.col > from.col ? 7 : 0
      rook_to_col = to.col > from.col ? to.col - 1 : to.col + 1
      
      rook = piece_at(Position.new(from.row, rook_col))
      @board[from.row][rook_to_col] = rook
      @board[from.row][rook_col] = nil
      rook.move_to(Position.new(from.row, rook_to_col))
    end

    def handle_en_passant(from, to)
      captured_pawn_row = from.row
      @board[captured_pawn_row][to.col] = nil
    end

    def handle_pawn_promotion(position)
      @board[position.row][position.col] = Queen.new(@current_player, position)
    end

    def find_king(color)
      Position.all.find do |pos|
        piece = piece_at(pos)
        piece.is_a?(King) && piece.color == color
      end
    end

    def current_pieces
      Position.all.map { |pos| piece_at(pos) }.compact.select { |piece| piece.color == @current_player }
    end

    def opponent_pieces
      Position.all.map { |pos| piece_at(pos) }.compact.select { |piece| piece.color != @current_player }
    end
  end
end 