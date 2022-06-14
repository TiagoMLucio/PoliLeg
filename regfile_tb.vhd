library ieee;
use IEEE.numeric_bit.all;
use IEEE.math_real.all;

entity regfile_tb is end entity;


architecture arch of regfile_tb is
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

    signal clk, rst, regWr, simulation: bit;
    signal rr1i, rr2i, wri: bit_vector(natural (ceil(log2(real(32)))) - 1 downto 0);
    signal data, q1o, q2o: bit_vector (63 downto 0);
    constant period: time := 5 ns;
    
begin
    dut: regfile port map (clk, rst, regWr, rr1i, rr2i, wri, data, q1o, q2o);
    clk <= (simulation and (not clk)) after period/2;

    process
        begin
            report "BOT";
            simulation <= '1';
            data <= ('1', '0', '1', '0', '1', others=> '0');
            wri <= "01010";
            regWr <= '1';
            wait until rising_edge(clk);
            wait for period/2;
            data <= ('1', '0', '1', '1', '0', others=> '1');
            wri <= "01011";
            regWr <= '1';
            wait until rising_edge(clk);
            wait for period/2;
            data <= ('1', '0', '1', '1', '1', '0', others=> '0');
            wri <= "11011";
            regWr <= '1';
            wait for period/2;
            data <= ('1', '1', '1', '1', '0', '1', others=> '0');
            wri <= "01111";
            regWr <= '1';
            wait until rising_edge(clk);
            regWr <= '0';
            rr1i <= "01010";
            rr2i <= "01011";
            wait for period/10;
            assert q1o = "1010100000000000000000000000000000000000000000000000000000000000" report "Teste 1 falhou no caso 1";
            assert q2o = "1011011111111111111111111111111111111111111111111111111111111111" report "Teste 1 falhou no caso 2";
            wait for period/2;
            rr1i <= "11011";
            rr2i <= "01111";
            wait for period/10;
            assert q1o = "1011100000000000000000000000000000000000000000000000000000000000" report "Teste 2 falhou no caso 1";
            assert q2o = "1111010000000000000000000000000000000000000000000000000000000000" report "Teste 2 falhou no caso 1";
            simulation <= '0';
            report "EOT";
        wait;
        end process;
end architecture arch;