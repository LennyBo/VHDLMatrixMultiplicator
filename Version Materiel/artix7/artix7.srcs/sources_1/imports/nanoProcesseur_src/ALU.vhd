----------------------------------------------------------------------------------
-- Nom du module: ALU
--
-- Description:
--   program counter du nanoProcesseur
--
-- Auteur:        O. Gloriod (YME)
--
-- Date et modification:
-- - 13.12.14 copie  
-- - 15.08.16 numeric_std 
-- - 18.12.16 CCR_i(Cidx downto Cidx)
-- - 26.08.17 RETconst
-- - 28.08.17 CMPconst et CMPaddr
-- - 21.11.19 multiplications
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use Work.nanoProcesseur_package.all;

entity ALU is
    Port(
         operande1_i : in  std_logic_vector(7 downto 0);  -- valeur du 1er  opérande
         operande2_i : in  std_logic_vector(7 downto 0);  -- valeur du 2eme opérande
         opcode_i    : in  std_logic_vector(5 downto 0);  -- opcode de l'instruction
         CCR_i       : in  std_logic_vector(3 downto 0);  -- registre de contrôle
         ALU_LSB_o   : out std_logic_vector(7 downto 0);  -- résultat LSB de l'opération
         ALU_MSB_o   : out std_logic_vector(7 downto 0);  -- résultat MSB de l'opération
         ZCVN_o      : out std_logic_vector(3 downto 0)   -- nouvel état des bits de contrôle
        );
end ALU;

architecture Behavioral of ALU is

  signal uALU_C      : std_logic_vector( 8 downto 0);
  signal uALU16      : std_logic_vector(15 downto 0);
  signal ALU16enable : std_logic;
  signal CCR_mask    : std_logic_vector( 3 downto 0);
  signal flag_Z      : std_logic;
  signal flag_C      : std_logic;
  signal flag_V      : std_logic;
  signal flag_n      : std_logic;
  
begin

