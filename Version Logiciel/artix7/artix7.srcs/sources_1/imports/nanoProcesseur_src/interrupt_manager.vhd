----------------------------------------------------------------------------------
-- Nom du module: Interrupt_Manager
--
-- Description:
--   interrupt manager du nanoProcesseur
--
-- Auteur: O. Gloriod
--
-- Date et modification:
-- - 27.08.17 création
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;  
use Work.nanoProcesseur_package.all;

entity Interrupt_Manager is
    port(
         clk_i           : in  std_logic; -- horloge système
         reset_i         : in  std_logic; -- reset asynchrone
         interrupt_set_i : in  std_logic; -- interrupt set flanc montant
         interrupt_clr_i : in  std_logic; -- interrupt clear
         interrupt_reg_o : out std_logic  -- interrupt mémorisé     
        );
end Interrupt_Manager;

architecture Behavorial of Interrupt_Manager is

  signal reg               : std_logic;
  signal interrupt_set_old : std_logic;

begin

-- Branchement de la sortie
interrupt_reg_o <= reg;

-- Process
process(clk_i,reset_i)
begin
  if reset_i = '1' then
    reg <= '0';
    interrupt_set_old <= '0';
  elsif rising_edge(clk_i) then
    if interrupt_set_old = '0' and interrupt_set_i = '1' then    
      reg <= '1';
    elsif interrupt_clr_i = '1' then
      reg <= '0';
    end if;
    --
    interrupt_set_old <= interrupt_set_i;
  end if;
end process;

end Behavorial;

