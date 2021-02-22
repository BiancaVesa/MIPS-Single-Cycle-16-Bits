----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/28/2020 12:17:00 PM
-- Design Name: 
-- Module Name: test_env - Behavioral
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

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is

component mpg is
    Port ( en : out STD_LOGIC;
           btn : in STD_LOGIC;
           clk : in STD_LOGIC);
end component;

component SSD is
  Port (digit0 : in STD_LOGIC_VECTOR(3 downto 0);
  digit1 : in STD_LOGIC_VECTOR(3 downto 0);
  digit2 : in STD_LOGIC_VECTOR(3 downto 0);
  digit3 : in STD_LOGIC_VECTOR(3 downto 0);
  clk : in STD_LOGIC;
  LED : out std_logic_vector(6 downto 0);
  O2 : out std_logic_vector(3 downto 0));
end component;

component instr_fetch is
  Port (clk : in std_logic;
  b_adr : in std_logic_vector(15 downto 0);
  en_cnt : in std_logic;
  en_res: in std_logic;
  jmp : in std_logic;
  pc_src : in std_logic;
  pc_out : out std_logic_vector (15 downto 0);
  instruction : out std_logic_vector(15 downto 0));
end component;

component instr_decode is
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
end component;

component ex_unit is
  Port (
  rd1 : in std_logic_vector(15 downto 0);
  aluSrc : in std_logic;
  rd2 : in std_logic_vector(15 downto 0); 
  ext_imm : in std_logic_vector(15 downto 0); 
  sa : in std_logic;
  func : in std_logic_vector(2 downto 0);
  aluOp : in std_logic_vector(2 downto 0);
  zero : out std_logic;
  aluRes : out std_logic_vector(15 downto 0));
end component;

component mem is
  Port (memWr: in std_logic;
  aluResIn: in std_logic_vector (15 downto 0);
  rd2: in std_logic_vector(15 downto 0);
  memData: out std_logic_vector(15 downto 0);
  aluResOut: out std_logic_vector(15 downto 0));
end component;

--semnale pt IF
signal cnt : std_logic_vector(15 downto 0) := x"0000";
signal pc : std_logic_vector(15 downto 0) := x"0000";
signal pcSrc : std_logic;
signal instr : std_logic_vector(15 downto 0) := x"0000";
signal DO : std_logic_vector(15 downto 0) := x"0000";
signal en1 :std_logic ;
signal en2 :std_logic ;
signal j_adr: std_logic_vector(15 downto 0) := x"0000";
signal b_adr: std_logic_vector(15 downto 0) := x"0000";

--semnale pt UC
signal regDst : std_logic;
signal extOp : std_logic;
signal aluSrc : std_logic;
signal branch : std_logic;
signal jump : std_logic;
signal aluOp : std_logic_vector(2 downto 0);
signal memWr : std_logic;
signal memToReg : std_logic;
signal regWr : std_logic;

--semnale pt ID
signal rd1 : std_logic_vector(15 downto 0) := x"0000";
signal rd2 : std_logic_vector(15 downto 0) := x"0000";
signal wd : std_logic_vector(15 downto 0) := x"0000";
signal extImm : std_logic_vector(15 downto 0) := x"0000";
signal func : std_logic_vector(2 downto 0);
signal sa : std_logic;

--semnale pt EX
signal zero : std_logic;
signal aluRes : std_logic_vector(15 downto 0);

--semnale pt MEM
signal enMemWr : std_logic;
signal memData : std_logic_vector(15 downto 0);

begin

MPG_1 : mpg port map(en1, btn(0), clk);
MPG_2 : mpg port map(en2, btn(1), clk);

I_F : instr_fetch port map(clk, extImm, en1, en2, jump, pcSrc, pc, instr);

--UC
process(instr)
begin
    case (instr(15 downto 13)) is
    when "000" => regDst<='1'; extOp<='0'; aluSrc<='0'; branch<='0'; jump<='0'; aluOp<="000"; memWr<='0'; memToReg<='0'; regWr<='1'; --tip R
    when "001" => regDst<='0'; extOp<='1'; aluSrc<='1'; branch<='0'; jump<='0'; aluOp<="001"; memWr<='0'; memToReg<='0'; regWr<='1'; --addi
    when "010" => regDst<='0'; extOp<='1'; aluSrc<='1'; branch<='0'; jump<='0'; aluOp<="010"; memWr<='0'; memToReg<='1'; regWr<='1'; --lw
    when "011" => regDst<='0'; extOp<='1'; aluSrc<='1'; branch<='0'; jump<='0'; aluOp<="011"; memWr<='1'; memToReg<='0'; regWr<='0'; --sw
    when "100" => regDst<='0'; extOp<='1'; aluSrc<='0'; branch<='1'; jump<='0'; aluOp<="100"; memWr<='0'; memToReg<='0'; regWr<='0'; --beq
    when "101" => regDst<='0'; extOp<='1'; aluSrc<='0'; branch<='1'; jump<='0'; aluOp<="101"; memWr<='0'; memToReg<='0'; regWr<='0'; --bne
    when "110" => regDst<='0'; extOp<='1'; aluSrc<='1'; branch<='0'; jump<='0'; aluOp<="110"; memWr<='0'; memToReg<='0'; regWr<='1'; --xori
    when "111" => regDst<='0'; extOp<='0'; aluSrc<='0'; branch<='0'; jump<='1'; aluOp<="111"; memWr<='0'; memToReg<='0'; regWr<='0'; --j
    end case;
end process;

I_D : instr_decode port map(instr, wd, regWr, regDst, extOp, clk, rd1, rd2, extImm, func, sa);
EX : ex_unit port map(rd1, aluSrc, rd2, extImm, sa, func, aluOp, zero, aluRes);  

process(memWr)
begin
    if en1='0' then
      enMemWr<= '0';
    else
      if memWr='1' then
         enMemWr<= '1';
      else enMemWr<='0';
      end if; 
    end if;
end process;

MEM_RAM : mem port map(enMemWr, aluRes, rd2, memData, aluRes);

pcSrc<=branch and zero;

--WB
process(memToReg)
begin
    if memToReg='0' then
        wd<=aluRes;
    else wd<=memData;
    end if;
end process;


process(sw)
begin
    case (sw(7 downto 5)) is
    when "000" => DO<=instr;
    when "001" => DO<=pc;
    when "010" => DO<=rd1;
    when "011" => DO<=rd2;
    when "100" => DO<=extImm;
    when "101" => DO<=aluRes;
    when "110" => DO<=memData;
    when "111" => DO<=wd;
    end case;
end process;

led(10 downto 8)<=aluOp;
led(7)<=regDst;
led(6)<=extOp;
led(5)<=aluSrc;
led(4)<=branch;
led(3)<=jump;
led(2)<=memWr;
led(1)<=memToReg;
led(0)<=regWr;

SSD_1: SSD port map (DO(15 downto 12), DO(11 downto 8), DO(7 downto 4), DO(3 downto 0), clk, cat, an);

end Behavioral;