-------------------------------------------------------
--! @signExtend.vhd
--! @brief Descrição do Extensor de Sinal do PoliLeg
--! @author Tiago M Lucio (tiagolucio@usp.br)
--! @date 2022-06-12
-------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity signExtend is
    port (
        i: in bit_vector(31 downto 0); -- input
        o: out bit_vector(63 downto 0) --output
    );
end signExtend;

architecture arch of signExtend is

begin

    o <= bit_vector(resize(signed(i(25 downto 0)), o'length)) when i(31) = '0' else -- B
         bit_vector(resize(signed(i(23 downto 5)), o'length)) when i(30) = '0' else -- CB
         bit_vector(resize(signed(i(20 downto 12)), o'length));                   -- D

end arch ; -- arch
