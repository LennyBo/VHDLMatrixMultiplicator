----------------------------------------------------------------------------------
-- Nom du module: nanoControler
--
-- Description:
--   top niveau du projet nanoControler
--
-- Auteur:        O. Gloriod (YME)
--
-- Date et modification:
-- - 07.01.15 zedboard   
-- - 16.08.16 artix7
-- - 24.08.17 interruption 
-- - 27.08.17 IP Timer
-- - 28.08.17 smartROM
-- - 28.08.17 IP BCD7SEG
-- - 04.09.17 IP 0 à 3
-- - 21.11.19 vide
----------------------------------------------------------------------------------

library Work, ieee;
use ieee.std_logic_1164.all;
use Work.nanoProcesseur_package.all;

-- Pour la zedboard ne mettre que 1 port d'entrée et un port de sortie

entity nanoControleur is
  generic(
          SIMULATION : boolean := false
         );
  port (
        clk_i       : in      std_logic;
        reset_n_i   : in      std_logic;
        port_a_i    : in      std_logic_vector(7 downto 0);
        port_b_i    : in      std_logic_vector(7 downto 0);
        poussoir_i  : in      std_logic_vector(3 DOWNTO 0);
        port_a_o    : out     std_logic_vector(7 downto 0);
        port_b_o    : out     std_logic_vector(7 downto 0)
       );
end entity nanoControleur;


