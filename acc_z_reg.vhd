-- acc_z_reg.vhd
-- Accumulator (8-bit) and Z flag (1-bit). Set 0 has no STA/LDR, so the
-- holding register R is not needed.
-- Synchronous, active-high RESET: ACC <= 0x00, Z <= 1.
library ieee;
use ieee.std_logic_1164.all;

entity acc_z_reg is
    port (
        clk    : in  std_logic;
        reset  : in  std_logic;
        acc_we : in  std_logic;
        z_we   : in  std_logic;
        d_acc  : in  std_logic_vector(7 downto 0);   -- ALU result
        d_z    : in  std_logic;                      -- ALU zero flag
        acc    : out std_logic_vector(7 downto 0);
        z      : out std_logic
    );
end entity acc_z_reg;

architecture rtl of acc_z_reg is
    signal acc_r : std_logic_vector(7 downto 0) := (others => '0');
    signal z_r   : std_logic := '1';
begin
    process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                acc_r <= (others => '0');
                z_r   <= '1';
            else
                if acc_we = '1' then
                    acc_r <= d_acc;
                end if;
                if z_we = '1' then
                    z_r <= d_z;
                end if;
            end if;
        end if;
    end process;

    acc <= acc_r;
    z   <= z_r;
end architecture rtl;
