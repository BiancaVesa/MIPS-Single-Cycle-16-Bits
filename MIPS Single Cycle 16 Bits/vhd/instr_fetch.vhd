----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/27/2020 12:54:21 PM
-- Design Name: 
-- Module Name: instr_fetch - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity instr_fetch is
  Port (clk : in std_logic;
  b_adr : in std_logic_vector(15 downto 0);
  en_cnt : in std_logic;
  en_res: in std_logic;
  jmp : in std_logic;
  pc_src : in std_logic;
  pc_out : out std_logic_vector (15 downto 0);
  instruction : out std_logic_vector(15 downto 0));
end instr_fetch;

architecture Behavioral of instr_fetch is

type ROM is array (0 to 255) of std_logic_vector(15 downto 0);

constant mem : ROM :=(
0 => b"001_000_001_0000000", --addi $1, $0, 0
1 => b"001_000_010_0000001", --addi $2, $0, 1
2 => b"001_000_111_0001001", --addi $7, $0, 9
3 => b"000_000_000_011_0_100", --and $3, $0, $0
4 => b"000_001_010_100_0_000", --add $4, $1, $1
5 => b"000_000_010_001_0_000", --add $1, $0, $2
6 => b"000_000_100_010_0_000", --add $2, $0, $4
7 => b"000_000_011_110_0_000", --add $6, $0, $3
8 => b"001_110_011_0000001", --addi $3, $6, 1
9 => b"100_111_011_0000001", --beq $3, $7, 1
10 => b"111_0000000000100", --j 4
11 => b"000_000_100_101_0_110", --xor $5, $0, $4
12 => b"001_000_110_0000100", --addi $6, $0, 4
13 => b"011_110_101_0000000", --sw $5, 0, $6
14 => b"001_000_010_0000000", --addi $4, $0, 0
15 => b"010_110_100_0000000", --lw $4, 0, $6 
16 => b"111_0000000000000", --j 0
others => x"0000");

signal pc : std_logic_vector(15 downto 0) := x"0000"; -- intrarea in PC
signal jump_val : std_logic_vector(15 downto 0) := x"0000"; --iesirea din al doilea mux
signal branch_val : std_logic_vector(15 downto 0) := x"0000"; --iesirea din primul mux
signal pc_val : std_logic_vector(15 downto 0) := x"0000"; --iesirea din PC
signal pc_aux : std_logic_vector(15 downto 0) := x"0000"; -- semnalul care intra in mux-uri
signal jump_adr : std_logic_vector(15 downto 0) := x"0000"; -- adresa de jump

begin

process (clk, en_cnt, en_res)
begin 
    if rising_edge(clk) then
        if en_cnt = '1' then
            pc_val <= pc;
        end if;
        if en_res = '1' then
            pc_val <= x"0000";
        end if;
    end if;
end process;

pc_aux <= pc_val + 1;

process(pc_src, b_adr, pc_aux)
begin
 if pc_src = '0' then
    branch_val <= pc_aux;
 else
    branch_val <= pc_aux + b_adr;
 end if;
end process;

jump_adr <= pc_aux(15 downto 13) & mem(conv_integer(pc_val))(12 downto 0);

process(jmp, branch_val, jump_adr)
begin
  if jmp = '0' then 
    jump_val <= branch_val;
  else jump_val <= jump_adr;
  end if;
end process;

pc <= jump_val;

instruction <= mem(conv_integer(pc_val));
pc_out <= pc_val;

end Behavioral;
