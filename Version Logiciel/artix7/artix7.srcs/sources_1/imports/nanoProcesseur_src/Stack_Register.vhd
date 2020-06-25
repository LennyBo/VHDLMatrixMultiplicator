----------------------------------------------------------------------------------
-- Nom du module: Stack_Register
--
-- Description:
--   pile du nanoProcesseur
--
-- Auteur:        O. Gloriod (YME)
--
-- Date et modification:
-- - 24.08.17 création
-- - 25.08.17 modif stack_o
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity Stack_Register is
    Port(
         clk_i        : in  std_logic;                     -- horloge système
         reset_i      : in  std_logic;                     -- reset asynchrone
         Stack_Push_i : in  std_logic;                     -- pousse la valeur dans la pile
         Stack_Pull_i : in  std_logic;                     -- récupére la dernière valeur introduite
         Stack_i      : in  std_logic_vector(7 downto 0);  -- valeur à mémoriser
         Stack_o      : out std_logic_vector(7 downto 0)   -- dernière valeur
        );
end Stack_Register;

architecture Behavorial of Stack_Register is

  type STACK_REG_Type is array(7 downto 0) of std_logic_vector(7 downto 0); -- Pile de 8 éléments
  signal stack_reg : STACK_REG_Type;

begin

process(clk_i,reset_i)
begin
  if reset_i = '1' then
    stack_reg <= (others => (others => '0'));
  elsif rising_edge(clk_i) then
    if Stack_Push_i = '1' then
      stack_reg <= stack_reg(6 downto 0) & Stack_i;
    elsif Stack_Pull_i = '1' then
      stack_reg <= "00000000" & stack_reg(7 downto 1);
    end if;
  end if;
end process;

Stack_o   <= stack_reg(0);

end Behavorial;

