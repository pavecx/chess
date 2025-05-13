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

      # @param board [Board] the current game board
      # @return [Array<Position>] array of valid moves for this piece
      def valid_moves(board)
        raise NotImplementedError, "#{self.class} must implement #valid_moves"
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