----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/15/2020 05:07:00 PM
-- Design Name: 
-- Module Name: Reg16To8 - Behavioral
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

entity Reg16To8 is
  Port ( 
        data_i : in std_logic_vector(15 DOWNTO 0);
        
        c1_o : out std_logic_vector (7 DOWNTO 0);
        c2_o : out std_logic_vector (7 DOWNTO 0)
  );
end Reg16To8;

architecture Behavioral of Reg16To8 is

begin

c1_o <= data_i(15 DOWNTO 8);
c2_o <= data_i(7 DOWNTO 0);

end Behavioral;
