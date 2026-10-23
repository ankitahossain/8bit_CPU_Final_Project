-- tb_cpu.vhd
-- Self-checking testbench for Set 0 (LDI, ADD, AND, JZ, NOT).
-- Applies RESET for one rising edge, then runs one clock cycle per
-- executed instruction and compares ACC, Z and next PC with Appendix B.
library ieee;
use ieee.std_logic_1164.all;

entity tb_cpu is
end entity tb_cpu;

architecture sim of tb_cpu is
    constant T : time := 10 ns;

    signal clk   : std_logic := '0';
    signal reset : std_logic := '1';
    signal q     : std_logic_vector(7 downto 0);
    signal z     : std_logic;
    signal pc    : std_logic_vector(3 downto 0);

    type acc_arr is array (0 to 7) of std_logic_vector(7 downto 0);
    type z_arr   is array (0 to 7) of std_logic;
    type pc_arr  is array (0 to 7) of std_logic_vector(3 downto 0);

    -- Expected values AFTER each rising edge (cycle 0 = reset)
    constant EXP_ACC : acc_arr := (x"00", x"A5", x"00", x"00",
                                   x"FF", x"0F", x"0F", x"10");
    constant EXP_Z   : z_arr   := ('1', '0', '1', '1', '0', '0', '0', '0');
    constant EXP_PC  : pc_arr  := (x"0", x"1", x"2", x"5",
                                   x"6", x"7", x"8", x"9");

    signal done : boolean := false;
begin
    dut : entity work.cpu_top
        port map (clk => clk, reset => reset, q => q, z => z, pc => pc);

    -- Clock: stops after the last instruction so the simulation ends
    clk <= not clk after T / 2 when not done;

    stimulus : process
        variable errors : integer := 0;
    begin
        -- Cycle 0: RESET = 1 on the first rising edge
        wait until rising_edge(clk);
        wait for 1 ns;
        assert q = EXP_ACC(0) and z = EXP_Z(0) and pc = EXP_PC(0)
            report "Cycle 0 (RESET) mismatch" severity error;
        reset <= '0';

        -- Cycles 1..7: one executed instruction each
        for i in 1 to 7 loop
            wait until rising_edge(clk);
            wait for 1 ns;
            if q /= EXP_ACC(i) or z /= EXP_Z(i) or pc /= EXP_PC(i) then
                errors := errors + 1;
                report "Cycle " & integer'image(i) & " MISMATCH" severity error;
            else
                report "Cycle " & integer'image(i) & " OK" severity note;
            end if;
        end loop;

        if errors = 0 then
            report "PASS: all cycles match Appendix B (Set 0)." severity note;
        else
            report "FAIL: " & integer'image(errors) & " cycle(s) mismatched."
                severity error;
        end if;

        done <= true;
        wait;
    end process stimulus;
end architecture sim;
