module HexColor
  DEFAULT = "#c9b896"
  STORED = /\A#[0-9a-f]{6}\z/
  INPUT = /\A#?[0-9a-fA-F]{3}(?:[0-9a-fA-F]{3})?\z/

  def self.normalize(value)
    hex = value.to_s.strip.delete_prefix("#")
    return if hex.blank? || !hex.match?(INPUT)

    hex = hex.chars.map { |char| char * 2 }.join if hex.length == 3
    "##{hex.downcase}"
  end
end
