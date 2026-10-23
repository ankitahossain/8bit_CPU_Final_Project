-- alu.vhd
-- 8-bit combinational ALU for Set 0: LDI, ADD, AND, NOT.
-- Built from gates: XOR/AND/OR (adder), AND (bitwise AND), NOT,
-- NAND (result multiplexer) and NOR (zero detect).
library ieee;
use ieee.std_logic_1164.all;

entity alu is
    port (
        acc     : in  std_logic_vector(7 downto 0);  -- operand A
        operand : in  std_logic_vector(7 downto 0);  -- operand B (immediate)
        sel_ldi : in  std_logic;
        sel_add : in  std_logic;
        sel_and : in  std_logic;
        sel_not : in  std_logic;
        result  : out std_logic_vector(7 downto 0);
        zero    : out std_logic                       -- '1' when result = 0x00
    );
end entity alu;

architecture gates of alu is
    signal sum_v, and_v, not_v : std_logic_vector(7 downto 0);
    signal res                 : std_logic_vector(7 downto 0);
    signal unused_cout         : std_logic;
    signal z_lo, z_hi          : std_logic;
begin
    -- ADD: ripple-carry adder of XOR/AND/OR gates
    u_add : entity work.adder8
        port map (a => acc, b => operand, sum => sum_v, cout => unused_cout);

    -- AND and NOT, one gate per bit
    bit_logic : for i in 0 to 7 generate
        and_v(i) <= acc(i) and operand(i);
        not_v(i) <= not acc(i);
    end generate bit_logic;

    -- Result multiplexer in NAND-NAND form with one-hot selects:
    -- res = NAND( NAND(sel_ldi,imm), NAND(sel_add,sum),
    --             NAND(sel_and,and), NAND(sel_not,not) )
    mux : for i in 0 to 7 generate
        signal t0, t1, t2, t3 : std_logic;
    begin
        t0 <= sel_ldi nand operand(i);
        t1 <= sel_add nand sum_v(i);
        t2 <= sel_and nand and_v(i);
        t3 <= sel_not nand not_v(i);
        res(i) <= not (t0 and t1 and t2 and t3);
    end generate mux;

    result <= res;

    -- Zero detect: two 4-input NOR gates combined with an AND
    z_lo <= not (res(0) or res(1) or res(2) or res(3));
    z_hi <= not (res(4) or res(5) or res(6) or res(7));
    zero <= z_lo and z_hi;
end architecture gates;
