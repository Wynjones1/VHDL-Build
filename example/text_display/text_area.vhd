library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

package text_display_comp is
    constant TEXT_WIDTH  : integer := 80;
    constant TEXT_HEIGHT : integer := 60;
    constant TILE_WIDTH  : integer := 8;
    constant TILE_HEIGHT : integer := 8;

    subtype character_t is integer range 0 to 127;
    type    glyph_t     is array (0 to 7)               of std_logic_vector(7 downto 0);
    type    glyph_rom_t is array (0 to 127)             of glyph_t;
    type    line_t      is array (0 to TEXT_WIDTH  - 1) of character_t;
    type    text_ram_t  is array (0 to TEXT_HEIGHT - 1) of line_t;

    constant FONT_ROM : glyph_rom_t := (
        ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000"),
        ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000"),
        ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000"),
        ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000"),
        ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000"),
        ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000"),
        ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000"),
        ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000"),
        ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000"),
        ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000"),
        ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000"),
        ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000"),
        ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000"),
        ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000"),
        ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000"),
        ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000"),
        ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000"),
        ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000"),
        ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000"),
        ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000"),
        ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000"),
        ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000"),
        ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000"),
        ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000"),
        ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000"),
        ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000"),
        ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000"),
        ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000"),
        ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000"),
        ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000"),
        ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000"),
        ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000"),
        ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000"),
        ("00011000","00111100","00111100","00011000","00011000","00000000","00011000","00000000"),
        ("01101100","01101100","00000000","00000000","00000000","00000000","00000000","00000000"),
        ("01101100","01101100","11111110","01101100","11111110","01101100","01101100","00000000"),
        ("00110000","01111100","11000000","01111000","00001100","11111000","00110000","00000000"),
        ("00000000","11000110","11001100","00011000","00110000","01100110","11000110","00000000"),
        ("00111000","01101100","00111000","01110110","11011100","11001100","01110110","00000000"),
        ("01100000","01100000","11000000","00000000","00000000","00000000","00000000","00000000"),
        ("00011000","00110000","01100000","01100000","01100000","00110000","00011000","00000000"),
        ("01100000","00110000","00011000","00011000","00011000","00110000","01100000","00000000"),
        ("00000000","01100110","00111100","11111111","00111100","01100110","00000000","00000000"),
        ("00000000","00110000","00110000","11111100","00110000","00110000","00000000","00000000"),
        ("00000000","00000000","00000000","00000000","00000000","00110000","00110000","01100000"),
        ("00000000","00000000","00000000","11111100","00000000","00000000","00000000","00000000"),
        ("00000000","00000000","00000000","00000000","00000000","00110000","00110000","00000000"),
        ("00000110","00001100","00011000","00110000","01100000","11000000","10000000","00000000"),
        ("01111100","11000110","11001110","11011110","11110110","11100110","01111100","00000000"),
        ("00110000","01110000","00110000","00110000","00110000","00110000","11111100","00000000"),
        ("01111000","11001100","00001100","00111000","01100000","11001100","11111100","00000000"),
        ("01111000","11001100","00001100","00111000","00001100","11001100","01111000","00000000"),
        ("00011100","00111100","01101100","11001100","11111110","00001100","00011110","00000000"),
        ("11111100","11000000","11111000","00001100","00001100","11001100","01111000","00000000"),
        ("00111000","01100000","11000000","11111000","11001100","11001100","01111000","00000000"),
        ("11111100","11001100","00001100","00011000","00110000","00110000","00110000","00000000"),
        ("01111000","11001100","11001100","01111000","11001100","11001100","01111000","00000000"),
        ("01111000","11001100","11001100","01111100","00001100","00011000","01110000","00000000"),
        ("00000000","00110000","00110000","00000000","00000000","00110000","00110000","00000000"),
        ("00000000","00110000","00110000","00000000","00000000","00110000","00110000","01100000"),
        ("00011000","00110000","01100000","11000000","01100000","00110000","00011000","00000000"),
        ("00000000","00000000","11111100","00000000","00000000","11111100","00000000","00000000"),
        ("01100000","00110000","00011000","00001100","00011000","00110000","01100000","00000000"),
        ("01111000","11001100","00001100","00011000","00110000","00000000","00110000","00000000"),
        ("01111100","11000110","11011110","11011110","11011110","11000000","01111000","00000000"),
        ("00110000","01111000","11001100","11001100","11111100","11001100","11001100","00000000"),
        ("11111100","01100110","01100110","01111100","01100110","01100110","11111100","00000000"),
        ("00111100","01100110","11000000","11000000","11000000","01100110","00111100","00000000"),
        ("11111000","01101100","01100110","01100110","01100110","01101100","11111000","00000000"),
        ("11111110","01100010","01101000","01111000","01101000","01100010","11111110","00000000"),
        ("11111110","01100010","01101000","01111000","01101000","01100000","11110000","00000000"),
        ("00111100","01100110","11000000","11000000","11001110","01100110","00111110","00000000"),
        ("11001100","11001100","11001100","11111100","11001100","11001100","11001100","00000000"),
        ("01111000","00110000","00110000","00110000","00110000","00110000","01111000","00000000"),
        ("00011110","00001100","00001100","00001100","11001100","11001100","01111000","00000000"),
        ("11100110","01100110","01101100","01111000","01101100","01100110","11100110","00000000"),
        ("11110000","01100000","01100000","01100000","01100010","01100110","11111110","00000000"),
        ("11000110","11101110","11111110","11111110","11010110","11000110","11000110","00000000"),
        ("11000110","11100110","11110110","11011110","11001110","11000110","11000110","00000000"),
        ("00111000","01101100","11000110","11000110","11000110","01101100","00111000","00000000"),
        ("11111100","01100110","01100110","01111100","01100000","01100000","11110000","00000000"),
        ("01111000","11001100","11001100","11001100","11011100","01111000","00011100","00000000"),
        ("11111100","01100110","01100110","01111100","01101100","01100110","11100110","00000000"),
        ("01111000","11001100","11100000","01110000","00011100","11001100","01111000","00000000"),
        ("11111100","10110100","00110000","00110000","00110000","00110000","01111000","00000000"),
        ("11001100","11001100","11001100","11001100","11001100","11001100","11111100","00000000"),
        ("11001100","11001100","11001100","11001100","11001100","01111000","00110000","00000000"),
        ("11000110","11000110","11000110","11010110","11111110","11101110","11000110","00000000"),
        ("11000110","11000110","01101100","00111000","00111000","01101100","11000110","00000000"),
        ("11001100","11001100","11001100","01111000","00110000","00110000","01111000","00000000"),
        ("11111110","11000110","10001100","00011000","00110010","01100110","11111110","00000000"),
        ("01111000","01100000","01100000","01100000","01100000","01100000","01111000","00000000"),
        ("11000000","01100000","00110000","00011000","00001100","00000110","00000010","00000000"),
        ("01111000","00011000","00011000","00011000","00011000","00011000","01111000","00000000"),
        ("00010000","00111000","01101100","11000110","00000000","00000000","00000000","00000000"),
        ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","11111111"),
        ("00110000","00110000","00011000","00000000","00000000","00000000","00000000","00000000"),
        ("00000000","00000000","01111000","00001100","01111100","11001100","01110110","00000000"),
        ("11100000","01100000","01100000","01111100","01100110","01100110","11011100","00000000"),
        ("00000000","00000000","01111000","11001100","11000000","11001100","01111000","00000000"),
        ("00011100","00001100","00001100","01111100","11001100","11001100","01110110","00000000"),
        ("00000000","00000000","01111000","11001100","11111100","11000000","01111000","00000000"),
        ("00111000","01101100","01100000","11110000","01100000","01100000","11110000","00000000"),
        ("00000000","00000000","01110110","11001100","11001100","01111100","00001100","11111000"),
        ("11100000","01100000","01101100","01110110","01100110","01100110","11100110","00000000"),
        ("00110000","00000000","01110000","00110000","00110000","00110000","01111000","00000000"),
        ("00001100","00000000","00001100","00001100","00001100","11001100","11001100","01111000"),
        ("11100000","01100000","01100110","01101100","01111000","01101100","11100110","00000000"),
        ("01110000","00110000","00110000","00110000","00110000","00110000","01111000","00000000"),
        ("00000000","00000000","11001100","11111110","11111110","11010110","11000110","00000000"),
        ("00000000","00000000","11111000","11001100","11001100","11001100","11001100","00000000"),
        ("00000000","00000000","01111000","11001100","11001100","11001100","01111000","00000000"),
        ("00000000","00000000","11011100","01100110","01100110","01111100","01100000","11110000"),
        ("00000000","00000000","01110110","11001100","11001100","01111100","00001100","00011110"),
        ("00000000","00000000","11011100","01110110","01100110","01100000","11110000","00000000"),
        ("00000000","00000000","01111100","11000000","01111000","00001100","11111000","00000000"),
        ("00010000","00110000","01111100","00110000","00110000","00110100","00011000","00000000"),
        ("00000000","00000000","11001100","11001100","11001100","11001100","01110110","00000000"),
        ("00000000","00000000","11001100","11001100","11001100","01111000","00110000","00000000"),
        ("00000000","00000000","11000110","11010110","11111110","11111110","01101100","00000000"),
        ("00000000","00000000","11000110","01101100","00111000","01101100","11000110","00000000"),
        ("00000000","00000000","11001100","11001100","11001100","01111100","00001100","11111000"),
        ("00000000","00000000","11111100","10011000","00110000","01100100","11111100","00000000"),
        ("00011100","00110000","00110000","11100000","00110000","00110000","00011100","00000000"),
        ("00011000","00011000","00011000","00000000","00011000","00011000","00011000","00000000"),
        ("11100000","00110000","00110000","00011100","00110000","00110000","11100000","00000000"),
        ("01110110","11011100","00000000","00000000","00000000","00000000","00000000","00000000"),
        ("00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000"));

    type text_display_out_t is
        record
            colour : std_logic_vector(7 downto 0);
            hs     : std_logic;
            vs     : std_logic;
        end record;

