----------------------------------------------------------------------------------
-- Nom du module: Address_Decode
--
-- Description:
--   Décodeur d'adresses du nanoControleur
--
-- Auteur: O. Gloriod
--
-- Date et modification:
-- - 07.01.15 zedboard
-- - 27.08.17 adresses des ports
-- - 28.08.17 IP BCD7SEG
-- - 04.09.17 IP de 0 à 3
-- - 20.11.19
----------------------------------------------------------------------------------

library Work, ieee;
use ieee.std_logic_1164.all;
use Work.nanoProcesseur_package.all;

entity Address_Decode is
  port (
    addr_i      : in  std_logic_vector(7 downto 0);
    cs_ram_o    : out std_logic;  -- adresse sur 5 bits, 32 bytes
    cs_port_a_o : out std_logic;  -- adresse sur 8 bits
    cs_port_b_o : out std_logic;  -- adresse sur 8 bits
    cs_ip_o     : out std_logic_vector(3 downto 0); -- adresses sur 4 bits, 4x16 bytes
    cs_poussoir_o : out std_logic
    );
end entity Address_Decode;


architecture behavioral of Address_Decode is

begin

-- RAM 32 bytes
cs_ram_o     <= '1' when addr_i(7 downto 5) = BASEADDR_RAM(7 downto 5) else '0';

-- IP 4 x 16 bytes
cs_ip_o(0)   <= '1' when addr_i(7 downto 4) = BASEADDR_IP0(7 downto 4) else '0';
cs_ip_o(1)   <= '1' when addr_i(7 downto 4) = BASEADDR_IP1(7 downto 4) else '0';
cs_ip_o(2)   <= '1' when addr_i(7 downto 4) = BASEADDR_IP2(7 downto 4) else '0';
cs_ip_o(3)   <= '1' when addr_i(7 downto 4) = BASEADDR_IP3(7 downto 4) else '0';

-- Port 128 x 1 bytes
cs_port_a_o  <= '1' when addr_i = BASEADDR_PORT(7 downto 1)&'0' else '0';
cs_port_b_o  <= '1' when addr_i = BASEADDR_PORT(7 downto 1)&'1' else '0'; 
cs_poussoir_o <= '1' when addr_i = BASEADDR_POUSSOIR(7 DOWNTO 0) else '0';


end architecture behavioral;

