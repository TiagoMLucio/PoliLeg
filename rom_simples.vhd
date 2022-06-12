-------------------------------------------------------
--! @rom_simples.vhd
--! @brief Descrição da ROM_simples do PoliLeg
--! @author Tiago M Lucio (tiagolucio@usp.br)
--! @date 2022-06-12
-------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity rom_simples is
    port (
        -- 4 bits de endereco:
        addr: in bit_vector(3 downto 0);
        -- 8 bits de tamanho de palavra de dados:
        data: out bit_vector(7 downto 0)
    );
end rom_simples;

architecture arch of rom_simples is
    type mem_t is array (0 to 15) of bit_vector(7  downto 0);
    signal mem : mem_t := (
        "00000000", "00000011", "11000000", "00001100", 
        "00110000", "01010101", "10101010", "11111111",
        "11100000", "11100111", "00000111", "00011000", 
        "11000011", "00111100", "11110000", "00001111");
begin
  data <= mem(to_integer(unsigned(addr)));
end arch;