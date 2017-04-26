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

  def squares_with_coordinates(cursor_x, cursor_y)
    ret = []
    @positions[@rotation].each_with_index do |row, row_index|
      row.each_with_index do |square, column_index|
        if square
          square_x = cursor_x + (column_index*Square.width)
          square_y = cursor_y + (row_index*Square.height)
          ret << [Sprites::SQUARES[@color_index % Sprites::SQUARES.size], square_x, square_y]
        end
      end
    end
    ret
  end

  def _rotation
    @rotation
  end

  def _rotation=(number)
    @rotation = number % @positions.size
  end

  _ = nil

  Q_POSITIONS = [
    [
      [_,_,_,_],
      [_,_,_,_],
      [_,1,1,_],
      [_,1,1,_]
    ],[
      [_,_,_,_],
      [_,_,_,_],
      [_,1,1,_],
      [_,1,1,_]
    ],[
      [_,_,_,_],
      [_,_,_,_],
      [_,1,1,_],
      [_,1,1,_]
    ],[
      [_,_,_,_],
      [_,_,_,_],
      [_,1,1,_],
      [_,1,1,_]
    ]
  ]

  Z_POSITIONS = [
    [
      [_,_,_,_],
      [_,_,_,_],
      [_,1,1,_],
      [_,_,1,1]
    ],
    [
      [_,_,_,_],
      [_,_,_,1],
      [_,_,1,1],
      [_,_,1,_]
    ],
    [
      [_,_,_,_],
      [_,_,_,_],
      [_,1,1,_],
      [_,_,1,1]
    ],
    [
      [_,_,_,_],
      [_,_,_,1],
      [_,_,1,1],
      [_,_,1,_]
    ]
  ]

  S_POSITIONS = [
    [
      [_,_,_,_],
      [_,_,_,_],
      [_,_,1,1],
      [_,1,1,_]
    ],
    [
      [_,_,_,_],
      [_,_,1,_],
      [_,_,1,1],
      [_,_,_,1]
    ],
    [
      [_,_,_,_],
      [_,_,_,_],
      [_,_,1,1],
      [_,1,1,_]
    ],
    [
      [_,_,_,_],
      [_,_,1,_],
      [_,_,1,1],
      [_,_,_,1]
    ]
  ]

  I_POSITIONS = [
    [
      [_,_,_,_],
      [_,_,_,_],
      [1,1,1,1],
      [_,_,_,_]
    ],
    [
      [_,_,1,_],
      [_,_,1,_],
      [_,_,1,_],
      [_,_,1,_]
    ],
    [
      [_,_,_,_],
      [_,_,_,_],
      [1,1,1,1],
      [_,_,_,_]
    ],
    [
      [_,_,1,_],
      [_,_,1,_],
      [_,_,1,_],
      [_,_,1,_]
    ]
  ]

  T_POSITIONS = [
    [
      [_,_,_,_],
      [_,_,_,_],
      [_,1,1,1],
      [_,_,1,_]
    ],
    [
      [_,_,_,_],
      [_,_,1,_],
      [_,1,1,_],
      [_,_,1,_]
    ],
    [
      [_,_,_,_],
      [_,_,1,_],
      [_,1,1,1],
      [_,_,_,_]
    ],
    [
      [_,_,_,_],
      [_,_,1,_],
      [_,_,1,1],
      [_,_,1,_]
    ]
  ]

  L_POSITIONS = [
    [
      [_,_,_,_],
      [_,_,_,_],
      [_,1,1,1],
      [_,1,_,_]
    ],
    [
      [_,_,_,_],
      [_,1,1,_],
      [_,_,1,_],
      [_,_,1,_]
    ],
    [
      [_,_,_,_],
      [_,_,_,1],
      [_,1,1,1],
      [_,_,_,_]
    ],
    [
      [_,_,_,_],
      [_,_,1,_],
      [_,_,1,_],
      [_,_,1,1]
    ]
  ]

  J_POSITIONS = [
    [
      [_,_,_,_],
      [_,_,_,_],
      [_,1,1,1],
      [_,_,_,1]
    ],
    [
      [_,_,_,_],
      [_,_,1,_],
      [_,_,1,_],
      [_,1,1,_]
    ],
    [
      [_,_,_,_],
      [_,1,_,_],
      [_,1,1,1],
      [_,_,_,_]
    ],
    [
      [_,_,_,_],
      [_,_,1,1],
      [_,_,1,_],
      [_,_,1,_]
    ]
  ]

  Q = new(Q_POSITIONS,0)
  Z = new(Z_POSITIONS,1)
  S = new(S_POSITIONS,2)
  T = new(T_POSITIONS,3)
  I = new(I_POSITIONS,4)
  L = new(L_POSITIONS,5)
  J = new(J_POSITIONS,6)

  ALL = [Q,Z,S,T,I,L,J]
end
