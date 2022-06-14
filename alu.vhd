-------------------------------------------------------
--! @alu.vhd
--! @brief Descrição da Alu do PoliLeg
--! @author Tiago M Lucio (tiagolucio@usp.br)
--! @date 2022-06-12
-------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity alu is
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
end entity alu;

architecture arch of alu is

    signal O, Slt: bit_vector(size - 1 downto 0);
    signal Add, Sub: bit_vector(size downto 0);

begin

    Slt <= (0 => '1', others => '0') when signed(A) < signed(B) else
           (others => '0');

    Add <= bit_vector(signed('0' & A) + signed('0' & B));
    Sub <= bit_vector(signed('0' & A) + signed('0' & bit_vector(signed(not B) + 1)));

    with S select
        O <= A and B when "0000",
             A or B when "0001",
             Add(size - 1 downto 0) when "0010",
             Sub(size - 1 downto 0) when "0110",
             Slt when "0111",
             A nor B when "1100",
             (others => '0') when others;

    Z <= '1' when unsigned(O) = 0 else
         '0';
    
    Co <= Add(size) when S = "0010" else
          Sub(size);

    Ov <= '1' when 
                (S = "0010" and ((A(size - 1) = B(size - 1)) and (A(size - 1) /= O(size - 1)))) or 
                (S = "0110" and  ((A(size - 1) /= B(size - 1)) and (A(size - 1) /= O(size - 1)))) else
          '0';

    F <= O;

end arch ; -- arch
