----------------------------------------------------------------------------------
-- Nom du module: Instruction_Register
--
-- Description:
--   program counter du nanoProcesseur
--
-- Auteur:        O. Gloriod
--
-- Date et modification:
-- - 19.10.14 création
-- - 24.08.17 interruption
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;  
use Work.nanoProcesseur_package.all;

entity Instruction_Register is
    Port(
         clk_i       : in  std_logic;                     -- horloge système
         reset_i     : in  std_logic;                     -- reset asynchrone
         IR_load_i   : in  std_logic;                     -- chargement du registre d'instruction (impulsion)
         IR_i        : in  std_logic_vector(13 downto 0); -- instruction
         int_pulse_i : in  std_logic;                     -- interruption
         opcode_o    : out std_logic_vector( 5 downto 0); -- opcode de l'instruction
         operande_o  : out std_logic_vector( 7 downto 0)  -- opérande contenu dans l'instruction
        );
end Instruction_Register;

architecture Behavorial of Instruction_Register is

	signal IR_Reg : std_logic_vector(13 downto 0);
	
begin

-- Branchement des sorties
operande_o <= IR_reg( 7 downto 0);
opcode_o   <= IR_reg(13 downto 8);

-- Process
process(clk_i,reset_i)
begin
  if reset_i = '1' then
    IR_reg <= (others => '0');
  elsif rising_edge(clk_i) then
    if IR_load_i = '1' then    
      if int_pulse_i = '0' then
        IR_reg <= IR_i;
      else
        IR_reg <= CALL & X"FF";
      end if; 
    end if;
  end if;
end process;

end Behavorial;

