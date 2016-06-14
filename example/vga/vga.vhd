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

entity vga is
    port(clk   : in  std_logic;
         reset : in  std_logic;
         en    : out std_logic;
         HS    : out std_logic;
         VS    : out std_logic;
         pix_x : out integer;
         pix_y : out integer);
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
begin
    HS_counter : vga_counter
        generic map (16, 96, 640, 48)
        port    map (clk, reset, HS_en, HS_s, pix_x);

    VS_counter : vga_counter
        generic map (10, 2, 480, 29)
        port    map (HS_s, reset, VS_en, VS, pix_y);

    en <= hs_en and vs_en;
    HS <= HS_s;
end rtl;
