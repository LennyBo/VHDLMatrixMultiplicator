----------------------------------------------------------------------------------
-- Nom du module: Operandes_Multiplexer
--
-- Description:
--   program counter du nanoProcesseur
--
-- Auteur:        O. Gloriod
--
-- Date et modification:
-- - 13.12.14 mise à jour
-- - 21.11.19 multiplications
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use Work.nanoProcesseur_package.all;

entity Operandes_Multiplexer is
    Port(
         sel_i     : in  std_logic_vector(2 downto 0);  -- bus de sélection de l'opérande
         Accu_i    : in  std_logic_vector(7 downto 0);  -- valeur de l'accumulateur
         AccuMSB_i : in  std_logic_vector(7 downto 0);  -- valeur de l'accumulateur MSB
         const_i   : in  std_logic_vector(7 downto 0);  -- constante contenue dans l'instruction
         data_i    : in  std_logic_vector(7 downto 0);  -- valeur provenant d'une adresse
         oper1_o   : out std_logic_vector(7 downto 0);  -- valeur sélectionnée pour oper1
         oper2_o   : out std_logic_vector(7 downto 0)   -- valeur sélectionnée pour oper2
        );
end Operandes_Multiplexer;

architecture Behavorial of Operandes_Multiplexer is

begin

with sel_i select
  oper1_o <= Accu_i    when MUX_ACCU,
             const_i   when MUX_CONST,
             data_i    when MUX_DATA,
             Accu_i    when others;
               
with sel_i select
  oper2_o <= const_i   when MUX_ACCU_CONST,
             data_i    when MUX_ACCU_DATA,
             AccuMSB_i when MUX_ACCUMSB,
             Accu_i    when others;

end Behavorial;

