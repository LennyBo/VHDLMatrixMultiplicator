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
  constant poussoir : std_logic_vector(7 DOWNTO 0) := hph(BASEADDR_POUSSOIR,X"00");
  
  -- Registres IP0
  --constant ip0 : std_logic_vector(7 downto 0) := hph(BASEADDR_IP0,X"40"); -- IP2 data0 écriture (adresse)  
  
  -- Registres IP1
  constant ip1 : std_logic_vector(7 downto 0) := hph(BASEADDR_IP0,X"04"); -- IP2 data0 écriture (adresse)  

  -- Registres IP2
  constant ip2 : std_logic_vector(7 downto 0) := hph(BASEADDR_IP0,X"06"); -- IP2 data0 écriture (adresse)  

  -- Registres IP3
  constant ip3 : std_logic_vector(7 downto 0) := hph(BASEADDR_IP0,X"0F"); -- IP2 data0 écriture (adresse)  

  -- Variables
    constant Rc11    : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"00");  
    constant Rc12    : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"01");  
    constant Rc21    : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"02"); 
    constant Rc22    : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"03"); 
    constant Rc31    : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"04");  
    constant Rc32    : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"05");  
    constant Rc41    : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"06"); 
    constant Rc42    : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"07"); 
    constant Ra2    : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"08");  
    constant Ra3    : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"09");  
    constant Ra4    : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"0A"); 
    constant Rb2    : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"0B"); 
    constant Rb3    : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"0C");  
    constant Rb4    : std_logic_vector(7 downto 0) := hph(BASEADDR_RAM,X"0D");  
  
  --address pour la version materiel
  constant a1       : std_logic_vector(7 downto 0) := hph(BASEADDR_IP0,X"00");  
  constant a2       : std_logic_vector(7 downto 0) := hph(BASEADDR_IP0,X"01");  
  constant a3       : std_logic_vector(7 downto 0) := hph(BASEADDR_IP0,X"02");  
  constant a4       : std_logic_vector(7 downto 0) := hph(BASEADDR_IP0,X"03"); 
  constant b1       : std_logic_vector(7 downto 0) := hph(BASEADDR_IP0,X"04"); 
  constant b2       : std_logic_vector(7 downto 0) := hph(BASEADDR_IP0,X"05"); 
  constant b3       : std_logic_vector(7 downto 0) := hph(BASEADDR_IP0,X"06"); 
  constant b4       : std_logic_vector(7 downto 0) := hph(BASEADDR_IP0,X"07"); 
  constant c11    : std_logic_vector(7 downto 0) := hph(BASEADDR_IP0,X"08");  
  constant c12    : std_logic_vector(7 downto 0) := hph(BASEADDR_IP0,X"09");  
  constant c21    : std_logic_vector(7 downto 0) := hph(BASEADDR_IP0,X"0A");  
  constant c22    : std_logic_vector(7 downto 0) := hph(BASEADDR_IP0,X"0B"); 
  constant c31    : std_logic_vector(7 downto 0) := hph(BASEADDR_IP0,X"0C"); 
  constant c32    : std_logic_vector(7 downto 0) := hph(BASEADDR_IP0,X"0D"); 
  constant c41    : std_logic_vector(7 downto 0) := hph(BASEADDR_IP0,X"0E"); 
  constant c42    : std_logic_vector(7 downto 0) := hph(BASEADDR_IP0,X"0F"); 
  
  
           
  -- Adresses des sous-routines et des labels
 
  -- Ne pas dépasser 250
  constant lblStart    : integer := 0;
  constant lblVersionMateriel    : integer := 20;
  constant lblVersionLogiciel   : integer := 60;
  
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
        LOADconst & "00000001" when lblStart+0,
        STOREaddr & Ra2          when lblStart+1,
        LOADconst & "00000010" when lblStart+2,
        STOREaddr & Ra3          when lblStart+3,
        LOADconst & "00000011" when lblStart+4,
        STOREaddr & Ra4          when lblStart+5,
        LOADconst & "00000101" when lblStart+6,
        STOREaddr & Rb2          when lblStart+7,
        LOADconst & "00000110" when lblStart+8,
        STOREaddr & Rb3          when lblStart+9,
        LOADconst & "00000111" when lblStart+10,
        STOREaddr & Rb4          when lblStart+11,
        
        BRA         & i2h(lblVersionMateriel ) when lblStart+12,
        
        LOADaddr    & portA                 when lblVersionMateriel+0,
        STOREaddr   & a1                    when lblVersionMateriel+1,
        LOADaddr    & Ra2                   when lblVersionMateriel+2,
        STOREaddr   & a2                    when lblVersionMateriel+3,
        LOADaddr    & Ra3                   when lblVersionMateriel+4,
        STOREaddr   & a3                    when lblVersionMateriel+5,
        LOADaddr    & Ra4                   when lblVersionMateriel+6,
        STOREaddr   & a4                    when lblVersionMateriel+7,
        LOADaddr    & portB                 when lblVersionMateriel+8,
        STOREaddr   & b1                    when lblVersionMateriel+9,
        LOADaddr    & Rb2                   when lblVersionMateriel+10,
        STOREaddr   & b2                    when lblVersionMateriel+11,
        LOADaddr    & Rb3                   when lblVersionMateriel+12,
        STOREaddr   & b3                    when lblVersionMateriel+13,
        LOADaddr    & Rb4                   when lblVersionMateriel+14,
        STOREaddr   & b4                    when lblVersionMateriel+15,
        
        LOADaddr    & c11       when lblVersionMateriel+16,
        STOREaddr   & Rc11      when lblVersionMateriel+17,
        LOADaddr    & c12       when lblVersionMateriel+18,
        STOREaddr   & Rc12      when lblVersionMateriel+19,
        LOADaddr    & c21       when lblVersionMateriel+20,
        STOREaddr   & Rc21      when lblVersionMateriel+21,
        LOADaddr    & c22       when lblVersionMateriel+22,
        STOREaddr   & Rc22      when lblVersionMateriel+23,
        LOADaddr    & c31       when lblVersionMateriel+24,
        STOREaddr   & Rc31      when lblVersionMateriel+25,
        LOADaddr    & c32       when lblVersionMateriel+26,
        STOREaddr   & Rc32      when lblVersionMateriel+27,
        LOADaddr    & c41       when lblVersionMateriel+28,
        STOREaddr   & Rc41      when lblVersionMateriel+29,
        LOADaddr    & c42       when lblVersionMateriel+30,
        STOREaddr   & Rc42      when lblVersionMateriel+31,
        
        BRA         & i2h(srWriteLED) when lblVersionMateriel+32,
        
        
        --Start matrix mulitplication
        --First multiplication (c1)
        LOADaddr   & portA                 when lblVersionLogiciel+0,
        MULTaddr    & portB                 when lblVersionLogiciel+1,
        STOREaddr   & Rc11 when lblVersionLogiciel+2,
        EXGAMA      & "00000000"            when lblVersionLogiciel+3,
        STOREaddr   & Rc12 when lblVersionLogiciel+4,
        --Second multiplication
        LOADaddr   & Ra2                 when lblVersionLogiciel+5,
        MULTaddr    & Rb3                 when lblVersionLogiciel+6,
        --Adding the prev result
        ADDaddr     & Rc11      when lblVersionLogiciel+7,
        STOREaddr   & Rc11 when lblVersionLogiciel+8,
        EXGAMA      & "00000000"            when lblVersionLogiciel+9,
        ADDaddr     & Rc12      when lblVersionLogiciel+10,
        STOREaddr   & Rc12 when lblVersionLogiciel+11,
        
        --Next multiplication
        LOADaddr    & portA                 when lblVersionLogiciel+12,
        MULTaddr    & portB                 when lblVersionLogiciel+13,
        STOREaddr   & Rc21 when lblVersionLogiciel+14,
        EXGAMA      & "00000000"            when lblVersionLogiciel+15,
        STOREaddr   & Rc22 when lblVersionLogiciel+16,
        
        LOADaddr   & Ra2                 when lblVersionLogiciel+17,
        MULTaddr    & Rb4                 when lblVersionLogiciel+18,
        ADDaddr     & Rc21      when lblVersionLogiciel+19,
        STOREaddr   & Rc21 when lblVersionLogiciel+20,
        EXGAMA      & "00000000"            when lblVersionLogiciel+21,
        ADDaddr     & Rc22      when lblVersionLogiciel+22,
        STOREaddr   & Rc22 when lblVersionLogiciel+23,
        
        LOADaddr    & Ra3                 when lblVersionLogiciel+24,
        MULTaddr    & portB                 when lblVersionLogiciel+25,
        STOREaddr   & Rc31 when lblVersionLogiciel+26,
        EXGAMA      & "00000000"            when lblVersionLogiciel+27,
        STOREaddr   & Rc32 when lblVersionLogiciel+28,
        
        LOADaddr   & Ra4                 when lblVersionLogiciel+29,
        MULTaddr    & Rb3                 when lblVersionLogiciel+30,
        ADDaddr     & Rc31      when lblVersionLogiciel+31,
        STOREaddr   & Rc31 when lblVersionLogiciel+32,
        EXGAMA      & "00000000"            when lblVersionLogiciel+33,
        ADDaddr     & Rc32      when lblVersionLogiciel+34,
        STOREaddr   & Rc32 when lblVersionLogiciel+35,
        
        LOADaddr    & Ra3                 when lblVersionLogiciel+36,
        MULTaddr    & Rb2                 when lblVersionLogiciel+37,
        STOREaddr   & Rc41 when lblVersionLogiciel+38,
        EXGAMA      & "00000000"            when lblVersionLogiciel+39,
        STOREaddr   & Rc42 when lblVersionLogiciel+40,
        
        LOADaddr   & Ra4                 when lblVersionLogiciel+41,
        MULTaddr    & Rb4                 when lblVersionLogiciel+42,
        ADDaddr     & Rc41      when lblVersionLogiciel+43,
        STOREaddr   & Rc41 when lblVersionLogiciel+44,
        EXGAMA      & "00000000"            when lblVersionLogiciel+45,
        ADDaddr     & Rc42      when lblVersionLogiciel+46,
        STOREaddr   & Rc42 when lblVersionLogiciel+47,
         BRA         & i2h(srWriteLED) when lblVersionLogiciel+48,
        
        
        LOADaddr    & Rc11 when srWriteLED+0, 
        STOREaddr   & portB  when srWriteLED+1, 
        LOADaddr    & Rc12 when srWriteLED+2, 
        STOREaddr   & portA  when srWriteLED+3, 
        --Wating before the next value
        NOP         & "00000000"        when srWriteLED+4,
        NOP         & "00000000"        when srWriteLED+5,
        
        LOADaddr    & Rc21 when srWriteLED+6, 
        STOREaddr   & portB  when srWriteLED+7, 
        LOADaddr    & Rc22 when srWriteLED+8, 
        STOREaddr   & portA  when srWriteLED+9, 
        NOP         & "00000000"        when srWriteLED+10, 
        NOP         & "00000000"        when srWriteLED+11,
        
        LOADaddr    & Rc31 when srWriteLED+12, 
        STOREaddr   & portB  when srWriteLED+13, 
        LOADaddr    & Rc32 when srWriteLED+14, 
        STOREaddr   & portA  when srWriteLED+15, 
        NOP         & "00000000"        when srWriteLED+16,
        NOP         & "00000000"        when srWriteLED+17,
        LOADaddr    & Rc41 when srWriteLED+18, 
        STOREaddr   & portB  when srWriteLED+19, 
        LOADaddr    & Rc42 when srWriteLED+20, 
        STOREaddr   & portA  when srWriteLED+21, 
        NOP         & "00000000"        when srWriteLED+22,
        NOP         & "00000000"        when srWriteLED+23,
        
        BRA         & i2h(srWriteLED)         when srWriteLED+24,
        
    
    
    -- Vecteur d'interruption (changer l'adresse srINT)
    BRA         & i2h(srINT)            when 255,
                       
    -- Code exécuté en cas d'erreur d'adresse
    BRA          & i2h(254)             when others;
    
    
    
----------------------------------------------------------------
                  
end architecture Behavioral ; -- of ROM
