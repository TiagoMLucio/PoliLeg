-------------------------------------------------------
--! @shiftleft2.vhd
--! @brief Descrição do Deslocador de 2 bits para a esquerda do PoliLeg
--! @author Tiago M Lucio (tiagolucio@usp.br)
--! @date 2022-06-12
-------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity shiftleft2 is
    generic(
        ws: natural := 64); -- word Size
    port (
        i: in bit_vector(ws - 1 downto 0); -- input
        o: out bit_vector(ws - 1 downto 0) --output
    );
end shiftleft2;

architecture arch of shiftleft2 is

begin

    o <= i(ws - 3 downto 0) & "00";

end arch ; -- arch
