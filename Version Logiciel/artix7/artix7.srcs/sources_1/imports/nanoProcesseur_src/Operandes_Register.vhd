----------------------------------------------------------------------------------
-- Nom du module: Operandes_Register
--
-- Description:
--   program counter du nanoProcesseur
--
-- Auteur:        O. Gloriod (YME)
--
-- Date et modification:
-- - 13.12.14 mise à jour
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity Operandes_Register is
    Port(
         clk_i       : in  std_logic;                     -- horloge système
         reset_i     : in  std_logic;                     -- reset asynchrone
         oper_load_i : in  std_logic;                     -- chargement de l'opérande
         oper_i      : in  std_logic_vector(7 downto 0);  -- valeur à mémoriser
         operande_o  : out std_logic_vector(7 downto 0)   -- valeur mémorisée
        );
end Operandes_Register;

architecture Behavorial of Operandes_Register is

begin

p_oper:process(clk_i,reset_i)
begin
  if reset_i = '1' then
    operande_o <= (others => '0');
  elsif rising_edge(clk_i) then
    if oper_load_i = '1' then
      operande_o <= oper_i; 
    end if;
  end if;
end process;

end Behavorial;

