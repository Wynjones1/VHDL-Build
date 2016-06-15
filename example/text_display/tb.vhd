library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

entity tb is
end;

architecture rtl of tb is
    component top is
        port( clk   : in  std_logic;
              reset : in  std_logic;
              red   : out std_logic_vector(2 downto 0);
              green : out std_logic_vector(2 downto 0);
              blue  : out std_logic_vector(1 downto 0);
              hs    : out std_logic;
              vs    : out std_logic);
    end component;

    signal clk   : std_logic;
    signal reset : std_logic;
begin

    top_0: top
        port map (clk, reset, open, open, open, open, open);

    clk_gen:
    process
    begin
        clk <= '0';
        wait for 1 ns;
        clk <= '1';
    end process;

    reset_gen:
    process
    begin
        reset <= '1';
        wait for 1 ns;
        reset <= '0';
    end process;
    
end rtl;
