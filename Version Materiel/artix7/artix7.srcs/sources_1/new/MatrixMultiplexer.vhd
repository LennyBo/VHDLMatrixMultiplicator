----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/15/2020 05:16:21 PM
-- Design Name: 
-- Module Name: MatrixMultiplexer - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MatrixMultiplexer is
  Port (
        c11_i : in std_logic_vector(7 DOWNTO 0);
        c12_i : in std_logic_vector(7 DOWNTO 0);
        c21_i : in std_logic_vector(7 DOWNTO 0);
        c22_i : in std_logic_vector(7 DOWNTO 0);
        c31_i : in std_logic_vector(7 DOWNTO 0);
        c32_i : in std_logic_vector(7 DOWNTO 0);
        c41_i : in std_logic_vector(7 DOWNTO 0);
        c42_i : in std_logic_vector(7 DOWNTO 0);
        
        Rs_i  : in std_logic_vector(7 DOWNTO 0);
        
        data_o : out std_logic_vector(7 DOWNTO 0)
   );
end MatrixMultiplexer;

architecture Behavioral of MatrixMultiplexer is

begin

data_o <= c11_i when Rs_i = "00000001" else
          c12_i when Rs_i = "00000010" else
          c21_i when Rs_i = "00000100" else
          c22_i when Rs_i = "00001000" else
          c31_i when Rs_i = "00010000" else
          c32_i when Rs_i = "00100000" else
          c41_i when Rs_i = "01000000" else
          c42_i when Rs_i = "10000000" else
          "00000000";

end Behavioral;
