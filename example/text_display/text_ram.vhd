library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;
use work.display_comp.all;

package text_ram_comp is
    type text_ram_in_t is
        record
            we : std_logic;
            wd : character_t;
            wx : natural range 0 to TEXT_WIDTH  - 1;
            wy : natural range 0 to TEXT_HEIGHT - 1;
            rx : natural range 0 to TEXT_WIDTH  - 1;
            ry : natural range 0 to TEXT_HEIGHT - 1;
        end record;

    type text_ram_out_t is
        record
            data : character_t;
        end record;
end package;

library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;
use work.text_ram_comp.all;
use work.display_comp.all;

entity text_ram is
    port(clk    : in  std_logic;
         reset  : in  std_logic;
         input  : in  text_ram_in_t;
         output : out text_ram_out_t);
end text_ram;

architecture rtl of text_ram is
    type ram_t is array(0 to TEXT_WIDTH * TEXT_HEIGHT - 1) of character_t;

    subtype index_t is natural range 0 to TEXT_WIDTH * TEXT_HEIGHT - 1;
    signal write_idx : index_t;
    signal read_idx  : index_t;
    signal ram_s     : ram_t;
begin
    comb : process(input)
    begin
        write_idx <= input.wy * TEXT_WIDTH + input.wx;
        read_idx  <= input.ry * TEXT_WIDTH + input.rx;
    end process;


    seq : process(clk, reset)
    begin
        if rising_edge(clk) then
            if input.we = '1' then
                ram_s(write_idx) <= input.wd;
            end if;
            output.data <= ram_s(read_idx);
        end if;
    end process;
end architecture;
