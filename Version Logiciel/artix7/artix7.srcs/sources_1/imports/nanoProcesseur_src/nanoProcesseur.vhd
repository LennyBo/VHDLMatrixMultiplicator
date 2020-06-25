----------------------------------------------------------------------------------
-- Nom du module: nanoProcesseur
--
-- Description:
--   top niveau du projet nanoProcesseur
--
-- Auteur:        O. Gloriod
--
-- Date et modification:
-- - 19.10.14 cr�ation
-- - 24.08.17 CALL et RET
-- - 24.08.17 interruption
-- - 25.08.17 RTI
-- - 21.11.19 multiplications
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity nanoProcesseur is
    Port(
         clk_i       : in  std_logic;                     -- horloge syst�me
         reset_i     : in  std_logic;                     -- reset asynchrone
         interrupt_i : in  std_logic;                     -- interruption
         PC_o        : out std_logic_vector( 7 downto 0); -- program counter
         IR_i        : in  std_logic_vector(13 downto 0); -- instruction
         data_wr_o   : out std_logic;                     -- data write (impulsion)
         addr_o      : out std_logic_vector( 7 downto 0); -- adresse bus pour lecture et �criture
         data_o      : out std_logic_vector( 7 downto 0); -- data bus pour l'�criture
         data_i      : in  std_logic_vector( 7 downto 0)  -- data bus pour la lecture
        );
end nanoProcesseur;

