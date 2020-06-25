----------------------------------------------------------------------------------
-- Nom du module: Timer
--
-- Description:
--   Timer
--
-- Auteur:        O. Gloriod
--
-- Date et modification:
-- - 26.08.17 création
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer is
    Generic(
            SIMULATION : boolean := false;
            DIVN : integer := 100E6/400 -- 400Hz @ 100MHz
           );
    Port(
         clk_i   : in  std_logic;
         reset_i : in  std_logic;
         p_o     : out std_logic  -- impulsion (pulse) de fréquence fclk_i/DIVN, durée une période de clk_i
        );
end timer;

architecture Behavorial of timer is

 function setConst(cond:boolean; vtrue:integer; vfalse:integer) return integer is
 begin
   if cond then
     return vtrue;
   else
     return vfalse;
   end if;
 end;
 
 constant divn_simu : integer := setConst(SIMULATION,DIVN/1000,DIVN);
 signal reg : integer range 0 to DIVN-1;

begin

process(clk_i,reset_i)
begin
  if reset_i = '1' then
    reg <= divn_simu-1;
    p_o <= '0';
  elsif rising_edge(clk_i) then
    if reg = 0 THEN
      reg <= divn_simu-1;
      p_o <= '1';
    else
      reg <= reg-1;
      p_o <= '0';
    end if;
  end if;
end process;

end Behavorial;

