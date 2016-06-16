library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

package vga_counter_comp is
    type vga_counter_out_t is
        record
            sync   : std_logic;
            enable : std_logic;
            pix    : natural;
        end record;
end package;

library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;
use work.vga_counter_comp.all;

entity vga_counter is
    generic(FP : natural;
            PW : natural;
            DT : natural;
            BP : natural);
    port(clk    : in  std_logic;
         reset  : in  std_logic;
         output : out vga_counter_out_t);
end vga_counter;

architecture rtl of vga_counter is
    constant COUNT_MAX : natural := FP + PW + DT + BP;
    subtype counter_t is natural range 0 to COUNT_MAX - 1;

    signal counter_s      : counter_t;
    signal counter_next_s : counter_t;
    signal output_next_s  : vga_counter_out_t;
begin
    comb : process(counter_s)
    begin
        counter_next_s <= (counter_s + 1) mod COUNT_MAX;

        if    counter_s < DT           then output_next_s <= ('1', '1', counter_s); -- Display Time
        elsif counter_s < DT + FP      then output_next_s <= ('1', '0', counter_s); -- Front Porch
        elsif counter_s < DT + FP + PW then output_next_s <= ('0', '0', counter_s); -- Pulse Width
        else                                output_next_s <= ('1', '0', counter_s); -- Back Porce
        end if;
    end process;

    seq : process(clk, reset)
    begin
        if reset = '1' then
            output    <= ('1', '1', 0);
            counter_s <= 0;
        elsif rising_edge(clk) then
            output    <= output_next_s;
            counter_s <= counter_next_s;
        end if;
    end process;
end rtl;

library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

package vga_comp is
    subtype width_t  is natural range 0 to 640 - 1;
    subtype height_t is natural range 0 to 480 - 1;

    type vga_out_t is
        record
            en    : std_logic;
            hs    : std_logic;
            vs    : std_logic;
            pix_x : width_t;
            pix_y : height_t;
        end record;
end package;

library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;
use work.vga_comp.all;
use work.vga_counter_comp.all;

entity vga is
    port(clk    : in  std_logic;
         reset  : in  std_logic;
         output : out vga_out_t);
end vga;

architecture rtl of vga is
    component vga_counter is
        generic(FP : natural;
                PW : natural;
                DT : natural;
                BP : natural);
        port(clk    : in  std_logic;
             reset  : in  std_logic;
             output : out vga_counter_out_t);
    end component;

    signal h_counter_out_s : vga_counter_out_t;
    signal v_counter_out_s : vga_counter_out_t;
begin
    HS_counter : vga_counter
        generic map (16, 96, 640, 48)
        port    map (clk, reset, h_counter_out_s);

    VS_counter : vga_counter
        generic map (10, 2, 480, 29)
        port    map (h_counter_out_s.sync, reset, v_counter_out_s);

    comb: process(h_counter_out_s, v_counter_out_s)
    begin
        output.en    <= h_counter_out_s.enable and v_counter_out_s.enable;
        output.hs    <= h_counter_out_s.sync;
        output.vs    <= v_counter_out_s.sync;

        if h_counter_out_s.pix < 640 then
            output.pix_x <= h_counter_out_s.pix;
        else
            output.pix_x <= 0;
        end if;

        if v_counter_out_s.pix < 480 then
            output.pix_y <= v_counter_out_s.pix;
        else
            output.pix_y <= 0;
        end if;
    end process;
end rtl;