architecture Structural of nanoProcesseur is

  component Instruction_Register is
    Port(
         clk_i       : in  std_logic;                     -- horloge syst�me
         reset_i     : in  std_logic;                     -- reset asynchrone
         IR_load_i   : in  std_logic;                     -- chargement du registre d'instruction (impulsion)
         IR_i        : in  std_logic_vector(13 downto 0); -- instruction      
         int_pulse_i : in  std_logic;                     -- interruption
         opcode_o    : out std_logic_vector( 5 downto 0); -- opcode de l'instruction
         operande_o  : out std_logic_vector( 7 downto 0)  -- op�rande contenu dans l'instruction
        );
  end component;

  component Interrupt_Manager is
    port(
         clk_i           : in  std_logic; -- horloge syst�me
         reset_i         : in  std_logic; -- reset asynchrone
         interrupt_set_i : in  std_logic; -- interrupt set flanc montant
         interrupt_clr_i : in  std_logic; -- interrupt clear
         interrupt_reg_o : out std_logic  -- interrupt m�moris�     
        );
  end component;
        
  component Sequenceur is
    Port(
         clk_i           : in  std_logic;                     -- horloge syst�me
         reset_i         : in  std_logic;                     -- reset asynchrone
         int_reg_i       : in  std_logic;                     -- interruption m�moris�e
         int_pulse_o     : out std_logic;                     -- interruption en cours de traitement
         RTI_flag_o      : out std_logic;                     -- RTI est trait�e
         opcode_i        : in  std_logic_vector(5 downto 0);  -- opcode de l'instruction
         CCR_i           : in  std_logic_vector(3 downto 0);  -- �tat actuel du registre de contr�le
         PC_inc_o        : out std_logic;                     -- incr�mentation du PC (impulsion)
         PC_load_o       : out std_logic;                     -- chargement du PC (impulsion)
         PC_stack_push_o : out std_logic;                     -- sauvegarde du PC (impulsion) dans la pile 
         PC_stack_pull_o : out std_logic;                     -- restaure le PC (impulsion) depuis la pile
         IR_load_o       : out std_logic;                     -- chargement du registre d'instruction (impulsion)
         oper_sel_o      : out std_logic_vector(2 downto 0);  -- bus de s�lection des op�randes
         oper_load_o     : out std_logic;                     -- chargement de l'op�rande (impulsion)
         Accu_load_o     : out std_logic;                     -- chargement de l'accumulateur (impulsion)
         AccuMSB_load_o  : out std_logic;                     -- chargement de l'accumulateur MSB (impulsion)
         CCR_load_o      : out std_logic;                     -- chargement du registre de contr�le (impulsion)
         data_wr_o       : out std_logic                      -- data write pour l'�criture des donn�es (impulsion)
        );
  end component;

  component Program_Counter is
    Port(
         clk_i           : in  std_logic;                     -- horloge syst�me
         reset_i         : in  std_logic;                     -- reset asynchrone
         int_pulse_i     : in  std_logic;                     -- interruption
         PC_inc_i        : in  std_logic;                     -- incr�mentation du PC (impulsion)
         PC_load_i       : in  std_logic;                     -- chargement du PC (impulsion)
         addr_i          : in  std_logic_vector(7 downto 0);  -- adresse � charg�e dans le PC
         PC_stack_pull_i : in  std_logic;                     -- restaure l'adresse provenant de la pile
         PC_stack_i      : in  std_logic_vector(7 downto 0);  -- adresse provenant de la pile � charg�e dans le PC
         PC_o            : out std_logic_vector(7 downto 0);  -- valeur du PC 
         PC1_o           : out std_logic_vector(7 downto 0)   -- valeur du PC +1 ou +0 
        );
  end component;

  component Operandes_Multiplexer is
    Port(
         sel_i     : in  std_logic_vector(2 downto 0);  -- bus de s�lection de l'op�rande
         Accu_i    : in  std_logic_vector(7 downto 0);  -- valeur de l'accumulateur
         AccuMSB_i : in  std_logic_vector(7 downto 0);  -- valeur de l'accumulateur MSB
         const_i   : in  std_logic_vector(7 downto 0);  -- constante contenue dans l'instruction
         data_i    : in  std_logic_vector(7 downto 0);  -- valeur provenant d'une adresse
         oper1_o   : out std_logic_vector(7 downto 0);  -- valeur s�lectionn�e pour oper1
         oper2_o   : out std_logic_vector(7 downto 0)   -- valeur s�lectionn�e pour oper2
        );
  end component;

  component Operandes_Register is
    Port(
         clk_i       : in  std_logic;                     -- horloge syst�me
         reset_i     : in  std_logic;                     -- reset asynchrone
         oper_load_i : in  std_logic;                     -- chargement de l'op�rande
         oper_i      : in  std_logic_vector(7 downto 0);  -- valeur � m�moriser
         operande_o  : out std_logic_vector(7 downto 0)   -- valeur m�moris�e
        );
  end component;
  
  component ALU is
    Port(
         operande1_i : in  std_logic_vector(7 downto 0);  -- valeur du 1er  op�rande
         operande2_i : in  std_logic_vector(7 downto 0);  -- valeur du 2eme op�rande
         opcode_i    : in  std_logic_vector(5 downto 0);  -- opcode de l'instruction
         CCR_i       : in  std_logic_vector(3 downto 0);  -- registre de contr�le
         ALU_LSB_o   : out std_logic_vector(7 downto 0);  -- r�sultat LSB de l'op�ration
         ALU_MSB_o   : out std_logic_vector(7 downto 0);  -- r�sultat MSB de l'op�ration
         ZCVN_o      : out std_logic_vector(3 downto 0)   -- nouvel �tat des bits de contr�le
        ); 
  end component; 
   
  component Accu_Register is
    Port(
         clk_i          : in  std_logic;                     -- horloge syst�me
         reset_i        : in  std_logic;                     -- reset asynchrone
         Accu_Save_i    : in  std_logic;                     -- sauvegarde lors d'une interruption
         Accu_Restore_i : in  std_logic;                     -- restaure lors du RTI
         Accu_Load_i    : in  std_logic;                     -- chargement de l'accumulateur � m�moriser
         Accu_i         : in  std_logic_vector(7 downto 0);  -- valeur de l'accumulateur � m�moriser
         Accu_o         : out std_logic_vector(7 downto 0)   -- valeur de l'accumulateur m�moris�e
        );   
  end component; 

  component Status_Register is
    Port(
         clk_i         : in  std_logic;                     -- horloge syst�me
         reset_i       : in  std_logic;                     -- reset asynchrone
         CCR_Save_i    : in  std_logic;                     -- sauvegarde lors d'une interruption
         CCR_Restore_i : in  std_logic;                     -- restaure lors du RTI
         CCR_Load_i    : in  std_logic;                     -- chargement des bits de contr�le
         CCR_i         : in  std_logic_vector(3 downto 0);  -- bits de contr�le � m�moriser
         CCR_o         : out std_logic_vector(3 downto 0)   -- bits de contr�le m�moris�s
        );
  end component;
  
  component Stack_Register is
    Port(
         clk_i        : in  std_logic;                     -- horloge syst�me
         reset_i      : in  std_logic;                     -- reset asynchrone
         Stack_push_i : in  std_logic;                     -- pousse la valeur dans la pile
         Stack_pull_i : in  std_logic;                     -- r�cup�re la derni�re valeur introduite
         Stack_i      : in  std_logic_vector(7 downto 0);  -- valeur � m�moriser
         Stack_o      : out std_logic_vector(7 downto 0)   -- derni�re valeur
        );
  end component;
  

  -- Signaux provenant du registre d'instruction
  signal IR_opcode   : std_logic_vector(5 downto 0);  -- opcode de l'instruction
  signal IR_operande : std_logic_vector(7 downto 0);  -- operande associ� � l'instruction
  
  -- Signaux de gestionnaire d'interruption (interrupt manager)
  signal int_reg : std_logic; -- interruption m�moris�e
  
  -- Signaux provenant du program counter
  signal PC          : std_logic_vector(7 downto 0);  -- valeur du program counter
  signal PC1         : std_logic_vector(7 downto 0);  -- valeur du program counter +1 ou +0
  
  -- Signaux provenant du s�quenceur
  signal int_pulse     : std_logic;
  signal RTI_flag      : std_logic;
  signal PC_inc        : std_logic;
  signal PC_load       : std_logic;
  signal IR_load       : std_logic;
  signal oper_sel      : std_logic_vector(2 downto 0);
  signal oper_load     : std_logic;
  signal Accu_load     : std_logic;
  signal AccuMSB_load  : std_logic;
  signal CCR_load      : std_logic;
  signal PC_stack_push : std_logic; 
  signal PC_stack_pull : std_logic;
   
  -- Signaux provenant du registre CCR
  signal CCR         : std_logic_vector(3 downto 0);

  -- Signaux provenant de registre de l'accumulateur
  signal Accu        : std_logic_vector(7 downto 0);
  signal AccuMSB     : std_logic_vector(7 downto 0);

  -- Signaux provenant des multiplexeurs de s�lection des op�randes
  signal oper1       : std_logic_vector(7 downto 0);      
  signal oper2       : std_logic_vector(7 downto 0);      

  -- Signaux provenant des registres des op�randes
  signal operande1   : std_logic_vector(7 downto 0);      
  signal operande2   : std_logic_vector(7 downto 0); 

  -- Signaux provenant de l'ALU
  signal ALUres      : std_logic_vector(7 downto 0);
  signal ALUresMSB   : std_logic_vector(7 downto 0);
  signal ZCNV        : std_logic_vector(3 downto 0);
  
  -- Signaux provenant de la pile pour le program counter
  signal PC_stack    : std_logic_vector(7 downto 0);

