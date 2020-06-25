----------------------------------------------------------------------------------
-- Nom du module: Output_Register
--
-- Description:
--   Registre des ports de sortie du nanoControleur
--
-- Auteur:        O. Gloriod (YME)
--
-- Date et modification:
-- - 13.12.14 copie
--
----------------------------------------------------------------------------------

library Work, ieee;
use ieee.std_logic_1164.all;
use Work.nanoProcesseur_package.all;

entity Output_Register is
  port (
    clk_i   : in     std_logic;
    reset_i : in     std_logic;
    cs_i    : in     std_logic;
    load_i  : in     std_logic;
    data_i  : in     std_logic_vector(7 downto 0);
    data_o  : out    std_logic_vector(7 downto 0));
end entity Output_Register;


architecture Behavioral of Output_Register is
  
begin

process(clk_i,reset_i)
begin
  if reset_i = '1' then
    data_o <= (others => '0');
  elsif rising_edge(clk_i) then
    if cs_i = '1' and load_i = '1' then
      data_o <= data_i;
    end if;
  end if;
end process;

end architecture Behavioral ; -- of Output_Register
