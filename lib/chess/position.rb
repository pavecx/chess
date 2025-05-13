# frozen_string_literal: true

module Chess
  # Represents a position on the chess board
  class Position
    attr_reader :row, :col

    # @param row [Integer] the row (0-7)
    # @param col [Integer] the column (0-7)
    def initialize(row, col)
      @row = row
      @col = col
    end

    # @return [Boolean] true if the position is within the board bounds
    def valid?
      @row.between?(0, 7) && @col.between?(0, 7)
    end

    # @param other [Position] another position to compare with
    # @return [Boolean] true if the positions are equal
    def ==(other)
      @row == other.row && @col == other.col
    end

    # @param other [Position] another position to add
    # @return [Position] the sum of the positions
    def +(other)
      Position.new(@row + other.row, @col + other.col)
    end

    # @param other [Position] another position to subtract
    # @return [Position] the difference of the positions
    def -(other)
      Position.new(@row - other.row, @col - other.col)
    end

    # @return [String] the algebraic notation for this position (e.g., "e4")
    def to_s
      "#{('a'.ord + @col).chr}#{8 - @row}"
    end

    # @param notation [String] the algebraic notation (e.g., "e4")
    # @return [Position] the position represented by the notation
    def self.from_notation(notation)
      col = notation[0].downcase.ord - 'a'.ord
      row = 8 - notation[1].to_i
      new(row, col)
    end

    # @return [Array<Position>] all positions on the board
    def self.all
      @all_positions ||= begin
        positions = []
        8.times do |row|
          8.times do |col|
            positions << new(row, col)
          end
        end
        positions
      end
    end
  end
end 