library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

entity top is
    port( clk   : in  std_logic;
          reset : in  std_logic;
          red   : out std_logic_vector(2 downto 0);
          green : out std_logic_vector(2 downto 0);
          blue  : out std_logic_vector(1 downto 0);
          hs    : out std_logic;
          vs    : out std_logic);
end top;

architecture rtl of top is
    component clk_gen is
        generic( CLOCK_SPEED : integer := 50_000_000;
                 REQUIRED_HZ : integer := 1);
        port( clk     : in std_logic;
              reset   : in std_logic;
              clk_out : out std_logic);
    end component;

    component vga is
        port(clk   : in  std_logic;
             reset : in  std_logic;
             en    : out std_logic;
             HS    : out std_logic;
             VS    : out std_logic;
             pix_x : out integer;
             pix_y : out integer);
    end component;

    constant CLK_HZ : integer := 50_000_000;

    signal vga_clk_s     : std_logic;
    signal hz_clk_s      : std_logic;
    signal colour_s      : integer range 0 to 2;
    signal next_colour_s : integer range 0 to 2;
    signal out_col_s     : std_logic_vector(7 downto 0);
    signal vga_en_s      : std_logic;
begin

    gen_vga_clk : clk_gen
        generic map (REQUIRED_HZ => 25_000_000)
        port    map (clk, reset, vga_clk_s);

    gen_hz_clk : clk_gen
        generic map (REQUIRED_HZ => 1)
        port    map (clk, reset, hz_clk_s);

    vga0 : vga
        port map(vga_clk_s, reset, vga_en_s, hs, vs, open, open);

    combinatoral:
    process(colour_s)
    begin
        next_colour_s <= (colour_s + 1) mod 3;

        if vga_en_s = '1' then
            case colour_s is
                when 0 => out_col_s <= "11100000";
                when 1 => out_col_s <= "00011100";
                when 2 => out_col_s <= "00000011";
            end case;
        else
            out_col_s <= (others => '0');
        end if;

        red   <= out_col_s(7 downto 5);
        green <= out_col_s(4 downto 2);
        blue  <= out_col_s(1 downto 0);
    end process;

    sequential:
    process(hz_clk_s, reset)
    begin
        if reset = '1' then
            colour_s <= 0;
        elsif rising_edge(hz_clk_s) then
            colour_s <= next_colour_s;
        end if;
    end process;
end rtl;
