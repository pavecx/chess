# frozen_string_literal: true

require_relative 'piece'

module Chess
  module Pieces
    # Represents a king in the game of chess
    class King < Piece
      def symbol
        white? ? '♔' : '♚'
      end

      def valid_moves(board, skip_validation = false)
        moves = []
        # Regular king moves (one square in any direction)
        directions = [
          [0, 1], [0, -1], [1, 0], [-1, 0],
          [1, 1], [1, -1], [-1, 1], [-1, -1]
        ]

        directions.each do |row_dir, col_dir|
          new_row = @position.row + row_dir
          new_col = @position.col + col_dir

          if new_row.between?(0, 7) && new_col.between?(0, 7)
            new_pos = Position.new(new_row, new_col)
            moves << new_pos if board.empty?(new_pos) || board.enemy_piece?(new_pos, @color)
          end
        end

        # Add castling moves if conditions are met
        moves.concat(castling_moves(board)) unless skip_validation

        moves
      end

      private

      def castling_moves(board)
        moves = []
        return moves if @moved || board.in_check?(true)

        # Check kingside castling
        if can_castle_kingside?(board)
          moves << Position.new(@position.row, @position.col + 2)
        end

        # Check queenside castling
        if can_castle_queenside?(board)
          moves << Position.new(@position.row, @position.col - 2)
        end

        moves
      end

      def can_castle_kingside?(board)
        rook_pos = Position.new(@position.row, 7)
        rook = board.piece_at(rook_pos)
        return false unless rook.is_a?(Chess::Pieces::Rook) && !rook.moved? && rook.color == @color

        # Check if squares between king and rook are empty and not under attack
        (@position.col + 1..6).all? do |col|
          pos = Position.new(@position.row, col)
          board.empty?(pos) && !board.square_under_attack?(pos, @color == :white ? :black : :white)
        end
      end

      def can_castle_queenside?(board)
        rook_pos = Position.new(@position.row, 0)
        rook = board.piece_at(rook_pos)
        return false unless rook.is_a?(Chess::Pieces::Rook) && !rook.moved? && rook.color == @color

        # Check if squares between king and rook are empty and not under attack
        (1..@position.col - 1).all? do |col|
          pos = Position.new(@position.row, col)
          board.empty?(pos) && !board.square_under_attack?(pos, @color == :white ? :black : :white)
        end
      end
    end
  end
end 