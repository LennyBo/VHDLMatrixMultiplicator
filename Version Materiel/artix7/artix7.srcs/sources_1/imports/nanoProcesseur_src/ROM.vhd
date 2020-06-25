----------------------------------------------------------------------------------
-- Nom du module: ROM
--
-- Description:
--   ROM du nanoControleur
--
-- Auteur: O. Gloriod
--
-- Date et modification:
-- - 07.01.15 zedboard
-- - 26.08.17 BCD 7 SEG
-- - 28.08.17 smartROM
-- - 28.08.17 IP BCD
-- - 28.08.17 CMPconst
-- - 04.09.17 remove data_i
-- - 21.11.19 exemple
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.nanoProcesseur_package.all;

entity ROM is
  port(
       pc_i   : in  std_logic_vector( 7 downto 0);
       ir_o   : out std_logic_vector(13 downto 0)
      );
end entity ROM;

architecture Behavioral of ROM is

  --------------------------------------------------
  -- Fonction de conversion integer en hexa
  -- - si integer < 0 retourne la valeur complémentée
  function i2h(a:integer) return std_logic_vector is
    variable h : std_logic_vector(7 downto 0);
  begin
    if a<0 then
      h := std_logic_vector(to_signed(a,8));
    else
      h := std_logic_vector(to_unsigned(a,8));
    end if;
    return h;
  end;
  --------------------------------------------------

  --------------------------------------------------
  -- fonction de conversion hexa en integer
  function h2i(a:std_logic_vector) return integer is
  begin
    return to_integer(unsigned(a));
  end;
  --------------------------------------------------

  --------------------------------------------------
  -- fonction de addition hexa
  function hph(a:std_logic_vector; b:std_logic_vector) return std_logic_vector is
  begin
    return std_logic_vector(unsigned(a)+unsigned(b));
  end;
  --------------------------------------------------

  --------------------------------------------------
  -- fonction setif: sif(cond,valtrue,valfalse) 
  function sif(c:boolean; v, f :integer) return integer is
  begin
    if c then return v;
    else      return f;
    end if;
  end;

  -- fonction setifhexa: sifh(cond,valtrue,valfalse) 
  function sifh(c:boolean; v, f :integer) return std_logic_vector is
  begin
    return std_logic_vector(to_unsigned(sif(c,v,f),8));
  end;
  --------------------------------------------------

  --------------------------------------------------
  -- pc : program counter de type integer
  signal   pc     : integer range 0 to 255;
  
  -- constant de 8 bits à 0
  constant noArg  : std_logic_vector(7 downto 0) := (others=>'0');
  
  -- adresses des ports
  constant portA : std_logic_vector(7 downto 0) := hph(BASEADDR_PORT,X"00");
  constant portB : std_logic_vector(7 downto 0) := hph(BASEADDR_PORT,X"01");
  
  -- Registres IP0
  --constant ip0 : std_logic_vector(7 downto 0) := hph(BASEADDR_IP0,X"40"); -- IP2 data0 écriture (adresse)  
  
  -- Registres IP1
  constant ip1 : std_logic_vector(7 downto 0) := hph(BASEADDR_IP0,X"04"); -- IP2 data0 écriture (adresse)  

  -- Registres IP2
  constant ip2 : std_logic_vector(7 downto 0) := hph(BASEADDR_IP0,X"06"); -- IP2 data0 écriture (adresse)  

  -- Registres IP3
  constant ip3 : std_logic_vector(7 downto 0) := hph(BASEADDR_IP0,X"0F"); -- IP2 data0 écriture (adresse)  

  -- Variables
  
  
  constant a1       : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"40");  
  constant a2       : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"41");  
  constant a3       : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"42");  
  constant a4       : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"43"); 
  constant b1       : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"44"); 
  constant b2       : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"45"); 
  constant b3       : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"46"); 
  constant b4       : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"47"); 
  constant c11    : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"48");  
  constant c12    : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"49");  
  constant c21    : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"4A");  
  constant c22    : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"4B"); 
  constant c31    : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"4C"); 
  constant c32    : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"4D"); 
  constant c41    : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"4E"); 
  constant c42    : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"4F"); 
  
  
           
  -- Adresses des sous-routines et des labels
 
  -- Ne pas dépasser 250
  constant lblSTART    : integer := 0;
  constant lblReadSW   : integer := 10;
  constant lblWaitFlag : integer := 20;
  --                                            --constantes du programme (des incrémenteurs? )
  constant srShiftLED  : integer := 180;
  constant srWriteLED  : integer := 200;
  --
  constant srINT       : integer := 240;
  --
  --------------------------------------------------
 
begin

pc <= to_integer(unsigned(pc_i));

-------------------------------------------------------------
-- Programme sous forme de with select
with pc select 

  ir_o <= --début du programme en adresse 0      

  -- Fonctions d'aide:
  -- i2h(a) integer (signé ou non signé) to hexa
  -- h2i(a) hexa to integer (int non signé)
  -- hph(a,b) addition hexa
  -- sif(condition,si vrai, si faux) set si

  --mnémonique   opérande           pc (adresse de l'instruction) 
          
-- lblSTART  
    --LOADconst   & a1                    when lblSTART+0,
    --ADDconst    & a2                    when lblSTART+1,
    --STOREaddr   & porta                 when lblSTART+2,
    
    --Loading constatns and sw values
    --Matrix a
    LOADconst & "00000000" when lblSTART+0,
    STOREaddr   & a1                 when lblSTART+1,
    LOADconst & "00000001" when lblSTART+2,
    STOREaddr   & a2                 when lblSTART+3,
    LOADconst & "00000010" when lblSTART+4,
    STOREaddr   & a3                 when lblSTART+5,
    LOADconst & "00000011" when lblSTART+6,
    STOREaddr   & a4                 when lblSTART+7,
    LOADconst & "00000100" when lblSTART+8,
    STOREaddr   & b1                 when lblSTART+9,
    LOADconst & "00000101" when lblSTART+10,
    STOREaddr   & b2                 when lblSTART+11,
    LOADconst & "00000110" when lblSTART+12,
    STOREaddr   & b3                 when lblSTART+13,
    LOADconst & "00000111" when lblSTART+14,
    STOREaddr   & b4                 when lblSTART+15,
    
    LOADaddr    & c12       when lblSTART+16,
    STOREaddr   & portA        when lblSTART+17,
    
    
    BRA         & i2h(lblSTART+18)         when lblSTART+18,
    
    -- Vecteur d'interruption (changer l'adresse srINT)
    BRA         & i2h(srINT)            when 255,
                       
    -- Code exécuté en cas d'erreur d'adresse
    BRA          & i2h(254)             when others;
    
    
    
----------------------------------------------------------------
                  
end architecture Behavioral ; -- of ROM
