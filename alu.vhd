-------------------------------------------------------
--! @alu.vhd
--! @brief Descrição da Alu do PoliLeg
--! @author Tiago M Lucio (tiagolucio@usp.br)
--! @date 2022-06-12
-------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity alu1b is
    port (
        A, B, Less, Ci, Ainv, Binv : in bit;
        Op : in bit_vector(1 downto 0); 
        F, Co, Set, Ov : out bit
    );
end entity alu1b;

architecture arch of alu1b is

    signal A_2, B_2, Add : bit;

begin

    A_2 <= A when Ainv = '0' else not A;
    B_2 <= B when Binv = '0' else not B;

    Add <= A_2 xor B_2 xor Ci;
    Co <= (A_2 and B_2) or (A_2 and Ci) or (B_2 and Ci);

    with Op select
        F <= A_2 and B_2 when "00",
             A_2 or B_2 when "01",
             Add when "10",
             Less when "11";
    
    Set <= Add;

    Ov <= '1' when 
                ((Ainv = Binv) and (A = B and A /= Add)) or 
                ((Ainv /= Binv) and  (A /= B and A /= Add)) else
          '0';

end arch ; -- arch

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

    component alu1b is
        port (
            A, B, Less, Ci, Ainv, Binv : in bit;
            Op : in bit_vector(1 downto 0); 
            F, Co, Set, Ov : out bit
        );
    end component;

    signal O, Ci, Set : bit_vector(size - 1 downto 0);
    signal Op : bit_vector (1 downto 0);
    signal Ainv, Binv : bit;

begin

    Op <= S(1 downto 0);
    Ainv <= S(3);
    Binv <= S(2);
    Ci(0) <= S(2);

    alu1b_0: alu1b port map(A(0), B(0), Set(size - 1), Ci(0), Ainv, Binv, Op, O(0), Ci(1), Set(0), open);

    alus : for i in 1 to size - 2 generate    
        alu1b_i: alu1b port map(A(i), B(i), '0', Ci(i), Ainv, Binv, Op, O(i), Ci(i + 1), Set(i), open);
    end generate ; -- alus

    alu1b_n: alu1b port map(A(size - 1), B(size - 1), '0', Ci(size - 1), Ainv, Binv, Op, O(size - 1), Co, Set(size - 1), Ov); 

    F <= O;
    Z <= '1' when unsigned(O) = 0 else '0';

end arch ; -- arch
