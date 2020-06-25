----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/14/2020 11:13:00 AM
-- Design Name: 
-- Module Name: Mult - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Mult is
  Port ( 
    A1_i : in std_logic_vector (7 DOWNTO 0);
    A2_i : in std_logic_vector (7 DOWNTO 0);
    A3_i : in std_logic_vector (7 DOWNTO 0);
    A4_i : in std_logic_vector (7 DOWNTO 0);
    B1_i : in std_logic_vector (7 DOWNTO 0);
    B2_i : in std_logic_vector (7 DOWNTO 0);
    B3_i : in std_logic_vector (7 DOWNTO 0);
    B4_i : in std_logic_vector (7 DOWNTO 0);
    
    C1_o : out std_logic_vector (15 DOWNTO 0);
    C2_o : out std_logic_vector (15 DOWNTO 0);
    C3_o : out std_logic_vector (15 DOWNTO 0);
    C4_o : out std_logic_vector (15 DOWNTO 0)
    
  );
end Mult;

architecture Behavioral of Mult is

begin

C1_o <= STD_LOGIC_VECTOR( (UNSIGNED(A1_i) * UNSIGNED(B1_i)) + (UNSIGNED(A2_i) * UNSIGNED(B3_i)));
C2_o <= STD_LOGIC_VECTOR( (UNSIGNED(A1_i) * UNSIGNED(B2_i)) + (UNSIGNED(A2_i) * UNSIGNED(B4_i)));
C3_o <= STD_LOGIC_VECTOR( (UNSIGNED(A3_i) * UNSIGNED(B1_i)) + (UNSIGNED(A4_i) * UNSIGNED(B3_i)));
C4_o <= STD_LOGIC_VECTOR( (UNSIGNED(A3_i) * UNSIGNED(B2_i)) + (UNSIGNED(A4_i) * UNSIGNED(B4_i)));

end Behavioral;
