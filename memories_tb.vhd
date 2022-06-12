-------------------------------------------------------
--! @rom_simples_tb.vhd
--! @brief TestBench das memórias do PoliLeg
--! @author Tiago M Lucio (tiagolucio@usp.br)
--! @date 2022-06-12
-------------------------------------------------------

library ieee;
use ieee.numeric_bit.all;

entity memories_tb is
end memories_tb;

architecture tb of memories_tb is
    component rom_simples is
        port (
            -- 4 bits de endereco:
            addr: in bit_vector(3 downto 0);
            -- 8 bits de tamanho de palavra de dados:
            data: out bit_vector(7 downto 0)
        );
    end component;

    component rom is
        generic (
            addr_s: natural := 64; -- Size in bits
            word_s: natural := 32; -- Width in bits
            init_f: string := "rom.dat"
        );
        port (
            addr: in bit_vector (addr_s - 1 downto 0);
            data: out bit_vector (word_s - 1 downto 0)
        );
    end component;

    -- sinais de suporte
    signal addr: bit_vector(3 downto 0);
    signal data1: bit_vector(7 downto 0);
    signal data2: bit_vector(31 downto 0);

    type mem_t1 is array (0 to 15) of bit_vector(7 downto 0);
    type mem_t2 is array (0 to 15) of bit_vector(31 downto 0);
    signal mem1 : mem_t1 := (
        "00000000", "00000011", "11000000", "00001100", 
        "00110000", "01010101", "10101010", "11111111",
        "11100000", "11100111", "00000111", "00011000", 
        "11000011", "00111100", "11110000", "00001111");
    signal mem2: mem_t2 := (
        "00000000000000000000000000000000",
        "00000000000000000000000000000001",
        "00000000000000000000000000000011",
        "00000000000000000000000000000111",
        "00000000000000000000000000001111",
        "00000000000000000000000000000000",
        "10000000000000000000000000000001",
        "11000000000000000000000000000001",
        "11100000000000000000000000000001",
        "11110000000000000000000000000001",
        "00000000000000000000000000000000",
        "11111110000000000000000000000001",
        "00000111000010000011100000000001",
        "00111111111111111111111111111001",
        "00000000000000000000000000000000",
        "11111111111111111111111111111111"
    );

begin
    dutA: rom_simples port map(addr, data1);
    dutB: rom generic map(4, 32, "rom.dat") port map(addr, data2);
    
    -- Estímulos
    stim: process
    begin
        for i in 0 to 15 loop
            addr <= bit_vector(to_unsigned(i, 4));
            wait for 1 ns;
            assert data1 = mem1(i)
            report "ROM_simples";
            assert data2 = mem2(i)
            report "ROM";
        end loop;
        report "End of tests";
        wait;
    end process;
end architecture;