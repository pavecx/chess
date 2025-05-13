# frozen_string_literal: true

require_relative 'piece'

module Chess
  module Pieces
    # Represents a pawn in the game of chess
    class Pawn < Piece
      def symbol
        white? ? '♙' : '♟'
      end

      def valid_moves(board)
        moves = []
        direction = white? ? -1 : 1

        # Forward moves
        one_step = Position.new(@position.row + direction, @position.col)
        if board.empty?(one_step)
          moves << one_step

          # Double step from starting position
          if !@moved
            two_steps = Position.new(@position.row + 2 * direction, @position.col)
            moves << two_steps if board.empty?(two_steps)
          end
        end

        # Capture moves
        [-1, 1].each do |offset|
          capture_pos = Position.new(@position.row + direction, @position.col + offset)
          moves << capture_pos if board.enemy_piece?(capture_pos, @color)
        end

        # En passant
        if board.en_passant_target
          [-1, 1].each do |offset|
            capture_pos = Position.new(@position.row + direction, @position.col + offset)
            moves << board.en_passant_target if capture_pos == board.en_passant_target
          end
        end

        moves
      end
    end
  end
end 