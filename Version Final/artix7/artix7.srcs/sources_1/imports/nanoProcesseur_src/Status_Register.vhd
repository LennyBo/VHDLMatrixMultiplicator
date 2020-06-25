----------------------------------------------------------------------------------
-- Nom du module: Status_Register
--
-- Description:
--   registre de status (CCR) du nanoProcesseur
--
-- Auteur:        O. Gloriod (YME)
--
-- Date et modification:
-- - 13.12.14 copie
-- - 25.08.17 CCR
-- - 28.08.17 double process
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity Status_Register is
    Port(
         clk_i         : in  std_logic;                     -- horloge système
         reset_i       : in  std_logic;                     -- reset asynchrone
         CCR_Save_i    : in  std_logic;                     -- sauvegarde lors d'une interruption
         CCR_Restore_i : in  std_logic;                     -- restaure lors du RTI
         CCR_Load_i    : in  std_logic;                     -- chargement des bits de contrôle
         CCR_i         : in  std_logic_vector(3 downto 0);  -- bits de contrôle à mémoriser
         CCR_o         : out std_logic_vector(3 downto 0)   -- bits de contrôle mémorisés
        );
end Status_Register;

architecture Behavorial of Status_Register is

  signal CCR_reg     : std_logic_vector(3 downto 0); -- registre de CCR
  signal CCR_reg_int : std_logic_vector(3 downto 0); -- registre de sauvegarde de CCR lors d'une interruption
  
begin

-- Status register
process(clk_i,reset_i)
begin
  if reset_i = '1' then
    CCR_reg     <= (others => '0'); 
  elsif rising_edge(clk_i) then
    if CCR_load_i = '1' then
      CCR_reg <= CCR_i;
    elsif CCR_Restore_i = '1' then
      CCR_reg <= CCR_reg_int;
    end if;
  end if;
end process;

-- Status register pour sauvegarde lors d'une interruption
process(clk_i,reset_i)
begin
  if reset_i = '1' then
    CCR_reg_int <= (others => '0'); 
  elsif rising_edge(clk_i) then
    if CCR_Save_i = '1' then
      CCR_reg_int <= CCR_reg;
    end if;
  end if;
end process;

-- Sortie
CCR_o <= CCR_reg;

end Behavorial;

