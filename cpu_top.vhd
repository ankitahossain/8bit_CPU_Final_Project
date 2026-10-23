-- cpu_top.vhd
-- Mini 8-bit accumulator CPU, Set 0: LDI, ADD, AND, JZ, NOT.
-- Single cycle: fetch, decode and execute in one rising clock edge.
library ieee;
use ieee.std_logic_1164.all;

entity cpu_top is
    port (
        clk   : in  std_logic;
        reset : in  std_logic;
        q     : out std_logic_vector(7 downto 0);   -- ACC
        z     : out std_logic;                      -- Z flag
        pc    : out std_logic_vector(3 downto 0)    -- PC (for checking)
    );
end entity cpu_top;

architecture structural of cpu_top is
    signal pc_s      : std_logic_vector(3 downto 0) := (others => '0');
    signal instr     : std_logic_vector(11 downto 0);
    signal opcode    : std_logic_vector(3 downto 0);
    signal operand   : std_logic_vector(7 downto 0);
    signal acc_s     : std_logic_vector(7 downto 0);
    signal z_s       : std_logic;
    signal alu_res   : std_logic_vector(7 downto 0);
    signal alu_zero  : std_logic;
    signal sel_ldi, sel_add, sel_and, sel_not : std_logic;
    signal acc_we, z_we, is_jz : std_logic;
begin
    opcode  <= instr(11 downto 8);
    operand <= instr(7 downto 0);

    u_pc : entity work.pc
        port map (clk => clk, reset => reset, is_jz => is_jz, z_flag => z_s,
                  target => operand(3 downto 0), pc_out => pc_s);

    u_rom : entity work.program_rom
        port map (addr => pc_s, instr => instr);

    u_ctrl : entity work.control_unit
        port map (opcode => opcode,
                  sel_ldi => sel_ldi, sel_add => sel_add,
                  sel_and => sel_and, sel_not => sel_not,
                  acc_we => acc_we, z_we => z_we, is_jz => is_jz);

    u_alu : entity work.alu
        port map (acc => acc_s, operand => operand,
                  sel_ldi => sel_ldi, sel_add => sel_add,
                  sel_and => sel_and, sel_not => sel_not,
                  result => alu_res, zero => alu_zero);

    u_regs : entity work.acc_z_reg
        port map (clk => clk, reset => reset,
                  acc_we => acc_we, z_we => z_we,
                  d_acc => alu_res, d_z => alu_zero,
                  acc => acc_s, z => z_s);

    q  <= acc_s;
    z  <= z_s;
    pc <= pc_s;
end architecture structural;
