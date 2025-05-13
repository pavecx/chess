# frozen_string_literal: true

require_relative 'piece'

module Chess
  module Pieces
    # Represents a knight in the game of chess
    class Knight < Piece
      def symbol
        white? ? '♘' : '♞'
      end

      def valid_moves(board, skip_validation = false)
        moves = []
        return moves unless @position.valid?

        # All possible L-shaped moves
        offsets = [
          [-2, -1], [-2, 1], [-1, -2], [-1, 2],
          [1, -2], [1, 2], [2, -1], [2, 1]
        ]

        offsets.each do |row_offset, col_offset|
          new_row = @position.row + row_offset
          new_col = @position.col + col_offset

          if new_row.between?(0, 7) && new_col.between?(0, 7)
            new_pos = Position.new(new_row, new_col)
            moves << new_pos if board.empty?(new_pos) || board.enemy_piece?(new_pos, @color)
          end
        end

        super(board, skip_validation)
      end
    end
  end
end 