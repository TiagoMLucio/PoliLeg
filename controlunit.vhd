-------------------------------------------------------
--! @controlunit.vhd
--! @brief Descrição da Unidade de Controle do PoliLeg
--! @author Tiago M Lucio (tiagolucio@usp.br)
--! @date 2022-06-23
-------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity controlunit is
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
end entity controlunit;

architecture arch of controlunit is

begin

    reg2loc <= '0' when opcode(7 downto 6) = "01" else '1';

    uncondBranch <= '1' when opcode(10) = '0' else '0';

    branch <= '1' when opcode(10 downto 5) = "101101" else '0';

    memRead <= '1';

    memToReg <= '1' when opcode = "11111000010" else '0';

    aluOp <= "00" when opcode(10 downto 6) = "11111" else
             "10" when opcode(7 downto 6) = "01" else 
             "01";
    
    memWrite <= '1' when opcode = "11111000000" else '0';

    aluSrc <= '1' when opcode(10 downto 6) = "11111" else '0';

    regWrite <= '1' when opcode(7 downto 6) = "01" or opcode = "11111000010" else '0';

end arch ; -- arch
