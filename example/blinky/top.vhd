library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

entity top is
    port( clk   : in  std_logic;
          reset : in  std_logic;
          led   : out std_logic);
end top;

architecture rtl of top is
    component clk_gen is
        generic( CLOCK_SPEED : integer := 50_000_000;
                 REQUIRED_HZ : integer := 1);
        port( clk     : in std_logic;
              reset   : in std_logic;
              clk_out : out std_logic);
    end component;

    constant CLK_HZ : integer := 50_000_000;

    signal hz_clk : std_logic;
    signal led_s  : std_logic;
begin

    gen_1hz_clk : clk_gen
        generic map (REQUIRED_HZ => CLK_HZ / 2)
        port    map (clk, reset, hz_clk);

    combinatoral:
    process(led_s)
    begin
        led <= led_s;
    end process;

    sequential:
    process(hz_clk, reset)
    begin
        if reset = '1' then
            led_s <= '0';
        elsif rising_edge(hz_clk) then
            if led_s = '1' then
                led_s <= '0';
            else
                led_s <= '1';
            end if;
        end if;
    end process;
end rtl;
