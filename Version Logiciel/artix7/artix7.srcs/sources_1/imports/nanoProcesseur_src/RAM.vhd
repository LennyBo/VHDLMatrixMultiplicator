----------------------------------------------------------------------------------
-- Nom du module: RAM
--
-- Description:
--   RAM du nanoControleur
--
-- Auteur:        O. Gloriod (YME)
--
-- Date et modification:
-- - 13.12.14 copie
--
----------------------------------------------------------------------------------

library Work, ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use Work.nanoProcesseur_package.all;

entity RAM is
  port (
    clk_i  : in     std_logic;
    cs_i   : in     std_logic;
    wr_i   : in     std_logic;
    addr_i : in     std_logic_vector(7  downto 0);
    data_i : in     std_logic_vector(7  downto 0);
    data_o : out    std_logic_vector(7  downto 0));
end entity RAM;

architecture Behavioral of RAM is

  type     blocRAM_type is array(0 to 31) of std_logic_vector(7 downto 0); 
  signal   blocRAM : blocRAM_type;
  
  signal   addr_reg : std_logic_vector(4 downto 0);

begin

process(clk_i)
begin
  if rising_edge(clk_i) then
    if cs_i = '1' and wr_i = '1' then
      blocRAM(to_integer(unsigned(addr_i(4 downto 0)))) <= data_i;
    end if;
    
    addr_reg <= addr_i(4 DOWNTO 0);
    
  end if;
end process;

data_o <= blocRAM(to_integer(unsigned(addr_i(4 downto 0))));

end architecture Behavioral ; -- of RAM
