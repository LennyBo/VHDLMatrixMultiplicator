----------------------------------------------------------------------------------
-- Nom du module: Data_Multiplexer
--
-- Description:
--   multiplexeur des données (pour la lecture) du nanoControleur
--
-- Auteur:        O. Gloriod (YME)
--
-- Date et modification:
-- - 07.01.15 zedboard
-- - 28.08.17 IP BCD7SEG
-- - 04.09.17 IP 0 à 3
----------------------------------------------------------------------------------

library Work, ieee;
use ieee.std_logic_1164.all;
use Work.nanoProcesseur_package.all;


entity Data_Multiplexer is
  port (
    RAM_data_i    : in     std_logic_vector(7 downto 0);
    port_a_data_i : in     std_logic_vector(7 downto 0);
    port_b_data_i : in     std_logic_vector(7 downto 0);
    ip0_data_i    : in     std_logic_vector(7 downto 0);
    ip1_data_i    : in     std_logic_vector(7 downto 0);
    ip2_data_i    : in     std_logic_vector(7 downto 0);
    ip3_data_i    : in     std_logic_vector(7 downto 0);
    data_o        : out    std_logic_vector(7 downto 0);
    cs_ram_i      : in     std_logic;
    cs_port_a_i   : in     std_logic;
    cs_port_b_i   : in     std_logic;
    cs_ip_i       : in     std_logic_vector(3 downto 0)
    );
end entity Data_Multiplexer;


architecture Behavioral of Data_Multiplexer is
  
begin

data_o <= RAM_data_i     when cs_ram_i     = '1' else
          port_a_data_i  when cs_port_a_i  = '1' else
          port_b_data_i  when cs_port_b_i  = '1' else
          ip0_data_i     when cs_ip_i(0)   = '1' else
          ip1_data_i     when cs_ip_i(1)   = '1' else
          ip2_data_i     when cs_ip_i(2)   = '1' else
          ip3_data_i     when cs_ip_i(3)   = '1' else
          (others => '-');

	  
end architecture Behavioral ; -- of Data_Multiplexer
