----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/14/2020 10:44:53 AM
-- Design Name: 
-- Module Name: Addr_decode - Behavioral
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

entity Addr_decode is
  Port (
    addr_i : in std_logic_vector (7 DOWNTO 0);
    
    Rs_o : out std_logic_vector (7 DOWNTO 0);
    RsO_o : out std_logic_vector (7 DOWNTO 0)
    
   );
end Addr_decode;

architecture Behavioral of Addr_decode is

begin

Rs_o <= "00000001" when addr_i = "01000000" else
        "00000010" when addr_i = "01000001" else
        "00000100" when addr_i = "01000010" else
        "00001000" when addr_i = "01000011" else
        "00010000" when addr_i = "01000100" else
        "00100000" when addr_i = "01000101" else
        "01000000" when addr_i = "01000110" else
        "10000000" when addr_i = "01000111" else
        "00000000";

RsO_o <= "00000001" when addr_i = "01001000" else
        "00000010" when addr_i = "01001001" else
        "00000100" when addr_i = "01001010" else
        "00001000" when addr_i = "01001011" else
        "00010000" when addr_i = "01001100" else
        "00100000" when addr_i = "01001101" else
        "01000000" when addr_i = "01001110" else
        "10000000" when addr_i = "01001111" else
        "00000000";

end Behavioral;