end text_display_comp;

library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;
use work.text_display_comp.all;
use work.vga_comp.all;

entity text_display is
    port( clk    : in  std_logic;
          reset  : in  std_logic;
          output : out text_display_out_t);
end;

architecture rtl of text_display is
    -- components
    component clk_gen is
        generic( CLOCK_SPEED : integer := 50_000_000;
                 REQUIRED_HZ : integer := 1);
        port( clk     : in std_logic;
              reset   : in std_logic;
              clk_out : out std_logic);
    end component;

    component vga is
        port(clk    : in  std_logic;
             reset  : in  std_logic;
             output : out vga_out_t);
    end component;

    -- functions
    function get_glyph_value(glyph : glyph_t; x : integer; y : integer) return std_logic
    is
    begin
        return glyph(y)(7 - x);
    end function;

    -- signals
    signal vga_clk_s : std_logic;
    signal vga_out_s : vga_out_t;
    signal colour_s  : std_logic_vector(7 downto 0);

    signal glyph_s      : glyph_t;
    signal char_s       : character_t;
    signal next_glyph_s : glyph_t;
    signal next_char_s  : character_t;

    signal tile_x_s    : integer range 0 to TEXT_WIDTH - 1;
    signal tile_y_s    : integer range 0 to TEXT_HEIGHT - 1;
    signal offset_x_s  : integer range 0 to TILE_WIDTH - 1;
    signal offset_y_s  : integer range 0 to TILE_HEIGHT - 1;
