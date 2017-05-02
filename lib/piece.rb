class Piece
  def initialize(positions, color_index=0, rotation=0)
    @positions = positions
    @color_index = color_index
    @rotation = rotation
  end

  def rotated_right
    r = dup
    r._rotation += 1
    r
  end

  def rotated_left
    r = dup
    r._rotation -= 1
    r
  end

  def with_game_state(game_state)
    p = self.dup
    p.instance_variable_set('@game_state', game_state)
    p
  end

  def squares_with_coordinates(cursor_x, cursor_y)
    ret = {}
    @positions[@rotation].each_with_index do |row, row_index|
      row.each_with_index do |square, column_index|
        if square
          square_x = cursor_x + (column_index*Square.width)
          square_y = cursor_y + (row_index*Square.height)
          ret[[row_index,column_index]] = [Square.new(@color_index, @game_state), square_x, square_y]
        end
      end
    end
    1.upto(@positions[@rotation].size - 1) do |row_index|
      1.upto(@positions[@rotation][row_index].size - 1) do |column_index|
        ret[[row_index,column_index]].try(:first).try(:left=, ret[[row_index,column_index-1]].try(:first))
        ret[[row_index,column_index]].try(:first).try(:up=, ret[[row_index-1,column_index]].try(:first))
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

  _ = nil

  O_POSITIONS = [
    [
      [_,_,_,_],
      [_,_,_,_],
      [_,1,2,_],
      [_,3,4,_]
    ],[
      [_,_,_,_],
      [_,_,_,_],
      [_,3,1,_],
      [_,4,2,_]
    ],[
      [_,_,_,_],
      [_,_,_,_],
      [_,4,3,_],
      [_,2,1,_]
    ],[
      [_,_,_,_],
      [_,_,_,_],
      [_,2,4,_],
      [_,1,3,_]
    ]
  ]

  Z_POSITIONS = [
    [
      [_,_,_,_],
      [_,_,_,_],
      [_,1,2,_],
      [_,_,3,4]
    ],
    [
      [_,_,_,_],
      [_,_,_,1],
      [_,_,3,2],
      [_,_,4,_]
    ],
    [
      [_,_,_,_],
      [_,_,_,_],
      [_,4,3,_],
      [_,_,2,1]
    ],
    [
      [_,_,_,_],
      [_,_,_,4],
      [_,_,2,3],
      [_,_,1,_]
    ]
  ]

  S_POSITIONS = [
    [
      [_,_,_,_],
      [_,_,_,_],
      [_,_,1,2],
      [_,3,4,_]
    ],
    [
      [_,_,_,_],
      [_,_,3,_],
      [_,_,4,1],
      [_,_,_,2]
    ],
    [
      [_,_,_,_],
      [_,_,_,_],
      [_,_,4,3],
      [_,2,1,_]
    ],
    [
      [_,_,_,_],
      [_,_,2,_],
      [_,_,1,4],
      [_,_,_,3]
    ]
  ]

  I_POSITIONS = [
    [
      [_,_,_,_],
      [_,_,_,_],
      [1,2,3,4],
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
      [_,_,4,_],
      [_,_,3,_],
      [_,_,2,_],
      [_,_,1,_]
    ]
  ]

  T_POSITIONS = [
    [
      [_,_,_,_],
      [_,_,_,_],
      [_,1,2,3],
      [_,_,4,_]
    ],
    [
      [_,_,_,_],
      [_,_,1,_],
      [_,4,2,_],
      [_,_,3,_]
    ],
    [
      [_,_,_,_],
      [_,_,4,_],
      [_,3,2,1],
      [_,_,_,_]
    ],
    [
      [_,_,_,_],
      [_,_,3,_],
      [_,_,2,4],
      [_,_,1,_]
    ]
  ]

  L_POSITIONS = [
    [
      [_,_,_,_],
      [_,_,_,_],
      [_,1,2,3],
      [_,4,_,_]
    ],
    [
      [_,_,_,_],
      [_,4,1,_],
      [_,_,2,_],
      [_,_,3,_]
    ],
    [
      [_,_,_,_],
      [_,_,_,4],
      [_,3,2,1],
      [_,_,_,_]
    ],
    [
      [_,_,_,_],
      [_,_,3,_],
      [_,_,2,_],
      [_,_,1,4]
    ]
  ]

  J_POSITIONS = [
    [
      [_,_,_,_],
      [_,_,_,_],
      [_,1,2,3],
      [_,_,_,4]
    ],
    [
      [_,_,_,_],
      [_,_,1,_],
      [_,_,2,_],
      [_,4,3,_]
    ],
    [
      [_,_,_,_],
      [_,4,_,_],
      [_,3,2,1],
      [_,_,_,_]
    ],
    [
      [_,_,_,_],
      [_,_,3,4],
      [_,_,2,_],
      [_,_,1,_]
    ]
  ]

  I = new(I_POSITIONS,0)
  J = new(J_POSITIONS,1)
  L = new(L_POSITIONS,2)
  O = new(O_POSITIONS,3)
  S = new(S_POSITIONS,4)
  T = new(T_POSITIONS,5)
  Z = new(Z_POSITIONS,6)

  ALL = [I,J,L,O,S,T,Z]
end
