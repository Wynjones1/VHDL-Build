library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;
use work.vga_comp.all;

entity tb is
end;

architecture rtl of tb is
    component vga is
        port(clk    : in  std_logic;
             reset  : in  std_logic;
             output : out vga_out_t);
    end component;

    signal clk    : std_logic;
    signal reset  : std_logic;
    signal output : vga_out_t;
begin

    vga_0 : vga
        port map (clk, reset, output);

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
        wait for 10 ns;
        reset <= '0';
        wait;
    end process;
    
end rtl;
