-- pc.vhd
-- 4-bit program counter. Every cycle PC <= PC + 1, except when a JZ is
-- taken (jz = '1' and Z = '1'), in which case PC <= target.
-- Synchronous, active-high RESET (PC <= 0).
library ieee;
use ieee.std_logic_1164.all;

entity pc is
    port (
        clk    : in  std_logic;
        reset  : in  std_logic;
        is_jz  : in  std_logic;
        z_flag : in  std_logic;
        target : in  std_logic_vector(3 downto 0);   -- operand[3:0]
        pc_out : out std_logic_vector(3 downto 0)
    );
end entity pc;

architecture rtl of pc is
    signal pc_reg   : std_logic_vector(3 downto 0) := (others => '0');
    signal pc_inc   : std_logic_vector(3 downto 0);
    signal pc_next  : std_logic_vector(3 downto 0);
    signal take, ntake : std_logic;
begin
    u_inc : entity work.inc4 port map (a => pc_reg, y => pc_inc);

    take  <= is_jz and z_flag;
    ntake <= not take;

    -- 2:1 mux from AND/OR/NOT gates
    sel : for i in 0 to 3 generate
        pc_next(i) <= (take and target(i)) or (ntake and pc_inc(i));
    end generate sel;

    process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                pc_reg <= (others => '0');
            else
                pc_reg <= pc_next;
            end if;
        end if;
    end process;

    pc_out <= pc_reg;
end architecture rtl;
