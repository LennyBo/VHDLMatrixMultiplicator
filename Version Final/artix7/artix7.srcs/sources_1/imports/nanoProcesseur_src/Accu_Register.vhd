----------------------------------------------------------------------------------
-- Nom du module: Accu_Register
--
-- Description:
--   program counter du nanoProcesseur
--
-- Auteur:        O. Gloriod
--
-- Date et modification:
-- - 13.12.14 mise à jour
-- - 25.08.17 RTI
-- - 28.08.17 double process
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity Accu_Register is
    Port(
         clk_i          : in  std_logic;                     -- horloge système
         reset_i        : in  std_logic;                     -- reset asynchrone
         Accu_Save_i    : in  std_logic;                     -- sauvegarde lors d'une interruption
         Accu_Restore_i : in  std_logic;                     -- restaure lors du RTI
         Accu_Load_i    : in  std_logic;                     -- chargement de l'accumulateur à mémoriser
         Accu_i         : in  std_logic_vector(7 downto 0);  -- valeur de l'accumulateur à mémoriser
         Accu_o         : out std_logic_vector(7 downto 0)   -- valeur de l'accumulateur mémorisée
        );
end Accu_Register;

architecture Behavorial of Accu_Register is

  signal Accu_reg     : std_logic_vector(7 downto 0); -- registre l'accumulateur
  signal Accu_reg_int : std_logic_vector(7 downto 0); -- registre de sauvegarde de l'accumulateur lors d'une interruption
  
begin

-- Accu register
process(clk_i,reset_i)
begin
  if reset_i = '1' then
    Accu_reg     <= (others => '0'); 
  elsif rising_edge(clk_i) then
    if Accu_load_i = '1' then
      Accu_reg <= Accu_i;
    elsif Accu_Restore_i = '1' then
      Accu_reg <= Accu_reg_int;
    end if;
  end if;
end process;

-- Accu register de sauvegarde lors d'une interruption
process(clk_i,reset_i)
begin
  if reset_i = '1' then
    Accu_reg_int <= (others => '0'); 
  elsif rising_edge(clk_i) then
    if Accu_Save_i = '1' then
      Accu_reg_int <= Accu_reg;
    end if;
  end if;
end process;

-- Sortie
Accu_o <= Accu_reg;

end Behavorial;

