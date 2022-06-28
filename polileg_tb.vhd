library ieee;
use ieee.numeric_bit.all;

entity polileg_tb is
end entity;

architecture test of polileg_tb is

    component polileg is
        port (          
            clock, reset : in bit
        );
    end component;

    signal clk, reset : bit;
    constant period: time := 1 ns;

begin
    dut: polileg port map(clk, reset);
    clk <= (not clk) after period/2;

    process begin
        report "BOT";
        reset <= '1';   
        wait for 1 ns;
        reset <= '0';
        wait for 50 ns;
        report "EOF";
        wait;
    end process;

end architecture;