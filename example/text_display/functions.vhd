library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

package functions is
    function vga_output( colour : std_logic_vector(7 downto 0); enable : std_logic) return std_logic_vector;

end functions;

package body functions is
    function vga_output(
        colour : std_logic_vector(7 downto 0); enable : std_logic) return std_logic_vector is
    begin
        if enable = '1' then
            return colour;
        else
            return (others => '0');
        end if;
    end function;
end functions;

