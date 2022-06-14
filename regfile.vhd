-------------------------------------------------------
--! @regfile.vhd
--! @brief Descrição do RegFile do PoliLeg
--! @author Tiago M Lucio (tiagolucio@usp.br)
--! @date 2022-06-12
-------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity d_register is
    generic (
        width       : natural := 64;
        reset_value : natural := 0
    );
    port (
        clock, reset, load  : in bit;
        d                       : in bit_vector(width - 1 downto 0);
        q                       : out bit_vector(width - 1 downto 0)
    );
end entity d_register;


architecture arch of d_register is

begin
    procD: process(clock, reset, load)
    begin 
        if (reset = '1') then q <= bit_vector(to_unsigned(reset_value, width));   -- assíncrono
        elsif (load = '1' and rising_edge(clock)) then q <= d;                    -- borda de subida do clock
        end if;
    end process procD;    

end arch ; -- arch

library ieee;
use ieee.numeric_bit.all;
use ieee.math_real.all;

entity regfile is
    generic (
        reg_n: natural := 10;
        word_s: natural := 64
    );
    port (
        clock: in bit;
        reset: in bit;
        regWrite: in bit;
        rr1, rr2, wr: in bit_vector(natural(ceil(log2(real(reg_n)))) - 1 downto 0);
        d: in bit_vector(word_s - 1 downto 0);
        q1, q2: out bit_vector(word_s - 1 downto 0)
    );
end entity regfile;

architecture arch of regfile is

    component d_register is
        generic (
            width       : natural := 64;
            reset_value : natural := 0
        );
        port (
            clock, reset, load  : in bit;
            d                       : in bit_vector(width - 1 downto 0);
            q                       : out bit_vector(width - 1 downto 0)
        );
    end component;

    type BitVectorArray is array (natural range <>) of bit_vector(word_s - 1 downto 0);

    signal load: bit_vector(reg_n - 1 downto 0);
    signal q: BitVectorArray(0 to reg_n);

begin

    regs : for i in 0 to reg_n-2 generate
            load(i) <= '1' when (i = unsigned(wr)) and regWrite = '1' else
                       '0';
            reg_i: d_register generic map (word_s) port map(clock, reset, load(i), d, q(i));
    end generate ; -- regs

    q(reg_n-1) <= (others => '0');
    q1 <= q(to_integer(unsigned(rr1)));
    q2 <= q(to_integer(unsigned(rr2))); 
    

end arch ; -- arch
