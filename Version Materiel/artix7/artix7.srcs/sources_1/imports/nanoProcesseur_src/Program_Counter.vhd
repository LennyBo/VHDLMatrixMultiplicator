----------------------------------------------------------------------------------
-- Nom du module: Program_Counter
--
-- Description:
--   program counter du nanoProcesseur
--
-- Auteur:        O. Gloriod (YME)
--
-- Date et modification:
-- - 13.12.14 copie
-- - 24.08.17 CALL et RET
-- - 24.08.17 interruption
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Program_Counter is
    Port(
         clk_i           : in  std_logic;                     -- horloge système
         reset_i         : in  std_logic;                     -- reset asynchrone
         int_pulse_i     : in  std_logic;                     -- interruption
         PC_inc_i        : in  std_logic;                     -- incrémentation du PC (impulsion)
         PC_load_i       : in  std_logic;                     -- chargement du PC (impulsion)
         addr_i          : in  std_logic_vector(7 downto 0);  -- adresse à chargée dans le PC
         PC_stack_pull_i : in  std_logic;                     -- restaure l'adresse provenant de la pile
         PC_stack_i      : in  std_logic_vector(7 downto 0);  -- adresse provenant de la pile à chargée dans le PC
         PC_o            : out std_logic_vector(7 downto 0);  -- valeur du PC 
         PC1_o           : out std_logic_vector(7 downto 0)   -- valeur du PC +1 ou +0 
        );
end Program_Counter;

architecture Behavorial of Program_Counter is

 signal PC_counter : unsigned(7 DOWNTO 0);

begin

process(clk_i,reset_i)
begin
  if reset_i = '1' then
    PC_counter <= (others => '0');
  elsif rising_edge(clk_i) then
    if PC_inc_i = '1' THEN
      PC_counter <= PC_counter + 1;
    elsif PC_stack_pull_i = '1' then
      PC_counter <= unsigned(PC_stack_i);
    elsif PC_load_i = '1' then   -- <- tester en dernier (priorité basse)
      PC_counter <= unsigned(addr_i);
    end if;
  end if;
end process;

PC_o  <= std_logic_vector(PC_counter);
PC1_o <= std_logic_vector(PC_counter+1) when int_pulse_i = '0' else std_logic_vector(PC_counter);

end Behavorial;

