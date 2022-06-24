-------------------------------------------------------
--! @datapath.vhd
--! @brief Descrição do Fluxo de Dados do PoliLeg
--! @author Tiago M Lucio (tiagolucio@usp.br)
--! @date 2022-06-23
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

    signal A_2, B_2, Add, Co_aux : bit;

begin

    A_2 <= A when Ainv = '0' else not A;
    B_2 <= B when Binv = '0' else not B;

    Add <= A_2 xor B_2 xor Ci;
    Co_aux <= ((A_2 and B_2) or ((A_2 or B_2) and Ci));

    with Op select
        F <= A_2 and B_2 when "00",
             A_2 or B_2 when "01",
             Add when "10",
             Less when "11";
    
    Set <= Add;
    Co <= Co_aux;
    Ov <= Ci xor Co_aux;

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

    alu1b_0: alu1b port map(A(0), B(0), Set(size - 1), S(2), Ainv, Binv, Op, O(0), Ci(1), Set(0), open);

    alus : for i in 1 to size - 2 generate    
        alu1b_i: alu1b port map(A(i), B(i), '0', Ci(i), Ainv, Binv, Op, O(i), Ci(i + 1), Set(i), open);
    end generate; -- alus

    alu1b_n: alu1b port map(A(size - 1), B(size - 1), '0', Ci(size - 1), Ainv, Binv, Op, O(size - 1), Co, Set(size - 1), Ov); 

    F <= O;
    Z <= '1' when unsigned(O) = 0 else '0';

end arch ; -- arch

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

library ieee;
use ieee.numeric_bit.all;
use ieee.math_real.all;

entity datapath is
    port (
        -- Common
        clock : in bit;
        reset : in bit;
        -- From Control Unit
        reg2loc : in bit;
        pcsrc : in bit;
        memToReg : in bit;
        aluCtrl : in bit_vector(3 downto 0);
        aluSrc : in bit;
        regWrite : in bit;
        -- To Control Unit
        opcode : out bit_vector(10 downto 0);
        zero : out bit;
        -- IM interface
        imAddr : out bit_vector(63 downto 0);
        imOut : in bit_vector(31 downto 0);
        -- DM interface
        dmAddr : out bit_vector(63 downto 0);
        dmIn : out bit_vector(63 downto 0);
        dmOut : in bit_vector(63 downto 0)
    );
end entity datapath;

architecture arch of datapath is

    component shiftleft2 is
        generic(
            ws: natural := 64); -- word Size
        port (
            i: in bit_vector(ws - 1 downto 0); -- input
            o: out bit_vector(ws - 1 downto 0) --output
        );
    end component;

    component signExtend is
        port (
            i: in bit_vector(31 downto 0); -- input
            o: out bit_vector(63 downto 0) --output
        );
    end component;

    component alu is
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
    end component;

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

    component regfile is
        generic (
            reg_n: natural := 32;
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
    end component;

    signal signE_o, shiftL_o, q1, q2, b_i, alu_o, pc_o, add4_o, add_o, pc_i, wr_i : bit_vector(63 downto 0);
    signal rr2_i : bit_vector(4 downto 0);

begin
    shiftL: shiftleft2 port map(signE_o, shiftL_o);
    signE: signExtend port map(imOut, signE_o);
    aluMain: alu port map(q1, b_i, alu_o, aluCtrl, zero, open, open);
    add4: alu port map(pc_o, bit_vector(to_signed(4, 64)), add4_o, "0010", open, open, open);
    add: alu port map(pc_o, shiftL_o, add_o, "0010", open, open, open);
    pc: d_register port map(clock, reset, '1', pc_i, pc_o);
    regF: regfile port map(clock, reset, regWrite, imOut(9 downto 5), rr2_i, ImOut(4 downto 0), wr_i, q1, q2);

    with pcsrc select
        pc_i <= add4_o when '0',
                add_o when others;

    with reg2loc select
        rr2_i <= imOut(20 downto 16) when '0',
                 imOut(4 downto 0) when others;
    
    with aluSrc select
        b_i <= q2 when '0',
               signE_o when others;

    with memToReg select
        wr_i <= dmOut when '1',
                alu_o when others;

    opcode <= ImOut(31 downto 21);
    imAddr <= pc_o;
    dmAddr <= alu_o;
    dmIn <= q2;

end arch ; -- arch