process(opcode_i, operande1_i, operande2_i,CCR_i)
begin

  uALU_C        <= (others => '0');
  uALU16        <= (others => '0');
  ALU16enable   <= '0';            
  CCR_mask      <= (others => '0');
  
  case opcode_i is
    when LOADconst | LOADaddr | RETconst =>   
      uALU_C <= '0' & operande1_i;
      CCR_mask(Zidx) <= '1';
      CCR_mask(Nidx) <= '1';
      
    when ORconst | ORaddr =>
      uALU_C <= ('0' & operande1_i) OR ('0' & operande2_i);
      CCR_mask(Zidx) <= '1';
      CCR_mask(Nidx) <= '1';

    when ANDconst | ANDaddr =>
      uALU_C <= ('0' & operande1_i) AND ('0' & operande2_i);
      CCR_mask(Zidx) <= '1';
      CCR_mask(Nidx) <= '1';

    when XORconst | XORaddr =>
      uALU_C <= ('0' & operande1_i) XOR ('0' & operande2_i);
      CCR_mask(Zidx) <= '1';
      CCR_mask(Nidx) <= '1';
      
     when ROLaccu =>
      uALU_C <= operande1_i & CCR_i(Cidx);
      CCR_mask(Cidx) <= '1';
      CCR_mask(Zidx) <= '1';
      CCR_mask(Nidx) <= '1';      

    when RORaccu =>
      uALU_C <= operande1_i(0) & CCR_i(Cidx) & operande1_i(7 downto 1);
      CCR_mask(Cidx) <= '1';
      CCR_mask(Zidx) <= '1';
      CCR_mask(Nidx) <= '1';    
      
    when ADDconst | ADDaddr =>
      uALU_C   <= STD_LOGIC_VECTOR( UNSIGNED('0' & operande1_i) + UNSIGNED('0' & operande2_i) );
      CCR_mask <= (others => '1');
      
    when ADCaddr | ADCconst =>
      -- le carry doit être convertit en bus de 1 bit 
      uALU_C   <= STD_LOGIC_VECTOR( UNSIGNED('0' & operande1_i) + UNSIGNED('0' & operande2_i) + UNSIGNED(CCR_i(Cidx downto Cidx)) );
      CCR_mask <= (others => '1');
      
    when NEGaccu | NEGconst | NEGaddr =>
      uALU_C <= '0' & STD_LOGIC_VECTOR( UNSIGNED(operande1_i XOR "11111111") + 1);
      CCR_mask(Zidx) <= '1';
      CCR_mask(Nidx) <= '1';
      
    when INCaccu  | INCaddr =>
      uALU_C <= STD_LOGIC_VECTOR( UNSIGNED('0' & operande1_i) + 1);
      CCR_mask(Cidx) <= '1';
      CCR_mask(Zidx) <= '1';
      CCR_mask(Nidx) <= '1';      

    when DECaccu  | DECaddr =>
      uALU_C <= STD_LOGIC_VECTOR( UNSIGNED('0' & operande1_i) + 511 );
      CCR_mask(Cidx) <= '1';
      CCR_mask(Zidx) <= '1';
      CCR_mask(Nidx) <= '1';
      
    when CMPconst | CMPaddr => -- Accu-const donc oper1-oper2
      uALU_C <= STD_LOGIC_VECTOR( UNSIGNED('0' & operande1_i) - UNSIGNED('0' & operande2_i) );
      CCR_mask(Zidx) <= '1';
      CCR_mask(Nidx) <= '1';

    when MULTaddr | MULTconst =>
      uALU16 <= STD_LOGIC_VECTOR( UNSIGNED(operande1_i) * UNSIGNED(operande2_i) );
      ALU16enable    <= '1';
      CCR_mask(Cidx) <= '1';
      CCR_mask(Zidx) <= '1';
      CCR_mask(Nidx) <= '1';        
      
    when MULTaccu =>
      uALU16 <= STD_LOGIC_VECTOR( UNSIGNED(operande1_i) * UNSIGNED(operande1_i) );
      ALU16enable    <= '1';
      CCR_mask(Cidx) <= '1';
      CCR_mask(Zidx) <= '1';
      CCR_mask(Nidx) <= '1';        
      
    when EXGAMA =>
      uALU16      <= operande1_i & operande2_i;
      ALU16enable <= '1';      

    when others =>
     null;         -- Les valeurs par défaut sont mises avant le case
  end case;
end process;


    
-- Branchement de la sortie
ALU_LSB_o <= uALU_C(7 downto 0) when ALU16enable = '0' else uALU16( 7 downto 0);
ALU_MSB_o <= (others => '0')    when ALU16enable = '0' else uALU16(15 downto 8);
    
-- indicateur de contrôle
flag_Z <= CCR_i(Zidx) when CCR_mask(Zidx) = '0' else
          '1'         when ALU16enable = '0' and uALU_C(7 DOWNTO 0) = X"00"   else
          '1'         when ALU16enable = '1' and uALU16             = X"0000" else
          '0';

flag_N <= CCR_i(Nidx) when CCR_mask(Nidx) = '0' else
          uALU_C(7)   when ALU16enable    = '0' else
          uALU16(15);

flag_V <= CCR_i(Vidx) when CCR_mask(Vidx) = '0' else
          '0'         when operande1_i(7) /= operande2_i(7) else
          '1'         when operande1_i(7) /= uALU_C(7) else
          '0';

flag_C <= '0'         when opcode_i = CLRC      else
          '1'         when opcode_i = SETC      else
          CCR_i(Nidx) when opcode_i = TRFNC     else
          CCR_i(Cidx) when CCR_mask(Cidx) = '0' else
          uALU_C(8)   when ALU16enable = '0'    else
          '0';

ZCVN_o <= flag_Z & flag_C & flag_V & flag_N;

end architecture Behavioral ; -- of ALU
