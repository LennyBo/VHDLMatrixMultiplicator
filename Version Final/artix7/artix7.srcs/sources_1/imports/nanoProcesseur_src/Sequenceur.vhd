----------------------------------------------------------------------------------
-- Nom du module: sequenceur
--
-- Description:
--   sequenceur du nanoProcesseur
--
-- Auteur:        O. Gloriod (YME)
--
-- Date et modification:
-- - 13.12.14 copie
-- - 24.08.17 CALL et RET
-- - 24.08.17 interruption
-- - 25.08.17 RTI
-- - 26.08.17 RETconst
-- - 27.08.17 interrupt_i -> int_reg_i
-- - 28.08.17 CMPconst et CMPaddr
-- - 21.11.19 multiplications
----------------------------------------------------------------------------------

library Work, ieee;
use ieee.std_logic_1164.all;
use Work.nanoProcesseur_package.all;

entity Sequenceur is
  port (
        clk_i           : in  std_logic;
        reset_i         : in  std_logic;
        int_reg_i       : in  std_logic;
        int_pulse_o     : out std_logic;
        RTI_flag_o      : out std_logic;
        PC_inc_o        : out std_logic;
        PC_load_o       : out std_logic;
        PC_stack_push_o : out std_logic; 
        PC_stack_pull_o : out std_logic; 
        IR_load_o       : out std_logic;
        opcode_i        : in  std_logic_vector(5 downto 0);
        CCR_i           : in  std_logic_vector(3 downto 0);
        oper_sel_o      : out std_logic_vector(2 downto 0);
        oper_load_o     : out std_logic;
        Accu_load_o     : out std_logic;
        AccuMSB_load_o  : out std_logic;
        CCR_load_o      : out std_logic;
        data_wr_o       : out std_logic
       );
end entity Sequenceur;

--------------------------------------------------------------------------------
-- Object        : Architecture Work.Sequenceur.Behavioral
-- Last modified : Tue Dec 02 09:53:27 2014.
--------------------------------------------------------------------------------

architecture Behavioral of Sequenceur is

  type STATE_TYPE is (sRESET, sIR_LOAD, sIR_DECODE, sOPCODE_DECODE);
  signal state : STATE_TYPE;
  
  signal int_pulse_set_disable : std_logic;
  
begin


etat_process: process(clk_i,reset_i)
begin
  if reset_i = '1' then
    state <= sRESET;
  elsif rising_edge(clk_i) then
    case state is
      when sRESET =>
       state <= sIR_LOAD;
      when sIR_LOAD =>
        state <= sIR_DECODE;
      when sIR_DECODE =>
        state <= sOPCODE_DECODE;
      when sOPCODE_DECODE =>
        state <= sIR_LOAD;
      when others =>
        -- Erreur, état non prévus. Reset du séquenceur
        state       <= sRESET;
    end case;
  end if;
end process;


interrupt_process: process(clk_i,reset_i)
begin
  if reset_i = '1' then
    int_pulse_set_disable <= '0';
    int_pulse_o           <= '0';
  elsif rising_edge(clk_i) then
    if state = sOPCODE_DECODE then  
      int_pulse_o <= '0';
      if int_pulse_set_disable = '0' and int_reg_i = '1' then
        int_pulse_o           <= '1';
        int_pulse_set_disable <= '1';
      end if;
    end if;
    --
    if int_reg_i = '0' then
      int_pulse_set_disable <= '0';
    end if;
  end if;
end process;

--ASSIGNATION COMBINATOIRE DES SORTIE EN FONCTION DE L'ETAT (STATE) et pour certaines sorties des entrées

PC_load_o       <= '1' when state  = sOPCODE_DECODE                          else '0';
IR_load_o       <= '1' when state  = sIR_LOAD                                else '0';
oper_load_o     <= '1' when state  = sIR_DECODE                              else '0';

data_wr_o       <= '1' when state  = sOPCODE_DECODE AND opcode_i = STOREaddr else '0';

PC_stack_push_o <= '1' when state  = sOPCODE_DECODE AND opcode_i = CALL      else '0'; 

PC_stack_pull_o <= '0' when state /= sOPCODE_DECODE                          else 
                   '1' when                             opcode_i = RET       else
                   '1' when                             opcode_i = RETconst  else
                   '1' when                             opcode_i = RTI       else
                   '0'; 

RTI_flag_o      <= '1' when state  = sOPCODE_DECODE AND opcode_i = RTI       else '0'; 


