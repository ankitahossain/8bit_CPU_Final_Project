-- gates.vhd
-- Gate-level building blocks used by the ALU and the PC.
-- Only AND, OR, NOT, NAND, NOR and XOR operators are used.
library ieee;
use ieee.std_logic_1164.all;

------------------------------------------------------------
-- 1-bit full adder: XOR for the sum, AND/OR for the carry
------------------------------------------------------------
entity full_adder is
    port (
        a, b, cin : in  std_logic;
        s, cout   : out std_logic
    );
end entity full_adder;

architecture gates of full_adder is
    signal p : std_logic;  -- propagate
begin
    p    <= a xor b;
    s    <= p xor cin;
    cout <= (a and b) or (p and cin);
end architecture gates;

------------------------------------------------------------
-- 8-bit ripple-carry adder (carry out discarded by the ALU)
------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity adder8 is
    port (
        a, b : in  std_logic_vector(7 downto 0);
        sum  : out std_logic_vector(7 downto 0);
        cout : out std_logic
    );
end entity adder8;

architecture gates of adder8 is
    signal c : std_logic_vector(8 downto 0);
begin
    c(0) <= '0';
    gen : for i in 0 to 7 generate
        fa : entity work.full_adder
            port map (a => a(i), b => b(i), cin => c(i),
                      s => sum(i), cout => c(i + 1));
    end generate gen;
    cout <= c(8);
end architecture gates;

------------------------------------------------------------
-- 4-bit incrementer (PC + 1) built from half-adder logic
------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity inc4 is
    port (
        a : in  std_logic_vector(3 downto 0);
        y : out std_logic_vector(3 downto 0)
    );
end entity inc4;

architecture gates of inc4 is
begin
    y(0) <= not a(0);
    y(1) <= a(1) xor a(0);
    y(2) <= a(2) xor (a(1) and a(0));
    y(3) <= a(3) xor (a(2) and a(1) and a(0));
end architecture gates;
