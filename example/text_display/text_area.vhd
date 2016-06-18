library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;
use work.display_comp.all;

package text_display_comp is
    type text_display_in_t is
        record
            wx : natural range 0 to TEXT_WIDTH  - 1;
            wy : natural range 0 to TEXT_HEIGHT - 1;
            we : std_logic;
            wd : character_t;
        end record;

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
use work.vga_comp.all;
use work.text_ram_comp.all;
use work.text_display_comp.all;
use work.display_comp.all;

entity text_display is
    port( clk    : in  std_logic;
          reset  : in  std_logic;
          input  : in  text_display_in_t;
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

    component text_ram is
        port(clk    : in  std_logic;
             reset  : in  std_logic;
             input  : in  text_ram_in_t;
             output : out text_ram_out_t);
    end component;

    -- types
    type tile_info_t is
        record
            tile_x   : natural range 0 to TEXT_WIDTH  - 1; 
            tile_y   : natural range 0 to TEXT_HEIGHT - 1; 
            offset_x : natural range 0 to TILE_WIDTH  - 1; 
            offset_y : natural range 0 to TILE_HEIGHT - 1; 
        end record;

    type stage0_t is
        record
            ti : tile_info_t;
            hs : std_logic;
            vs : std_logic;
            en : std_logic;
        end record;

    type stage1_t is
        record
            ti : tile_info_t;
            hs : std_logic;
            vs : std_logic;
            en : std_logic;
            ch : character_t;
        end record;

    type stage2_t is
        record
            ti : tile_info_t;
            hs : std_logic;
            vs : std_logic;
            en : std_logic;
            gl : glyph_t;
        end record;

    -- functions
    function get_glyph_value(glyph : glyph_t; x : integer; y : integer) return std_logic is
    begin
        return glyph(y)(7 - x);
    end function;

    function make_tile_info(pix_x : natural; pix_y : natural) return tile_info_t is
    begin
        return (pix_x /   TILE_WIDTH,
                pix_y /   TILE_HEIGHT,
                pix_x mod TILE_WIDTH,
                pix_y mod TILE_HEIGHT);
    end function;

    -- constants
    constant NUM_STAGES : natural := 3;

    -- signals
    signal vga_clk_s : std_logic;
    signal vga_out_s : vga_out_t;

    signal stage0_s : stage0_t;
    signal stage0_n : stage0_t;
    signal stage1_s : stage1_t;
    signal stage1_n : stage1_t;
    signal stage2_s : stage2_t;
    signal stage2_n : stage2_t;

    signal output_n : text_display_out_t;

    signal ram_in_s  : text_ram_in_t;
    signal ram_out_s : text_ram_out_t;
begin
    clk_gen_0: clk_gen
        generic map (REQUIRED_HZ => 25_000_000)
        port map (clk, reset, vga_clk_s);

    vga_0: vga
        port map (vga_clk_s, reset, vga_out_s);

    text_ram_0: text_ram
        port map (clk, reset, ram_in_s, ram_out_s);

    comb :
    process(vga_out_s, stage0_s, stage1_s, stage2_s, ram_out_s)
    begin
        -- sync -> tile info -> char -> glyph -> colour
        stage0_n.ti <= make_tile_info(vga_out_s.pix_x, vga_out_s.pix_y);
        stage0_n.vs <= vga_out_s.vs;
        stage0_n.hs <= vga_out_s.hs;
        stage0_n.en <= vga_out_s.en;

        ram_in_s <= (input.we, input.wd, input.wx, input.wy, vga_out_s.pix_x / TILE_WIDTH, vga_out_s.pix_y / TILE_HEIGHT);

        stage1_n.ti <= stage0_s.ti;
        stage1_n.vs <= stage0_s.vs;
        stage1_n.hs <= stage0_s.hs;
        stage1_n.en <= stage0_s.en;
        stage1_n.ch <= ram_out_s.data;

        stage2_n.ti <= stage1_s.ti;
        stage2_n.vs <= stage1_s.vs;
        stage2_n.hs <= stage1_s.hs;
        stage2_n.en <= stage1_s.en;
        stage2_n.gl <= FONT_ROM(stage1_s.ch);

        if stage2_s.en = '1' then
            output_n.colour <= (others => get_glyph_value( stage2_s.gl,
                                                           stage2_s.ti.offset_x,
                                                           stage2_s.ti.offset_y));
        else
            output_n.colour <= (others => '0');
        end if;
        output_n.hs <= stage2_s.hs;
        output_n.vs <= stage2_s.vs;

    end process;

    seq :
    process(clk, reset)
    begin
        if rising_edge(clk) then
            stage0_s <= stage0_n;
            stage1_s <= stage1_n;
            stage2_s <= stage2_n;
            output   <= output_n;
        end if;
    end process;
end rtl;