----------------------------------------------------------------
-- PC_inc_o
PC_inc_process: process(state,opcode_i,CCR_i)
begin
  PC_inc_o <= '0';
  if state = sOPCODE_DECODE then
    
    PC_inc_o <= '1';
    
    case opcode_i is          
      when BRA =>
        PC_inc_o <= '0';
      when BZ0 =>
        if CCR_i(Zidx) = '0' then
          PC_inc_o <= '0';
        end if;            
      when BZ1 =>
        if CCR_i(Zidx) = '1' then
          PC_inc_o <= '0';
        end if;
      when BC0 =>
        if CCR_i(Cidx) = '0' then
          PC_inc_o <= '0';
        end if;
      when BC1 =>
        if CCR_i(Cidx) = '1' then
          PC_inc_o <= '0';
        end if;
      when BV0 =>
        if CCR_i(Vidx) = '0' then
          PC_inc_o <= '0';
        end if;
      when BV1 =>
        if CCR_i(Vidx) = '1' then
          PC_inc_o <= '0';
        end if;
      when BN0 =>
        if CCR_i(Nidx) = '0' then
          PC_inc_o <= '0';
        end if;
      when BN1 =>
        if CCR_i(Nidx) = '1' then
          PC_inc_o <= '0';
        end if;
      when CALL =>
        PC_inc_o <= '0';
      when RET =>
        PC_inc_o <= '0';         
      when RETconst =>
        PC_inc_o <= '0';         
      when RTI =>
        PC_inc_o <= '0';         
      when others =>
        null;
    end case;
  end if;  
end process; 

----------------------------------------------------------------
-- oper_sel_o
oper_sel_process: process(state,opcode_i)
begin
  oper_sel_o <= (others => '0'); 
  if state = sIR_DECODE then  
    -- sélection des opérandes en fonction de l'opcode
    case opcode_i is
      -- 1 opérande
      when ROLaccu   | RORaccu |
           INCaccu   | 
           DECaccu   | 
           NEGaccu   |
           MULTaccu    =>
        oper_sel_o <= MUX_ACCU;

      when LOADconst |
           NEGconst  |
           RETconst    =>
        oper_sel_o <= MUX_CONST;

      when LOADaddr |
           INCaddr  |
           DECaddr  |
           NEGaddr    =>
        oper_sel_o <= MUX_DATA;

      when EXGAMA =>
        oper_sel_o <= MUX_ACCUMSB;
                              
      -- 2 opérandes
      when ANDconst | ORconst   | XORconst |
           ADDconst | ADCconst  |
           CMPconst |
           MULTconst =>
        oper_sel_o <= MUX_ACCU_CONST;

      when ANDaddr | ORaddr   | XORaddr |
           ADDaddr | ADCaddr  | 
           CMPaddr | 
           MULTaddr =>
        oper_sel_o <= MUX_ACCU_DATA;
          
      when others =>
        oper_sel_o <= (others => '0');  
    end case;
  end if;
end process;

----------------------------------------------------------------
-- Accu_load_o
Accu_load_process: process(state,opcode_i)
begin
  Accu_load_o    <= '0';
  AccuMSB_load_o <= '0';
  if state = sOPCODE_DECODE then
    case opcode_i is
      when LOADaddr | LOADconst |
           ANDconst | ANDaddr   | 
           ORconst  | ORaddr    |
           XORconst | XORaddr   |
           RORaccu  | ROLaccu   |
           ADDconst | ADDaddr   | ADCaddr | ADCconst |
           INCaccu  | INCaddr   |
           DECaccu  | DECaddr   |
           NEGaccu  | NEGaddr   | NEGconst |
           RETconst =>
        Accu_load_o <= '1'; 

      when MULTaccu | MULTaddr  | MULTconst |
           EXGAMA =>
        Accu_load_o    <= '1'; 
        AccuMSB_load_o <= '1';
                
      when others =>
        Accu_load_o    <= '0'; 
        AccuMSB_load_o <= '0';
        
    end case;
  end if;
end process;

----------------------------------------------------------------
--CCR_load_o
CCR_load_process: process(state,opcode_i)
begin
  CCR_load_o <= '0';
  if state = sOPCODE_DECODE then
    case opcode_i is
      when LOADaddr | LOADconst |
           ANDconst | ANDaddr   | 
           ORconst  | ORaddr    |
           XORconst | XORaddr   |
           RORaccu  | ROLaccu   |
           ADDconst | ADDaddr   | ADCaddr | ADCconst |
           INCaccu  | INCaddr   |
           DECaccu  | DECaddr   |
           NEGaccu  | NEGaddr   | NEGconst |
           RETconst | 
           CMPconst |
           MULTaccu | MULTaddr  | MULTconst =>
        CCR_load_o <= '1';
        
      when SETC | CLRC | TRFNC =>
        CCR_load_o <= '1'; 
        
      when others =>
        CCR_load_o <= '0';
          
    end case;
  end if;
end process;

end architecture Behavioral;