architecture Structural of nanoControleur is

  signal reset                   : std_logic; 
    
  signal PC                      : std_logic_vector( 7 downto 0); -- program counter from nanoProcesseur to ron
  signal ir                      : std_logic_vector(13 downto 0); -- instruction from rom to nanoPorcesseur
  signal poussoir8Bit            : std_logic_vector (7 DOWNTO 0);
  signal nanoProcesseur_wr       : std_logic;                     -- write from nanoProcesseur
  signal nanoProcesseur_addr     : std_logic_vector( 7 downto 0); -- addr from nanoProcesseur
  signal nanoProcesseur_data_out : std_logic_vector( 7 downto 0); -- data from nanoPorcesseur
  signal nanoProcesseur_data_in  : std_logic_vector( 7 downto 0); -- data for nanoProcesseur
  
  signal ram_data                : std_logic_vector( 7 downto 0); -- data from ram
  signal ip0_data                : std_logic_vector( 7 downto 0); -- data from ip0
  signal ip1_data                : std_logic_vector( 7 downto 0); -- data from ip1
  signal ip2_data                : std_logic_vector( 7 downto 0); -- data from ip2
  signal ip3_data                : std_logic_vector( 7 downto 0); -- data from ip3
  
  signal cs_ram                  : std_logic; -- chip select for ram
  signal cs_port_a               : std_logic; -- chip select for port A (in out)
  signal cs_port_b               : std_logic; -- chip select for port B (in out)
  signal cs_poussoir             : std_logic;
  signal cs_ip                   : std_logic_vector(3 downto 0); -- chip select for ip
 
  signal timer_pulse             : std_logic; -- pulse from internal timer
  
  signal lcd_rwn                 : std_logic;                    -- RWn pour le LCD
  signal lcd_data_in             : std_logic_vector(7 downto 0); -- data du LCD
  signal lcd_data_out            : std_logic_vector(7 downto 0); -- data pour le LCD
  
  component nanoProcesseur
    port (
      clk_i       : in  std_logic;
      reset_i     : in  std_logic;
      interrupt_i : in  std_logic; --pour la simulation --> pas besoin d'y toucher pour le moment.Pour la réduire la fréquence
      PC_o        : out std_logic_vector(7  downto 0);
      IR_i        : in  std_logic_vector(13 downto 0);
      addr_o      : out std_logic_vector(7  downto 0);
      data_i      : in  std_logic_vector(7  downto 0);
      data_o      : out std_logic_vector(7  downto 0);
      data_wr_o   : out std_logic
      );
  end component nanoProcesseur;
  
  component IPMultMat
      port (
        clk_i :in std_logic;
          reset_i : in std_logic;
          CS_i : in std_logic;
          load_i : in std_logic;
          data_i : in std_logic_vector (7 DOWNTO 0);
          addr_i : in std_logic_vector (7 DOWNTO 0);
          
          data_o : out std_logic_vector(7 DOWNTO 0)
        );
    end component IPMultMat;

  component ROM
    port (
          pc_i   : in  std_logic_vector( 7 downto 0);
          ir_o   : out std_logic_vector(13 downto 0)
         );
  end component ROM;

  component Address_Decode
    port (
      addr_i      : in  std_logic_vector(7 downto 0);
      cs_ram_o    : out std_logic;
      cs_port_a_o : out std_logic;
      cs_port_b_o : out std_logic;
      cs_ip_o     : out std_logic_vector(3 downto 0);
      cs_poussoir_o : out std_logic
      );
  end component Address_Decode;

  component Data_Multiplexer
    port (
      RAM_data_i     : in  std_logic_vector(7 downto 0);
      port_a_data_i  : in  std_logic_vector(7 downto 0);
      port_b_data_i  : in  std_logic_vector(7 downto 0);
      poussoir_data_i : in     std_logic_vector(7 downto 0);
      ip0_data_i     : in  std_logic_vector(7 downto 0);
      ip1_data_i     : in  std_logic_vector(7 downto 0);
      ip2_data_i     : in  std_logic_vector(7 downto 0);
      ip3_data_i     : in  std_logic_vector(7 downto 0);
      data_o         : out std_logic_vector(7 downto 0);
      cs_ram_i       : in  std_logic;
      cs_port_a_i    : in  std_logic;
      cs_port_b_i    : in  std_logic;
      cs_poussoir_i : in     std_logic;
      cs_ip_i        : in  std_logic_vector(3 downto 0)
     );
  end component Data_Multiplexer;

  component RAM
    port (
          clk_i  : in  std_logic;
          cs_i   : in  std_logic;
          wr_i   : in  std_logic;
          addr_i : in  std_logic_vector(7  downto 0);
          data_i : in  std_logic_vector(7  downto 0);
          data_o : out std_logic_vector(7  downto 0)
          );
  end component RAM;

  component Output_Register
    port (
          clk_i   : in  std_logic;
          reset_i : in  std_logic;
          cs_i    : in  std_logic;
          load_i  : in  std_logic;
          data_i  : in  std_logic_vector(7 downto 0);
          data_o  : out std_logic_vector(7 downto 0)
          );
  end component Output_Register;

  -- timer
  component timer is
    Generic(
            SIMULATION : boolean := false;
            DIVN : integer := 100E6/400 -- 400Hz @ 100MHz
           );
    Port(
         clk_i   : in  std_logic;
         reset_i : in  std_logic;
         p_o     : out std_logic  -- impulsion (pulse) de fréquence fclk_i/DIVN, durée une période de clk_i
        );
  end component timer;  
    
