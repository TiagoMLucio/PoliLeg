-------------------------------------------------------
--! @dataflow_components_tb.vhd
--! @brief TestBench dos componentes do Data Flow do PoliLeg
--! @author Tiago M Lucio (tiagolucio@usp.br)
--! @date 2022-06-12
-------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;


entity controlunit_tb is
end controlunit_tb;

architecture tb of controlunit_tb is

    component controlunit is
        port (
            -- To Datapath
            reg2loc: out bit;
            uncondBranch: out bit;
            branch: out bit;
            memRead: out bit;
            memToReg: out bit;
            aluOp: out bit_vector(1 downto 0);
            memWrite: out bit;
            aluSrc: out bit;
            regWrite: out bit;
            -- From Datapath
            opcode: in bit_vector(10 downto 0)
        );
    end component;

    signal reg2loc, uncondBranch, branch, memRead, memToReg, memWrite, aluSrc, regWrite : bit;
    signal aluOp : bit_vector(1 downto 0);
    signal opcode : bit_vector(10 downto 0);

begin
    dutA: controlunit port map(reg2loc, uncondBranch, branch, memRead, memToReg, aluOp, memWrite, aluSrc, regWrite, opcode);

    -- Estímulos
    stim: process 
    begin
        assert false report "ControlUnit Tests" severity note;

        opcode <= "00010100000"; -- B
        wait for 1 ns;
        assert uncondBranch = '1' report "B - uncondBranch" severity error;
        assert regWrite = '0' report "B - regWrite" severity error;
        assert memWrite = '0' report "B - memWrite" severity error;

        opcode <= "10001011000"; -- ADD
        wait for 1 ns;
        assert reg2loc = '0' report "ADD - reg2loc" severity error;
        assert uncondBranch = '0' report "ADD - uncondBranch" severity error;
        assert branch = '0' report "ADD - branch" severity error;
        assert memRead = '1' report "ADD - memRead" severity error;
        assert memToReg = '0' report "ADD - memToReg" severity error;
        assert aluOp = "10" report "ADD - aluOp" severity error;
        assert memWrite = '0' report "ADD - memWrite" severity error;
        assert aluSrc = '0' report "ADD - aluSrc" severity error;
        assert regWrite = '1' report "ADD - regWrite" severity error;

        opcode <= "11111000010"; -- LDUR
        wait for 1 ns;
        assert uncondBranch = '0' report "LDUR - uncondBranch" severity error;
        assert branch = '0' report "LDUR - branch" severity error;
        assert memRead = '1' report "LDUR - memRead" severity error;
        assert memToReg = '1' report "LDUR - memToReg" severity error;
        assert aluOp = "00" report "LDUR - aluOp" severity error;
        assert memWrite = '0' report "LDUR - memWrite" severity error;
        assert aluSrc = '1' report "LDUR - aluSrc" severity error;
        assert regWrite = '1' report "LDUR - regWrite" severity error;

        opcode <= "11111000000"; -- STUR
        wait for 1 ns;
        assert reg2loc = '1' report "STUR - reg2loc" severity error;
        assert uncondBranch = '0' report "STUR - uncondBranch" severity error;
        assert branch = '0' report "STUR - branch" severity error;
        assert memRead = '1' report "STUR - memRead" severity error;
        assert aluOp = "00" report "STUR - aluOp" severity error;
        assert memWrite = '1' report "STUR - memWrite" severity error;
        assert aluSrc = '1' report "STUR - aluSrc" severity error;
        assert regWrite = '0' report "STUR - regWrite" severity error;

        opcode <= "10110100000"; -- CBZ
        wait for 1 ns;
        assert reg2loc = '1' report "CBZ - reg2loc" severity error;
        assert uncondBranch = '0' report "CBZ - uncondBranch" severity error;
        assert branch = '1' report "CBZ - branch" severity error;
        assert memRead = '1' report "CBZ - memRead" severity error;
        assert aluOp = "01" report "CBZ - aluOp" severity error;
        assert memWrite = '0' report "CBZ - memWrite" severity error;
        assert aluSrc = '0' report "CBZ - aluSrc" severity error;
        assert regWrite = '0' report "CBZ - regWrite" severity error;


        assert false report "End of ControlUnit Tests" severity note;

        wait;
    end process;
end architecture;
