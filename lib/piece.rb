require 'set'

class Piece
  def initialize(positions, kick_data, color_index=0, rotation=0)
    @positions = positions
    @kick_data = kick_data
    @color_index = color_index
    @rotation = rotation
  end

  def rotated_right
    r = dup
    r._rotation += 1
    r
  end

  def rotated_right_kick_offsets
    return [] unless @kick_data
    @kick_data[@rotation][:r]
  end

  def rotated_left
    r = dup
    r._rotation -= 1
    r
  end

  def rotated_left_kick_offsets
    return [] unless @kick_data
    @kick_data[@rotation][:l]
  end

  def with_game_state(game_state)
    p = self.dup
    p.instance_variable_set('@game_state', game_state)
    p
  end

  def randomly_mutate_color
    @secondary_color = rand(7)
    @color_mutated_squares = Set.new
    if rand(3) == 0
      @color_mutated_squares << (rand(3)+1)
      if rand(3) == 0
        @color_mutated_squares << (rand(3)+1)
      end

    end
  end

  def squares_with_coordinates(cursor_x, cursor_y)
    ret = {}
    @positions[@rotation].each_with_index do |row, row_index|
      row.each_with_index do |square, column_index|
        if square
          square_x = cursor_x + (column_index*Square.width)
          square_y = cursor_y + (row_index*Square.height)
          color_index = (@secondary_color && @color_mutated_squares.include?(square)) ? @secondary_color : @color_index
          ret[[row_index,column_index]] = [Square.new(color_index, @game_state), square_x, square_y]
        end
      end
    end
    (0...@positions[@rotation].size).each do |row_index|
      (0...@positions[@rotation][row_index].size).each do |column_index|
        ret[[row_index,column_index]].try(:first).try(:right=, ret[[row_index,column_index+1]].try(:first))
        ret[[row_index,column_index]].try(:first).try(:down=, ret[[row_index+1,column_index]].try(:first))
      end
    end
    ret.values
  end

  def _rotation
    @rotation
  end

  def _rotation=(number)
    @rotation = number % @positions.size
  end

  # kick data for all 3 square pieces indexed by position index and rotation direction
  KICK_DATA_3 = [
    { # original position
      r: [
        [-1, 0],
        [-1, 1],
        [ 0,-2],
        [-1,-2]
      ],
      l: [
        [1, 0],
        [1, 1],
        [0,-2],
        [1,-2]
      ]
    },
    { # rotated clocwize once
      r: [
        [1, 0],
        [1,-1],
        [0, 2],
        [1, 2]
      ],
      l: [
        [1, 0],
        [1,-1],
        [0, 2],
        [1, 2]
      ]
    },
    { # rotated twice
      r: [
        [1, 0],
        [1, 1],
        [0,-2],
        [1,-2]
      ],
      l: [
        [-1, 0],
        [-1, 1],
        [ 0,-2],
        [-1,-2]
      ]
    },
    { # rotated counter-clocwize once
      r: [
        [-1, 0],
        [-1,-1],
        [ 0, 2],
        [-1, 2]
      ],
      l: [
        [-1, 0],
        [-1,-1],
        [ 0, 2],
        [-1, 2]
      ]
    }
  ]

  # kick data for I piece indexed by position index and rotation direction
  KICK_DATA_I = [
    { # original position
      r: [
        [-2, 0],
        [ 1, 0],
        [-2,-1],
        [ 1, 2]
      ],
      l: [
        [-1, 0],
        [ 2, 0],
        [-1, 2],
        [ 2,-1]
      ]
    },
    { # rotated clocwize once
      r: [
        [-1, 0],
        [ 2, 0],
        [-1, 2],
        [ 2,-1]
      ],
      l: [
        [ 2, 0],
        [-1, 0],
        [ 2, 1],
        [-1,-2]
      ]
    },
    { # rotated twice
      r: [
        [ 2, 0],
        [-1, 0],
        [ 2, 1],
        [-1,-2]
      ],
      l: [
        [ 1, 0],
        [-2, 0],
        [ 1,-2],
        [-2, 1]
      ]
    },
    { # rotated counter-clocwize once
      r: [
        [ 1, 0],
        [-2, 0],
        [ 1,-2],
        [-2, 1]
      ],
      l: [
        [-2, 0],
        [ 1, 0],
        [-2,-1],
        [ 1, 2]
      ]
    }
  ]

  _ = nil

  O_POSITIONS = [
    [
      [_,_,_,_],
      [_,1,2,_],
      [_,3,4,_],
      [_,_,_,_]
    ],[
      [_,_,_,_],
      [_,3,1,_],
      [_,4,2,_],
      [_,_,_,_]
    ],[
      [_,_,_,_],
      [_,4,3,_],
      [_,2,1,_],
      [_,_,_,_]
    ],[
      [_,_,_,_],
      [_,2,4,_],
      [_,1,3,_],
      [_,_,_,_]
    ]
  ]

  Z_POSITIONS = [
    [
      [1,2,_],
      [_,3,4],
      [_,_,_]
    ],
    [
      [_,_,1],
      [_,3,2],
      [_,4,_]
    ],
    [
      [_,_,_],
      [4,3,_],
      [_,2,1]
    ],
    [
      [_,4,_],
      [2,3,_],
      [1,_,_]
    ]
  ]

  S_POSITIONS = [
    [
      [_,1,2],
      [3,4,_],
      [_,_,_]
    ],
    [
      [_,3,_],
      [_,4,1],
      [_,_,2]
    ],
    [
      [_,_,_],
      [_,4,3],
      [2,1,_]
    ],
    [
      [2,_,_],
      [1,4,_],
      [_,3,_]
    ]
  ]

  I_POSITIONS = [
    [
      [_,_,_,_],
      [1,2,3,4],
      [_,_,_,_],
      [_,_,_,_]
    ],
    [
      [_,_,1,_],
      [_,_,2,_],
      [_,_,3,_],
      [_,_,4,_]
    ],
    [
      [_,_,_,_],
      [_,_,_,_],
      [4,3,2,1],
      [_,_,_,_]
    ],
    [
      [_,4,_,_],
      [_,3,_,_],
      [_,2,_,_],
      [_,1,_,_]
    ]
  ]

  T_POSITIONS = [
    [
      [_,4,_],
      [3,2,1],
      [_,_,_]
    ],
    [
      [_,3,_],
      [_,2,4],
      [_,1,_]
    ],
    [
      [_,_,_],
      [1,2,3],
      [_,4,_]
    ],
    [
      [_,1,_],
      [4,2,_],
      [_,3,_]
    ]
  ]

  L_POSITIONS = [
    [
      [_,_,4],
      [3,2,1],
      [_,_,_]
    ],
    [
      [_,3,_],
      [_,2,_],
      [_,1,4]
    ],
    [
      [_,_,_],
      [1,2,3],
      [4,_,_]
    ],
    [
      [4,1,_],
      [_,2,_],
      [_,3,_]
    ]
  ]

  J_POSITIONS = [
    [
      [4,_,_],
      [3,2,1],
      [_,_,_]
    ],
    [
      [_,3,4],
      [_,2,_],
      [_,1,_]
    ],
    [
      [_,_,_],
      [1,2,3],
      [_,_,4]
    ],
    [
      [_,1,_],
      [_,2,_],
      [4,3,_]
    ]
  ]

  I = new(I_POSITIONS, KICK_DATA_I, 0)
  J = new(J_POSITIONS, KICK_DATA_3, 1)
  L = new(L_POSITIONS, KICK_DATA_3, 2)
  O = new(O_POSITIONS, nil,         3)
  S = new(S_POSITIONS, KICK_DATA_3, 4)
  T = new(T_POSITIONS, KICK_DATA_3, 5)
  Z = new(Z_POSITIONS, KICK_DATA_3, 6)

  ALL = [I,J,L,O,S,T,Z]
end
