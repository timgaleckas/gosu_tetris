module Colors
  def self.from_hex(hex_string)
    Gosu::Color.new(*hex_string[1..-1].scan(/.{2}/).map{|s|s.to_i(16)})
  end

  FG = "#000022"

  MENU_BACKGROUND_HEX = "#DDDDBB"
  MENU_BACKGROUND = from_hex(MENU_BACKGROUND_HEX)

  MENU_BUTTON_BG_HEX = "#3D484C"
  MENU_BUTTON_FG_HEX = "#0078A8"
  MENU_BUTTON_FG_HOVERED_HEX = "#116688"
  MENU_BUTTON_TEXT_HEX = "#E0DAF2"

  MENU_BUTTON_BG = from_hex(MENU_BUTTON_BG_HEX)
  MENU_BUTTON_FG = from_hex(MENU_BUTTON_FG_HEX)
  MENU_BUTTON_FG_HOVERED = from_hex(MENU_BUTTON_FG_HOVERED_HEX)
  MENU_BUTTON_TEXT = from_hex(MENU_BUTTON_TEXT_HEX)


  COLOR_HEXS = [
    "#000022",
    "#005566",
    "#0078A8",
    "#101011",
    "#116688",
    "#2B2B2B",
    "#3D484C",
    "#442299",
    "#513F7F",
    "#667755",
    "#668811",
    "#883311",
    "#8899AA",
    "#99E1FF",
    "#9B79F2",
    "#B9ADD8",
    "#CCDDAA",
    "#CCF0FF",
    "#D7DBDD",
    "#DDDDBB",
    "#E0DAF2",
    "#E3E8EA",
    "#F2F2F2",
    "#FFFFEE",
    "#FFFFFF"
  ]
  COLORS = COLOR_HEXS.map{|s| from_hex(s) }
end
