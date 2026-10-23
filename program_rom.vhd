-- program_rom.vhd
-- 16 x 12-bit program ROM (constant array), read combinationally.
-- Contains the Appendix B program for Set 0. Unused locations = 0x000 (NOP).
--   0: LDI 0xA5   1: AND 0x5A   2: JZ 0x05   3: ADD 0x01   4: ADD 0x01
--   5: NOT        6: AND 0x0F   7: JZ 0x00   8: ADD 0x01
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity program_rom is
    port (
        addr  : in  std_logic_vector(3 downto 0);
        instr : out std_logic_vector(11 downto 0)
    );
end entity program_rom;

architecture rtl of program_rom is
    type rom_t is array (0 to 15) of std_logic_vector(11 downto 0);
    constant ROM : rom_t := (
        0      => x"1A5",   -- LDI 0xA5
        1      => x"45A",   -- AND 0x5A
        2      => x"C05",   -- JZ  0x05
        3      => x"201",   -- ADD 0x01
        4      => x"201",   -- ADD 0x01
        5      => x"700",   -- NOT
        6      => x"40F",   -- AND 0x0F
        7      => x"C00",   -- JZ  0x00
        8      => x"201",   -- ADD 0x01
        others => x"000"    -- NOP
    );
begin
    instr <= ROM(to_integer(unsigned(addr)));
end architecture rtl;
