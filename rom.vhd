-------------------------------------------------------
--! @rom.vhd
--! @brief Descrição da ROM do PoliLeg com o MDC
--! @author Tiago M Lucio (tiagolucio@usp.br)
--! @date 2022-06-23
-------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity rom is
    port (
        addr: in bit_vector(7 downto 0);
        data: out bit_vector(31 downto 0)
    );
end rom;

architecture arch of rom is
    type mem_t is array (0 to 255) of bit_vector(31  downto 0);
    constant mem : mem_t := (
        "11111000010000000000001111100011", -- LDUR
        "11111000010000001000001111100001", -- LDUR
        "11111000010000010000001111100010", -- LDUR
        "11001011000000100000000000100100", -- SUB
        "10110100000000000000000011100100", -- CBZ
        "10001010000000110000000010000101", -- AND
        "10110100000000000000000001100101", -- CBZ
        "11001011000000010000000001000010", -- SUB
        "00010111111111111111111111111011", -- B
        "11001011000000100000000000100001", -- SUB
        "00010111111111111111111111111001", -- B
        "11111000000000000000001111100001", --STUR
        "00010100000000000000000000000000", --B
        others => "00000000000000000000000000000000"
        );
begin
  data <= mem(to_integer(unsigned(addr)));
end arch;