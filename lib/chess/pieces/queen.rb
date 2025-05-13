# frozen_string_literal: true

require_relative 'piece'

module Chess
  module Pieces
    # Represents a queen in the game of chess
    class Queen < Piece
      def symbol
        white? ? '♕' : '♛'
      end

      def valid_moves(board)
        moves = []
        # Queen moves like both rook and bishop
        directions = [
          [0, 1], [0, -1], [1, 0], [-1, 0],  # rook directions
          [1, 1], [1, -1], [-1, 1], [-1, -1]  # bishop directions
        ]

        directions.each do |row_dir, col_dir|
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

        moves
      end
    end
  end
end 