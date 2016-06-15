library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

package types is
    type colour_t is (RED, GREEN, BLUE);

    function next_colour(c : colour_t) return colour_t;
end types;

package body types is
    function next_colour(c : colour_t) return colour_t is
    begin
        case c is
            when RED => return GREEN;
            when GREEN => return BLUE;
            when BLUE => return RED;
        end case;
    end function;
end types;

