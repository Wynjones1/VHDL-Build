library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;
use work.text_display_comp.all;

entity top is
    port( clk   : in  std_logic;
          reset : in  std_logic;
          red   : out std_logic_vector(2 downto 0);
          green : out std_logic_vector(2 downto 0);
          blue  : out std_logic_vector(1 downto 0);
          hs    : out std_logic;
          vs    : out std_logic);
end top;

architecture rtl of top is
    component text_display is
        port( clk    : in  std_logic;
              reset  : in  std_logic;
              input  : in  text_display_in_t;
              output : out text_display_out_t);
    end component;

    signal text_display_in_s  : text_display_in_t;
    signal text_display_out_s : text_display_out_t;

    signal x      : natural range 0 to 640 - 1;
    signal y      : natural range 0 to 480 - 1;
    signal x_next : natural range 0 to 640 - 1;
    signal y_next : natural range 0 to 480 - 1;

    function next_char(c : character_t) return character_t is
    begin
        if c = PRINTABLE_END then
            return PRINTABLE_START;
        else
            return c + 1;
        end if;
    end function;

    function next_pix(a : integer; m : integer) return integer is
    begin
        if a = m - 1 then
            return 0;
        else
            return a + 1;
        end if;
    end function;

    signal text_ram_s : text_ram_t := (others => (others => 65));
    signal c      : character_t; 
    signal c_next : character_t; 
begin
    text_display_0:
        text_display
        port map (clk, reset, text_display_in_s, text_display_out_s);

    comb: process(x, y)
    begin
        x_next <= next_pix(x, 640);
        if x = 640 - 1 then
            y_next <= next_pix(y, 480);
        end if;
        c_next <= next_char(c);
    end process;

    seq: process(clk, reset)
    begin
        if reset = '1' then
            x <= 0;
            y <= 0;
        elsif rising_edge(clk) then
            x <= x_next;
            y <= y_next;
            c <= c_next;
        end if;
    end process;

    text_display_in_s.wx <= x;
    text_display_in_s.wy <= y;
    text_display_in_s.we <= '1';
    text_display_in_s.wd <= c;

    hs    <= text_display_out_s.hs;
    vs    <= text_display_out_s.vs;
    red   <= text_display_out_s.colour(7 downto 5);
    green <= text_display_out_s.colour(4 downto 2);
    blue  <= text_display_out_s.colour(1 downto 0);
end rtl;
