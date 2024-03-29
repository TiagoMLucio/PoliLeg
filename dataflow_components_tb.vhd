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

    component signExtend is
        port (
            i: in bit_vector(31 downto 0); -- input
            o: out bit_vector(63 downto 0) --output
        );
    end component;

    component alu is
        generic (
            size : natural := 64
        );
        port (
            A, B : in bit_vector(size - 1 downto 0); -- inputs
            F    : out bit_vector(size - 1 downto 0); -- output
            S    : in bit_vector(3 downto 0); -- op selection
            Z    : out bit; -- zero flag
            Ov   : out bit; -- overflow flag
            Co   : out bit -- carry out
        );
    end component;

    signal i1, o1 : bit_vector(7 downto 0);
    signal i2 : bit_vector(31 downto 0);
    signal o2: bit_vector(63 downto 0);

begin
    dutA: shiftleft2 generic map(8) port map(i1, o1);
    dutB: signExtend port map(i2, o2);

    -- Estímulos
    stim: process 
    begin
        assert false report "Shiftleft2 Tests" severity note;

        i1 <= "10000010";
        wait for 1 ns;
        assert o1 = "00001000" report "Shiftleft2 82" severity error;

        i1 <= "11111111";
        wait for 1 ns;
        assert o1 = "11111100" report "Shiftleft2 FF" severity error;

        i1 <= "00000000";
        wait for 1 ns;
        assert o1 = "00000000" report "Shiftleft2 00" severity error;

        i1 <= "01010011";
        wait for 1 ns;
        assert o1 = "01001100" report "Shiftleft2 53" severity error;

        assert false report "End of Shiftleft2 Tests" severity note;

        assert false report "SignExtend Tests" severity note;

        i2 <= "00010100010100000000000000011111";
        wait for 1 ns;
        assert o2 = "0000000000000000000000000000000000000000010100000000000000011111" 
        report "SignExtend B +" severity error;

        i2 <= "00010111100000000000001111110000";
        wait for 1 ns;
        assert o2 = "1111111111111111111111111111111111111111100000000000001111110000" 
        report "SignExtend B -" severity error;

        i2 <= "10110100000000000000000010100001";
        wait for 1 ns;
        assert o2 = "0000000000000000000000000000000000000000000000000000000000000101" 
        report "SignExtend CB +" severity error;

        i2 <= "10110100100000111111111111111111";
        wait for 1 ns;
        assert o2 = "1111111111111111111111111111111111111111111111000001111111111111" 
        report "SignExtend CB -" severity error;

        i2 <= "11111000010011111111001111000001";
        wait for 1 ns;
        assert o2 = "0000000000000000000000000000000000000000000000000000000011111111" 
        report "SignExtend D +" severity error;

        i2 <= "11111000000101010101001000001100";
        wait for 1 ns;
        assert o2 = "1111111111111111111111111111111111111111111111111111111101010101" 
        report "SignExtend D -" severity error;

        assert false report "End of SignExtend Tests" severity note;

        wait;
    end process;
end architecture;