begin
    clk_gen_0:
        clk_gen
        generic map (REQUIRED_HZ => 25_000_000)
        port map (clk, reset, vga_clk_s);

    vga_0:
        vga
        port map (vga_clk_s, reset, vga_out_s);

    comb :
    process(reset, vga_out_s, char_s, glyph_s, colour_s)
    begin
        if reset = '1' then
            tile_x_s   <= 0;
            tile_y_s   <= 0;
            offset_x_s <= 0;
            offset_y_s <= 0;
        else
            tile_x_s   <= vga_out_s.pix_x / TILE_WIDTH;
            tile_y_s   <= vga_out_s.pix_y / TILE_HEIGHT;
            offset_x_s <= vga_out_s.pix_x mod TILE_WIDTH;
            offset_y_s <= vga_out_s.pix_y mod TILE_HEIGHT;
        end if;

        output.hs <= vga_out_s.hs;
        output.vs <= vga_out_s.vs;

        next_char_s <= (tile_y_s * TILE_WIDTH + tile_x_s) mod 128;

        next_glyph_s <= FONT_ROM(char_s);

        if get_glyph_value(glyph_s, offset_x_s, offset_y_s) = '1' then
            colour_s <= "11100000";
        else
            colour_s <= "00000000";
        end if;

        if vga_out_s.en = '1' then
            output.colour <= colour_s;
        else
            output.colour <= (others => '0');
        end if;
    end process;

    seq :
    process(clk, reset)
    begin
        if reset = '1' then
            char_s  <= 0;
        elsif rising_edge(clk) then
            glyph_s <= next_glyph_s;
            char_s  <= next_char_s;
        end if;
    end process;
end rtl;
