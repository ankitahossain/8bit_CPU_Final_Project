-- control_unit.vhd
-- Decodes opcode[3:0] for Set 0 (LDI, ADD, AND, NOT, JZ) using gates.
-- Any other opcode (including 0000) decodes to NOP: no select, no write.
--   LDI 0001   ADD 0010   AND 0100   NOT 0111   JZ 1100
library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
    port (
        opcode  : in  std_logic_vector(3 downto 0);
        sel_ldi : out std_logic;
        sel_add : out std_logic;
        sel_and : out std_logic;
        sel_not : out std_logic;
        acc_we  : out std_logic;   -- write ACC
        z_we    : out std_logic;   -- update Z flag
        is_jz   : out std_logic
    );
end entity control_unit;

architecture gates of control_unit is
    signal o3, o2, o1, o0 : std_logic;       -- opcode bits
    signal n3, n2, n1, n0 : std_logic;       -- inverted bits
    signal ldi, add, andi, nt : std_logic;
begin
    o3 <= opcode(3); o2 <= opcode(2); o1 <= opcode(1); o0 <= opcode(0);
    n3 <= not o3;    n2 <= not o2;    n1 <= not o1;    n0 <= not o0;

    ldi  <= n3 and n2 and n1 and o0;   -- 0001
    add  <= n3 and n2 and o1 and n0;   -- 0010
    andi <= n3 and o2 and n1 and n0;   -- 0100
    nt   <= n3 and o2 and o1 and o0;   -- 0111
    is_jz <= o3 and o2 and n1 and n0;  -- 1100

    sel_ldi <= ldi;
    sel_add <= add;
    sel_and <= andi;
    sel_not <= nt;

    -- ACC and Z are written by every ALU instruction (not by JZ / NOP)
    acc_we <= ldi or add or andi or nt;
    z_we   <= ldi or add or andi or nt;
end architecture gates;
