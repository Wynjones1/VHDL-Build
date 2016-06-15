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
              output : out text_display_out_t);
    end component;

    signal text_display_out_s : text_display_out_t;
begin
    text_display_0:
        text_display
        port map (clk, reset, text_display_out_s);

    hs    <= text_display_out_s.hs;
    vs    <= text_display_out_s.vs;
    red   <= text_display_out_s.colour(7 downto 5);
    green <= text_display_out_s.colour(4 downto 2);
    blue  <= text_display_out_s.colour(1 downto 0);
end rtl;
