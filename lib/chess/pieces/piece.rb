# frozen_string_literal: true

require_relative '../position'

module Chess
  module Pieces
    # Base class for all chess pieces
    class Piece
      attr_reader :color, :position, :moved

      # @param color [Symbol] :white or :black
      # @param position [Position] the current position of the piece
      def initialize(color, position)
        @color = color
        @position = position
        @moved = false
      end

      # @return [String] the Unicode symbol for the piece
      def symbol
        raise NotImplementedError, "#{self.class} must implement #symbol"
      end

      # @param board [Board] the current board state
      # @param skip_validation [Boolean] if true, skips check validation to prevent infinite recursion
      # @return [Array<Position>] array of valid positions the piece can move to
      def valid_moves(board, skip_validation = false)
        moves = []
        return moves unless @position.valid?

        # Get all possible moves for this piece
        moves = possible_moves(board) if respond_to?(:possible_moves)

        # Filter out moves that would put or leave the king in check
        unless skip_validation
          moves.select! do |move|
            # Try the move
            original_piece = board.piece_at(move)
            board.move_piece(@position, move)

            # Check if the king is in check
            in_check = board.in_check?(true)

            # Undo the move
            board.move_piece(move, @position)
            board.piece_at(move).replace(original_piece) if original_piece

            !in_check
          end
        end

        moves
      end

      # @param position [Position] the new position
      def move_to(position)
        @position = position
        @moved = true
      end

      # @return [Boolean] true if the piece is white
      def white?
        @color == :white
      end

      # @return [Boolean] true if the piece is black
      def black?
        @color == :black
      end

      # @param other [Piece] another piece to compare with
      # @return [Boolean] true if the pieces are the same color
      def same_color?(other)
        @color == other.color
      end

      # @param other [Piece] another piece to compare with
      # @return [Boolean] true if the pieces are different colors
      def different_color?(other)
        @color != other.color
      end

      private

      # @param board [Board] the current game board
      # @param position [Position] the position to check
      # @return [Boolean] true if the position is valid and empty
      def valid_empty_position?(board, position)
        position.valid? && board.empty?(position)
      end

      # @param board [Board] the current game board
      # @param position [Position] the position to check
      # @return [Boolean] true if the position is valid and contains an enemy piece
      def valid_enemy_position?(board, position)
        position.valid? && board.enemy_piece?(position, @color)
      end
    end
  end
end 