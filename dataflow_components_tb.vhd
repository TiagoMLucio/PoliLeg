-------------------------------------------------------
--! @dataflow_components_tb.vhd
--! @brief TestBench dos componentes do Data Flow do PoliLeg
--! @author Tiago M Lucio (tiagolucio@usp.br)
--! @date 2022-06-12
-------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;


entity dataflow_components_tb is
end dataflow_components_tb;

architecture tb of dataflow_components_tb is

    component shiftleft2 is
        generic(
            ws: natural := 64); -- word Size
        port (
            i: in bit_vector(ws - 1 downto 0); -- input
            o: out bit_vector(ws - 1 downto 0) --output
        );
    end component;

    signal i, o : bit_vector(7 downto 0);

begin
    dutA: shiftleft2 generic map(8) port map(i, o);

    -- Estímulos
    stim: process
    begin
        report "Shiftleft2 Tests";
        i <= "10000010";
        wait for 1 ns;
        assert o = "00001000" report "Shiftleft2 82";
        i <= "11111111";
        wait for 1 ns;
        assert o = "11111100" report "Shiftleft2 FF";
        i <= "00000000";
        wait for 1 ns;
        assert o = "00000000" report "Shiftleft2 00";
        i <= "01010011";
        wait for 1 ns;
        assert o = "01001100" report "Shiftleft2 53";
        report "End of Shiftleft2 Tests";

        wait;
    end process;
end architecture;
