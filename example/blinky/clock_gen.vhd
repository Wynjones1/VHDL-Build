library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

entity clk_gen is
    generic( CLOCK_SPEED : integer := 50_000_000;
             REQUIRED_HZ : integer := 1);
    port( clk     : in std_logic;
          reset   : in std_logic;
          clk_out : out std_logic);
end;

architecture rtl of clk_gen is
    constant COUNT_MAX : integer := CLOCK_SPEED / (REQUIRED_HZ * 2);
    signal   count     : integer range 0 to COUNT_MAX - 1 := 0;
    signal   clk_s     : std_logic;
begin
    process(clk, reset)
    begin
        if reset = '1' then
            count <= 0;
            clk_s <= '0';
        elsif rising_edge(clk) then
            if count = COUNT_MAX - 1 then
                count <= 0;
                if clk_s = '1' then
                    clk_s <= '0';
                else
                    clk_s <= '1';
                end if;
            else
                count <= count + 1;
            end if;
        end if;
            
    end process;

    clk_out <= clk_s;
end architecture;

