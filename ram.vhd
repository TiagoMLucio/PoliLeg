-------------------------------------------------------
--! @ram.vhd
--! @brief Descrição da RAM do PoliLeg
--! @author Tiago M Lucio (tiagolucio@usp.br)
--! @date 2022-06-12
-------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;
use std.textio.all;

entity ram is
    generic (
        addr_s: natural := 64; -- Size in bits
        word_s: natural := 32; -- Width in bits
        init_f: string := "rom.dat"
    );
    port (
        ck : in bit;
        rd, wr: in bit; -- enables (read and write)
        addr : in bit_vector(addr_s - 1 downto 0);
        data_i : in bit_vector(word_s - 1 downto 0);
        data_o : out bit_vector(word_s - 1 downto 0 )
    );
end ram;

architecture arch of ram is

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
      --! Memory matrix
      signal mem : mem_type := init_mem(init_f);
begin
    process(rd, ck)
    begin
        if (rd = '1') then
            data_o <= mem(to_integer(unsigned(addr)));
        end if;
        if (rising_edge(ck) and wr='1') then
            mem(to_integer(unsigned(addr))) <= data_i;
        end if;
    end process;
end arch ; -- arch