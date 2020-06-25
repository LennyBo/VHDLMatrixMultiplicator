---------------------------------------------------------
-- Version:
--   OGL/15.11.18a
---------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end testbench;

architecture structure of testbench is

-- Declaration du composant UUT
-- Exemple:
component nanoControleur is
   Generic(
        SIMULATION: boolean := true
        );
   Port(
        clk_i       : in      std_logic;
        reset_n_i   : in      std_logic;
        port_a_i    : in      std_logic_vector(7 downto 0);
        port_b_i    : in      std_logic_vector(7 downto 0);
        port_a_o    : out     std_logic_vector(7 downto 0);
        port_b_o    : out     std_logic_vector(7 downto 0);
        poussoir_i  : in      std_logic_vector(3 DOWNTO 0)
   );
end component;

-- Signaux pour instanciation composant UUT
-- Dans les testbench on laisse _i et _o à la fin des noms des signaux
-- qui sont connectés aux ports du composant
-- Exemple:
signal reset_n_i    : std_logic;
signal clk_i        : std_logic;
signal port_a_i     : std_logic_vector(7 downto 0); 
signal port_b_i     : std_logic_vector(7 downto 0); 
signal port_a_o     : std_logic_vector(7 downto 0); 
signal port_b_o     : std_logic_vector(7 downto 0);
signal poussoir_i     : std_logic_vector(7 downto 0);
-- Signaux propres au testbench (pas relié au composant)      
-- Ne pas modifier
signal mark_error_signal    : std_logic := '0';
signal error_number_signal  : integer   := 0;
signal mark_error_vecteur   : std_logic := '0';
signal error_number_vecteur : integer   := 0;
signal clk_gen              : std_logic := '0';
signal sim_finie            : std_logic := '0';

begin

-- Intanciation du composant UUT 
-- Exemple
uut: nanoControleur
    port map(
                clk_i      => clk_i,
                reset_n_i  => reset_n_i,
                port_a_i   => port_a_i,
                port_b_i   => port_b_i,
                port_a_o   => port_a_o,
                port_b_o   => port_b_o,
                poussoir_i => poussoir_i
    );
         
--********** PROCESS "clk_gengen" **********
--clk_gengen_25MHz: process
--begin
--  clk_gen <= '1', '0' after 1 ns;
--  --commenter si on teste une fonction combinatoire (pas de clock)
--  clk_i   <= '1', '0' after 5 ns, '1' after 17 ns;
--  wait for 25 ns;
--end process;
clk_gengen_100MHz: process
begin
  clk_gen <= '1', '0' after 1 ns;
  --commenter si on teste une fonction combinatoire (pas de clock)
  clk_i   <= '1', '0' after 3 ns, '1' after 7 ns;
  wait for 10 ns;
end process;


--********** PROCESS "run" **********
run: process

  --********** PROCEDURE "sim_cycle" **********
  -- permet d'attendre un certain nombre de flanc montant de clk_gen
  procedure sim_cycle(num : in integer) is
  begin
    for index in 1 to num loop
      wait until clk_gen = '1';
    end loop;
  end sim_cycle;

  --********** PROCEDURE "test_signal" **********
  procedure test_signal(signal_test, valeur: in std_logic; erreur : in integer) is 
  begin
     if signal_test /= valeur then
          mark_error_signal <= '1', '0' after 1 ns;
          error_number_signal <= erreur;
          assert false report "Etat du signal non correct" severity warning;
     end if;
  end test_signal;

 --********** PROCEDURE "test_vecteur" **********
  procedure test_vecteur(signal_test, valeur: in std_logic_vector; erreur : in integer) is 
  begin
     assert signal_test'length = valeur'length report "test_vecteur erreur: taille des bus" severity failure;
     if signal_test /= valeur then
          mark_error_vecteur <= '1', '0' after 1 ns;
          error_number_vecteur <= erreur;
          assert false report "Etat du signal non correct" severity warning;
     end if;
  end test_vecteur;

begin
  -- Début de la simulation temps t=0ns
  -- Fixer une valeur sur TOUTES les entrées (initialisation) sauf pour clk_i
  --
  -- Exemple
  reset_n_i      <= '0';
  port_a_i       <= "00000000";
  port_b_i       <= "00000000";
  poussoir_i     <= "00000000";
  -- mon_bus_i <= (others => '0'); -- met à '0' tous les éléments du bus
  --
  -- Ici mettre uniquement l'état initial des entrée
    
  -- Mettre le reste du testbench après sim_cycle(2)
  assert false report "La simulation est en cours" severity note;
  sim_cycle(2);
  -- Début des tests
    
  reset_n_i     <= '1';
  port_a_i      <= "00000001";
  port_b_i      <= "00000001";  
 
  sim_cycle(100);
  
  port_a_i      <= "00000011";
  port_b_i      <= "00000011";  

  sim_cycle(100); 
 
  -- Fin des tests, arrêt du process avec WAIT;
  sim_finie <= '1';
  wait;

end process;

end structure;

