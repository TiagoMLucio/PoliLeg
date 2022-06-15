-------------------------------------------------------
--! @rom_simples.vhd
--! @brief Descrição da ROM do PoliLeg
--! @author Tiago M Lucio (tiagolucio@usp.br)
--! @date 2022-06-12
-------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;
use std.textio.all;

entity rom is
    generic (
        addr_s: natural := 64; -- Size in bits
        word_s: natural := 32; -- Width in bits
        init_f: string := "rom.dat"
    );
    port (
        addr: in bit_vector (addr_s - 1 downto 0);
        data: out bit_vector (word_s - 1 downto 0)
    );
end rom;

architecture arch of rom is
    constant depth : natural := 2 ** addr_s;
    type mem_type is array (0 to depth-1) of bit_vector(word_s-1 downto 0);

    impure function init_mem(file_name : in string) return mem_type is
        file     f       : text open read_mode is file_name;
        variable l       : line;
        variable tmp_bv  : bit_vector(word_s-1 downto 0);
        variable tmp_mem : mem_type;
      begin
        for i in mem_type'range loop
          readline(f, l);
          read(l, tmp_bv);
          tmp_mem(i) := tmp_bv;
        end loop;
        return tmp_mem;
      end;

      signal mem : mem_type := init_mem(init_f);
begin
    
    data <= mem(to_integer(unsigned(addr)));

end arch ; -- arch
