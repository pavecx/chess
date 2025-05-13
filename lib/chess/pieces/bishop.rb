# frozen_string_literal: true

require_relative 'piece'

module Chess
  module Pieces
    # Represents a bishop in the game of chess
    class Bishop < Piece
      def symbol
        white? ? '♗' : '♝'
      end

      # @param board [Board] the current board state
      # @param skip_validation [Boolean] if true, skips check validation to prevent infinite recursion
      # @return [Array<Position>] array of valid positions the bishop can move to
      def valid_moves(board, skip_validation = false)
        moves = []
        return moves unless @position.valid?

        # Check all four diagonal directions
        [[1, 1], [1, -1], [-1, 1], [-1, -1]].each do |row_dir, col_dir|
          current_row = @position.row + row_dir
          current_col = @position.col + col_dir

          while current_row.between?(0, 7) && current_col.between?(0, 7)
            current_pos = Position.new(current_row, current_col)
            
            if board.empty?(current_pos)
              moves << current_pos
            elsif board.enemy_piece?(current_pos, @color)
              moves << current_pos
              break
            else
              break
            end

            current_row += row_dir
            current_col += col_dir
          end
        end

        super(board, skip_validation)
      end
    end
  end
end 