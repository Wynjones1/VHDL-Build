library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

entity tb is
end tb;

architecture rtl of tb is
    -- components
    component top is
        port( clk   : in  std_logic;
              reset : in  std_logic;
              led   : out std_logic);
    end component;

    -- signals
    signal clk    : std_logic;
    signal reset  : std_logic;
    signal led_s  : std_logic;
begin
    top0 : top
        port map (clk, reset, led_s);

    clk_gen:
    process
    begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    end process;

    reset_gen:
    process
    begin
        reset <= '1';
        wait for 50 ns;
        reset <= '0';
        wait;
    end process;
end rtl;