begin

IR_Inst: Instruction_Register
    port map(
         clk_i       => clk_i      , -- horloge syst�me
         reset_i     => reset_i    , -- reset asynchrone
         IR_load_i   => IR_load    , -- chargement du registre d'instruction (impulsion)
         IR_i        => IR_i       , -- instruction     
         int_pulse_i => int_pulse  , -- interruption
         opcode_o    => IR_opcode  , -- opcode de l'instruction
         operande_o  => IR_operande  -- op�rande contenu dans l'instruction
        );


Int_Inst: Interrupt_Manager
    port map(
         clk_i           => clk_i      ,  -- horloge syst�me
         reset_i         => reset_i    ,  -- reset asynchrone
         interrupt_set_i => interrupt_i,  -- interrupt set flanc montant
         interrupt_clr_i => RTI_flag   ,  -- interrupt clear
         interrupt_reg_o => int_reg       -- interrupt m�moris�     
        );

Sequenceur_Inst: Sequenceur
    port map(
             clk_i           => clk_i        , -- horloge syst�me
             reset_i         => reset_i      , -- reset asynchrone
             int_reg_i       => int_reg      , -- interruption   
             int_pulse_o     => int_pulse    , -- interruption en cours de traitement
             RTI_flag_o      => RTI_flag     , -- RTI est trait�e
             opcode_i        => IR_opcode    , -- opcode de l'instruction
             CCR_i           => CCR          , -- �tat actuel du registre de contr�le
             PC_inc_o        => PC_inc       , -- incr�mentation du PC (impulsion)
             PC_load_o       => PC_load      , -- chargement du PC (impulsion)
             PC_stack_push_o => PC_stack_push, -- sauvegarde du PC (impulsion) dans la pile 
             PC_stack_pull_o => PC_stack_pull, -- restaure le PC (impulsion) depuis la pile
             IR_load_o       => IR_load      , -- chargement du registre d'instruction (impulsion)
             oper_sel_o      => oper_sel     , -- bus de s�lection des op�randes
             oper_load_o     => oper_load    , -- chargement de l'op�rande (impulsion)
             Accu_load_o     => Accu_load    , -- chargement de l'accumulateur (impulsion)
             AccuMSB_load_o  => AccuMSB_load , -- chargement de l'accumulateur MSB (impulsion)
             CCR_load_o      => CCR_load     , -- chargement du registre de contr�le (impulsion)
             data_wr_o       => data_wr_o      -- data write pour l'�criture des donn�es (impulsion)
            );
        
        
PC_Inst: Program_Counter
  port map(
           clk_i           => clk_i        , -- horloge syst�me
           reset_i         => reset_i      , -- reset asynchrone
           int_pulse_i     => int_pulse    , -- interruption
           PC_inc_i        => PC_inc       , -- incr�mentation du PC (impulsion)
           PC_load_i       => PC_load      , -- chargement du PC (impulsion)
           addr_i          => IR_operande  , -- adresse � charg�e dans le PC
           PC_stack_pull_i => PC_stack_pull, -- restaure l'adresse provenant de la pile
           PC_stack_i      => PC_stack     , -- adresse provenant de la pile � charg�e dans le PC
           PC_o            => PC           , -- valeur du PC 
           PC1_o           => PC1            -- valeur du PC +1 ou +0
          );


