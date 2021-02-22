----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/03/2020 01:40:31 PM
-- Design Name: 
-- Module Name: instr_decode - Behavioral
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

entity instr_decode is
  Port ( instr : in std_logic_vector(15 downto 0);
  wd : in std_logic_vector(15 downto 0);
  regWr : in std_logic;
  regDst : in std_logic;
  extOp : in std_logic;
  clk : in std_logic;
  rd1 : out std_logic_vector(15 downto 0);
  rd2 : out std_logic_vector(15 downto 0);
  extImm : out std_logic_vector(15 downto 0);
  func : out std_logic_vector(2 downto 0);
  sa : out std_logic);
  end instr_decode;

architecture Behavioral of instr_decode is

component reg_file is
  Port (
  ra1 : in std_logic_vector(2 downto 0);
  ra2 : in std_logic_vector(2 downto 0);
  wa : in std_logic_vector(2 downto 0);
  wd : in std_logic_vector(15 downto 0);
  clk : in std_logic;
  wr_en : in std_logic;
  rd1 : out std_logic_vector(15 downto 0);
  rd2 : out std_logic_vector(15 downto 0));
end component;

signal rs : std_logic_vector(2 downto 0):="000";
signal rt : std_logic_vector(2 downto 0):="000";
signal rdest : std_logic_vector(2 downto 0):="000";
signal wa : std_logic_vector(2 downto 0);
signal imm : std_logic_vector(6 downto 0);

begin

rs <= instr(12 downto 10);
rt <= instr(9 downto 7);
rdest <= instr(6 downto 4);
imm <= instr(6 downto 0);
 
process(regDst)
begin
    if regDst = '0' then
       wa <= rt;
    else wa <= rdest;
    end if;
end process;

RF: reg_file port map(rs, rt, wa, wd, clk, regWr, rd1, rd2);

process (extOp)
begin
    if extOp = '0' then
        extImm <= "000000000" & imm;
    elsif imm(6) = '0' then
        extImm <= "000000000" & imm;
        else extImm <= "111111111" & imm;
    end if;  
end process;

func <= imm(2 downto 0);
sa <= imm(3);


end Behavioral;
