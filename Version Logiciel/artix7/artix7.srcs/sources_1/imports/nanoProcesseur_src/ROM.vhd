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
  constant ip0 : std_logic_vector(7 downto 0) := hph(BASEADDR_IP0,X"08"); -- IP2 data0 écriture (adresse)  
  
  -- Registres IP1
  constant ip1 : std_logic_vector(7 downto 0) := hph(BASEADDR_IP0,X"04"); -- IP2 data0 écriture (adresse)  

  -- Registres IP2
  constant ip2 : std_logic_vector(7 downto 0) := hph(BASEADDR_IP0,X"06"); -- IP2 data0 écriture (adresse)  

  -- Registres IP3
  constant ip3 : std_logic_vector(7 downto 0) := hph(BASEADDR_IP0,X"0F"); -- IP2 data0 écriture (adresse)  

  -- Variables
  
  constant vLED1    : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"00");  
  constant vLED2    : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"01");     
  constant vINT0    : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"1D"); 
  constant vINT1    : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"1E"); 
  constant vINTflag : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"1F"); --Met l'adresse 0x1F de la RAM dans la constante vINTflag.
  
  constant a1       : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"02");  
  constant a2       : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"03");  
  constant a3       : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"04");  
  constant a4       : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"05"); 
  constant b1       : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"06"); 
  constant b2       : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"07"); 
  constant b3       : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"08"); 
  constant b4       : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"09"); 
  constant c11    : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"0a");  
  constant c12    : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"0b");  
  constant c21    : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"0c");  
  constant c22    : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"0d"); 
  constant c31    : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"0e"); 
  constant c32    : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"0f"); 
  constant c41    : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"10"); 
  constant c42    : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"11"); 
  
  
           
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
    LOADaddr    & porta                when lblSTART+0, -- lecture
    STOREaddr   & a1                 when lblSTART+1,
    LOADconst    & "00000010"                 when lblSTART+2, -- lecture
    STOREaddr   & a2                 when lblSTART+3,
    LOADconst    & "00000100"                 when lblSTART+4, -- lecture
    STOREaddr   & a3                 when lblSTART+5,
    LOADconst    & "00000001"                 when lblSTART+6, -- lecture
    STOREaddr   & a4                 when lblSTART+7,
    --Matrix b
    LOADaddr    & portb                 when lblSTART+8, -- lecture
    STOREaddr   & b1                 when lblSTART+9, 
    LOADconst    & "00000010"                 when lblSTART+10, -- lecture
    STOREaddr   & b2                 when lblSTART+11,
    LOADconst    & "00000100"                 when lblSTART+12, -- lecture
    STOREaddr   & b3                 when lblSTART+13,
    LOADconst    & "00000001"                 when lblSTART+14, -- lecture
    STOREaddr   & b4                 when lblSTART+15,
    
    --Start matrix mulitplication
    --First multiplication (c1)
    LOADaddr   & a1                 when lblSTART+16,
    MULTaddr    & b1                 when lblSTART+17,
    STOREaddr   & c11 when lblSTART+18,
    EXGAMA      & "00000000"            when lblSTART+19,
    STOREaddr   & c12 when lblSTART+20,
    --Second multiplication
    LOADaddr   & a2                 when lblSTART+21,
    MULTaddr    & b3                 when lblSTART+22,
    --Adding the prev result
    ADDaddr     & c11      when lblSTART+23,
    STOREaddr   & c11 when lblSTART+24,
    EXGAMA      & "00000000"            when lblSTART+25,
    ADDaddr     & c12      when lblSTART+26,
    STOREaddr   & c12 when lblSTART+27,
    
    --Next multiplication
    LOADaddr    & a1                 when lblSTART+28,
    MULTaddr    & b2                 when lblSTART+29,
    STOREaddr   & c21 when lblSTART+30,
    EXGAMA      & "00000000"            when lblSTART+31,
    STOREaddr   & c22 when lblSTART+32,
    
    LOADaddr   & a2                 when lblSTART+33,
    MULTaddr    & b4                 when lblSTART+34,
    ADDaddr     & c21      when lblSTART+35,
    STOREaddr   & c21 when lblSTART+36,
    EXGAMA      & "00000000"            when lblSTART+37,
    ADDaddr     & c22      when lblSTART+38,
    STOREaddr   & c22 when lblSTART+39,
    
    LOADaddr    & a3                 when lblSTART+40,
    MULTaddr    & b1                 when lblSTART+41,
    STOREaddr   & c31 when lblSTART+42,
    EXGAMA      & "00000000"            when lblSTART+43,
    STOREaddr   & c32 when lblSTART+44,
    
    LOADaddr   & a4                 when lblSTART+45,
    MULTaddr    & b3                 when lblSTART+46,
    ADDaddr     & c31      when lblSTART+47,
    STOREaddr   & c31 when lblSTART+48,
    EXGAMA      & "00000000"            when lblSTART+49,
    ADDaddr     & c32      when lblSTART+50,
    STOREaddr   & c32 when lblSTART+51,
    
    LOADaddr    & a3                 when lblSTART+52,
    MULTaddr    & b2                 when lblSTART+53,
    STOREaddr   & c41 when lblSTART+54,
    EXGAMA      & "00000000"            when lblSTART+55,
    STOREaddr   & c42 when lblSTART+56,
    
    LOADaddr   & a4                 when lblSTART+57,
    MULTaddr    & b4                 when lblSTART+58,
    ADDaddr     & c41      when lblSTART+59,
    STOREaddr   & c41 when lblSTART+60,
    EXGAMA      & "00000000"            when lblSTART+61,
    ADDaddr     & c42      when lblSTART+62,
    STOREaddr   & c42 when lblSTART+63,
    
    --Showing the restults
    LOADaddr    & c11 when lblSTART+64, 
    STOREaddr   & portA  when lblSTART+65, 
    LOADaddr    & c12 when lblSTART+66, 
    STOREaddr   & portB  when lblSTART+67, 
    --Wating before the next value
    NOP         & "00000000"        when lblSTART+68,
    NOP         & "00000000"        when lblSTART+69,
    
    LOADaddr    & c21 when lblSTART+70, 
    STOREaddr   & portA  when lblSTART+71, 
    LOADaddr    & c22 when lblSTART+72, 
    STOREaddr   & portB  when lblSTART+73, 
    NOP         & "00000000"        when lblSTART+74,
    NOP         & "00000000"        when lblSTART+75,
    
    LOADaddr    & c31 when lblSTART+76, 
    STOREaddr   & portA  when lblSTART+77, 
    LOADaddr    & c32 when lblSTART+78, 
    STOREaddr   & portB  when lblSTART+79, 
    NOP         & "00000000"        when lblSTART+80,
    NOP         & "00000000"        when lblSTART+81,
    LOADaddr    & c41 when lblSTART+82, 
    STOREaddr   & portA  when lblSTART+83, 
    LOADaddr    & c42 when lblSTART+84, 
    STOREaddr   & portB  when lblSTART+85, 
    NOP         & "00000000"        when lblSTART+86,
    NOP         & "00000000"        when lblSTART+87,
    
    BRA         & i2h(lblSTART+64)         when lblSTART+88,
    
    -- Vecteur d'interruption (changer l'adresse srINT)
    BRA         & i2h(srINT)            when 255,
                       
    -- Code exécuté en cas d'erreur d'adresse
    BRA          & i2h(254)             when others;
    
    
    
----------------------------------------------------------------
                  
end architecture Behavioral ; -- of ROM