PC_stack_Inst: Stack_Register 
    Port map(
         clk_i        => clk_i        ,  -- horloge syst�me
         reset_i      => reset_i      ,  -- reset asynchrone
         Stack_push_i => PC_stack_push,  -- pousse la valeur dans la pile
         Stack_pull_i => PC_stack_pull,  -- r�cup�re la derni�re valeur introduite
         Stack_i      => PC1          ,  -- valeur du PC +1 ou +0 � m�moriser
         Stack_o      => PC_stack        -- valeur du PC � r�cup�rer
        );
             
                    
Oper_Mux_Inst: Operandes_Multiplexer
    Port map(                         
         sel_i     => oper_sel   , -- bus de s�lection de l'op�rande       
         Accu_i    => Accu       , -- valeur de l'accumulateur  
         AccuMSB_i => AccuMSB    , -- valeur de l'accumulateur MSB           
         const_i   => IR_operande, -- constante contenue dans l'instruction
         data_i    => data_i     , -- valeur provenant d'une adresse       
         oper1_o   => oper1      , -- valeur s�lectionn�e pour oper1                 
         oper2_o   => oper2        -- valeur s�lectionn�e pour oper2       
        );                        
          
          
Oper1_Reg_Inst: Operandes_Register
    Port map(
         clk_i       => clk_i      , -- horloge syst�me
         reset_i     => reset_i    , -- reset asynchrone
         oper_load_i => oper_load  , -- chargement de l'op�rande
         oper_i      => oper1      , -- valeur � m�moriser
         operande_o  => operande1    -- valeur m�moris�e
        );                   
          
          
Oper2_Reg_Inst: Operandes_Register
    Port map(
         clk_i       => clk_i      , -- horloge syst�me
         reset_i     => reset_i    , -- reset asynchrone
         oper_load_i => oper_load  , -- chargement de l'op�rande
         oper_i      => oper2      , -- valeur � m�moriser
         operande_o  => operande2    -- valeur m�moris�e
        );                   
          
          
ALU_Inst: ALU
    Port map(
         operande1_i => operande1, -- valeur du 1er  op�rande
         operande2_i => operande2, -- valeur du 2eme op�rande
         opcode_i    => IR_opcode, -- opcode de l'instruction
         CCR_i       => CCR      , -- registre de contr�le
         ALU_LSB_o   => ALUres   , -- r�sultat LSB de l'op�ration
         ALU_MSB_o   => ALUresMSB, -- r�sultat MSB de l'op�ration
         ZCVN_o      => ZCNV       -- nouvel �tat des bits de contr�le
        );
        
        
Accu_Reg_Inst: Accu_Register
    Port map(
         clk_i           => clk_i    , -- horloge syst�me
         reset_i         => reset_i  , -- reset asynchrone
         Accu_Save_i     => int_pulse, -- sauvegarde lors d'une interruption
         Accu_Restore_i  => RTI_flag , -- restaure lors du RTI
         Accu_Load_i     => Accu_Load, -- chargement de l'accumulateur � m�moriser
         Accu_i          => ALUres   , -- valeur de l'accumulateur � m�moriser
         Accu_o          => Accu       -- valeur de l'accumulateur m�moris�e
        );
        
AccuMSB_Reg_Inst: Accu_Register
   Port map(
        clk_i           => clk_i       , -- horloge syst�me
        reset_i         => reset_i     , -- reset asynchrone
        Accu_Save_i     => int_pulse   , -- sauvegarde lors d'une interruption
        Accu_Restore_i  => RTI_flag    , -- restaure lors du RTI
        Accu_Load_i     => AccuMSB_Load, -- chargement de l'accumulateur � m�moriser
        Accu_i          => ALUresMSB   , -- valeur de l'accumulateur MSB � m�moriser
        Accu_o          => AccuMSB       -- valeur de l'accumulateur MSB m�moris�e
       );
        
Status_Reg_Inst: Status_Register
    Port map(
         clk_i         => clk_i    , -- horloge syst�me
         reset_i       => reset_i  , -- reset asynchrone
         CCR_Save_i    => int_pulse, -- sauvegarde lors d'une interruption
         CCR_Restore_i => RTI_flag , -- restaure lors du RTI
         CCR_Load_i    => CCR_Load , -- chargement des bits de contr�le
         CCR_i         => ZCNV     , -- bits de contr�le � m�moriser
         CCR_o         => CCR        -- bits de contr�le m�moris�s
        );               
        

-- Sorties 
PC_o   <= PC;          -- program counter, adresse pour la ROM
addr_o <= IR_operande; -- adresse pour la RAM ou les PORT
data_o <= Accu;        -- valeur  pour la RAM ou les PORT
    
end Structural;

