library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;
use work.display_comp.all;
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
    -- components
    component text_display is
        port( clk    : in  std_logic;
              reset  : in  std_logic;
              input  : in  text_display_in_t;
              output : out text_display_out_t);
    end component;

    component clk_gen is
        generic( CLOCK_SPEED : integer := 50_000_000;
                 REQUIRED_HZ : integer := 1);
        port( clk     : in std_logic;
              reset   : in std_logic;
              clk_out : out std_logic);
    end component;

    -- function
    function next_char(c : character_t) return character_t is
    begin
        if c = PRINTABLE_END - 1 then
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

    signal text_display_in_s  : text_display_in_t;
    signal text_display_out_s : text_display_out_t;
    signal x                  : natural range 0 to TEXT_WIDTH - 1;
    signal y                  : natural range 0 to TEXT_HEIGHT - 1;
    signal x_next             : natural range 0 to TEXT_WIDTH - 1;
    signal y_next             : natural range 0 to TEXT_HEIGHT - 1;
    signal c                  : character_t; 
    signal c_next             : character_t; 
    signal clk_1hz_s          : std_logic;
begin
    gen_1hz : clk_gen
        generic map (REQUIRED_HZ => (640 * 480) / 64)
        port map (clk, reset, clk_1hz_s);

    text_display_0: text_display
        port map (clk, reset, text_display_in_s, text_display_out_s);

    comb: process(x, y, c, reset, text_display_out_s)
    begin
        x_next <= next_pix(x, TEXT_WIDTH);
        if x = TEXT_WIDTH - 1 then
            y_next <= next_pix(y, TEXT_HEIGHT);
        else
            y_next <= y;
        end if;
        c_next <= next_char(c);

        text_display_in_s <= (x, y, not reset, c);

        hs    <= text_display_out_s.hs;
        vs    <= text_display_out_s.vs;
        red   <= text_display_out_s.colour(7 downto 5);
        green <= text_display_out_s.colour(4 downto 2);
        blue  <= text_display_out_s.colour(1 downto 0);
    end process;

    seq: process(clk_1hz_s, reset)
    begin
        if reset = '1' then
            x <= 0;
            y <= 0;
            c <= 64;
        elsif rising_edge(clk_1hz_s) then
            x <= x_next;
            y <= y_next;
            c <= c_next;
        end if;
    end process;

end rtl;
