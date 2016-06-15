library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

entity vga_counter is
    generic(FP : integer;
            PW : integer;
            DT : integer;
            BP : integer);
    port(clk   : in  std_logic;
         reset : in  std_logic;
         valid : out std_logic;
         sync  : out std_logic;
         pix   : out integer);
end vga_counter;

architecture rtl of vga_counter is
    signal counter : integer range 0 to FP + PW + DT + BP- 1 := 0;
begin
    process(clk, reset)
    begin
        if reset = '1' then
            counter <= 0;
            valid   <= '0';
            sync    <= '1';
        elsif rising_edge(clk) then
            if counter < DT - 1 then
                sync    <= '1';
                counter <= counter + 1;
                valid   <= '1';
            elsif counter < DT + FP - 1 then
                sync    <= '1';
                counter <= counter + 1;
                valid   <= '0';
            elsif counter < DT + FP + PW - 1 then
                sync    <= '0';
                counter <= counter + 1;
                valid   <= '0';
            elsif counter < DT + FP + PW + BP - 1 then
                sync    <= '1';
                counter <= counter + 1;
                valid   <= '0';
            else
                sync    <= '1';
                counter <= 0;
                valid   <= '1';
            end if;

        end if;
    end process;

    pix <= counter;
end rtl;

library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

package vga_comp is
    subtype width_t  is integer range 0 to 640 - 1;
    subtype height_t is integer range 0 to 480 - 1;

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

entity vga is
    port(clk    : in  std_logic;
         reset  : in  std_logic;
         output : out vga_out_t);
end vga;

architecture rtl of vga is
    component vga_counter is
        generic(FP : integer;
                PW : integer;
                DT : integer;
                BP : integer);
        port(clk   : in  std_logic;
             reset : in  std_logic;
             valid : out std_logic;
             sync  : out std_logic;
             pix   : out integer);
    end component;
    signal hs_en : std_logic := '0';
    signal vs_en : std_logic := '0';
    signal HS_s  : std_logic := '0';
    signal VS_s  : std_logic := '0';
    signal X_s   : width_t;
    signal Y_s   : height_t;
begin
    HS_counter : vga_counter
        generic map (16, 96, 640, 48)
        port    map (clk, reset, HS_en, HS_s, X_s);

    VS_counter : vga_counter
        generic map (10, 2, 480, 29)
        port    map (HS_s, reset, VS_en, VS_s, Y_s);

    output.en    <= hs_en and vs_en;
    output.hs    <= HS_s;
    output.vs    <= VS_s;
    output.pix_x <= X_s;
    output.pix_y <= Y_s;
end rtl;