begin

  reset <= not reset_n_i;
  
  nPr_inst: nanoProcesseur
    port map(
             clk_i       => clk_i,
             reset_i     => reset,
             interrupt_i => timer_pulse,
             PC_o        => PC,
             IR_i        => ir,
             addr_o      => nanoProcesseur_addr,
             data_i      => nanoProcesseur_data_in,
             data_o      => nanoProcesseur_data_out,
             data_wr_o   => nanoProcesseur_wr
            );

  ROM_inst: ROM
    port map(
             pc_i   => PC,
             ir_o   => ir
            );

  Data_Mux_inst: Data_Multiplexer
    port map(
         RAM_data_i    => ram_data,
         port_a_data_i => port_a_i,
         port_b_data_i => port_b_i, 
         poussoir_data_i => poussoir8Bit,
         ip0_data_i    => ip0_data,
         ip1_data_i    => ip1_data,
         ip2_data_i    => ip2_data,
         ip3_data_i    => ip3_data,
         data_o        => nanoProcesseur_data_in,
         cs_ram_i      => cs_ram,
         cs_port_a_i   => cs_port_a,
         cs_port_b_i   => cs_port_b,
         cs_poussoir_i => cs_poussoir,
         cs_ip_i       => cs_ip
    );

  Addr_Decode_inst: Address_Decode
    port map(
      addr_i       => nanoProcesseur_addr,
      cs_ram_o     => cs_ram,
      cs_port_a_o  => cs_port_a,
      cs_port_b_o  => cs_port_b, 
      cs_ip_o      => cs_ip,
      cs_poussoir_o => cs_poussoir
      );
 
  RAM_inst: RAM
    port map(
         clk_i  => clk_i,
         cs_i   => cs_ram,
         wr_i   => nanoProcesseur_wr,
         addr_i => nanoProcesseur_addr,
         data_i => nanoProcesseur_data_out,
         data_o => ram_data
    );
            
    IPMultMat_inst: IPMultMat
    port map(
          clk_i => clk_i,
          reset_i => reset,
          CS_i => cs_ip(0),
          load_i => nanoProcesseur_wr,
          data_i => nanoProcesseur_data_out,
          addr_i => nanoProcesseur_addr,
          
          data_o => ip0_data
    );

  Port_a_Out_inst: Output_Register
    port map(
             clk_i   => clk_i,
             reset_i => reset,
             cs_i    => cs_port_a,
             load_i  => nanoProcesseur_wr,
             data_i  => nanoProcesseur_data_out,
             data_o  => port_a_o
            );

  Port_b_Out_inst: Output_Register
    port map(
             clk_i   => clk_i,
             reset_i => reset,
             cs_i    => cs_port_b,
             load_i  => nanoProcesseur_wr,
             data_i  => nanoProcesseur_data_out,
             data_o  => port_b_o 
             );


   timer_inst: timer
    Generic map(
            SIMULATION => SIMULATION,
            DIVN => 100E6/400 -- 400Hz @ 100MHz
           )
    Port map(
         clk_i   => clk_i,
         reset_i => reset,
         p_o     => timer_pulse
        );     
        
        
        
-- IP internes 0 à 3 (à instancier à la place du process)
-- - ip0_data est lu par le uC quand nanoProcesseur_addr(7 downto 4) = BASEADDR_IP0
-- - cs_ip(0) est activé quand nanoProcesseur_addr(7 downto 4) = BASEADDR_IP0
-- - dans IP0 utiliser :
--   - nanoProcesseur_addr(3 downto 0) pour lire/écrire les registres
--   - nanoProcesseur_wr et cs_ip(0) pour écrire
--   - nanoProcesseur_data_out donnée à écrire dans l'IP
-- idem pour les autres IP 1 à 3

   -- Exemple sous forme de process
   process(clk_i,reset)
   begin
     if reset='1' then 
       --ip0_data <= BASEADDR_IP0; -- valeur par défaut
       ip1_data <= BASEADDR_IP1; -- valeur par défaut
       ip2_data <= BASEADDR_IP2; -- valeur par défaut
       ip3_data <= BASEADDR_IP3; -- valeur par défaut
     elsif rising_edge(clk_i) then
       if nanoProcesseur_wr='1' then
         --if cs_ip(0)='1' and nanoProcesseur_addr(3 downto 0)="1000" then
           --ip0_data <= nanoProcesseur_data_out; -- registre 8
         --end if;
         if cs_ip(1)='1' and nanoProcesseur_addr(3 downto 0)="0100" then
           ip1_data <= nanoProcesseur_data_out; -- registre 4
         end if;
         if cs_ip(2)='1' and nanoProcesseur_addr(3 downto 0)="0110" then 
           ip2_data <= nanoProcesseur_data_out; -- registre 5
         end if;
         if cs_ip(3)='1' and nanoProcesseur_addr(3 downto 0)="1111" then
           ip3_data <= nanoProcesseur_data_out;  -- registre 15
         end if;
       end if;
     end if;
   end process;
   
   poussoir8Bit <= "0000" &  poussoir_i;
              
end architecture Structural ; -- of nanoControleur

