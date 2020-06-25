----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/07/2020 11:00:03 AM
-- Design Name: 
-- Module Name: IPMultMat - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity IPMultMat is
  Port (
    clk_i :in std_logic;
    reset_i : in std_logic;
    CS_i : in std_logic;
    load_i : in std_logic;
    data_i : in std_logic_vector (7 DOWNTO 0);
    addr_i : in std_logic_vector (7 DOWNTO 0);
    
    data_o : out std_logic_vector(7 DOWNTO 0)
   );
end IPMultMat;

architecture Behavioral of IPMultMat is

subtype t_state is std_logic_vector(3 DOWNTO 0);

constant eA1     : t_state	:= "0000";
constant eA2    : t_state	:= "0001";
constant eA3    : t_state	:= "0010";
constant eA4     : t_state	:= "0011";
constant eB1      : t_state	:= "0100";
constant eB2    : t_state	:= "0101";
constant eB3      : t_state	:= "0110";
constant eB4    : t_state	:= "0111";
constant eLoadDone    : t_state	:= "1000";

signal state : t_state;

signal Rs : std_logic_vector (7 DOWNTO 0);
signal RsO : std_logic_vector (7 DOWNTO 0);

signal a1 : std_logic_vector (7 DOWNTO 0);
signal a2 : std_logic_vector (7 DOWNTO 0);
signal a3 : std_logic_vector (7 DOWNTO 0);
signal a4 : std_logic_vector (7 DOWNTO 0);

signal b1 : std_logic_vector (7 DOWNTO 0);
signal b2 : std_logic_vector (7 DOWNTO 0);
signal b3 : std_logic_vector (7 DOWNTO 0);
signal b4 : std_logic_vector (7 DOWNTO 0);

signal c11 : std_logic_vector (7 DOWNTO 0);
signal c12 : std_logic_vector (7 DOWNTO 0);
signal c21 : std_logic_vector (7 DOWNTO 0);
signal c22 : std_logic_vector (7 DOWNTO 0);
signal c31 : std_logic_vector (7 DOWNTO 0);
signal c32 : std_logic_vector (7 DOWNTO 0);
signal c41 : std_logic_vector (7 DOWNTO 0);
signal c42 : std_logic_vector (7 DOWNTO 0);

signal c1 : std_logic_vector (15 DOWNTO 0);
signal c2 : std_logic_vector (15 DOWNTO 0);
signal c3 : std_logic_vector (15 DOWNTO 0);
signal c4 : std_logic_vector (15 DOWNTO 0);


    component Reg
    port (
        clk_i : in std_logic;
        reset_i : in std_logic;
        enable_i : in std_logic;
        data_i : in std_logic_vector (7 DOWNTO 0);
        Rs_i : in std_logic;
        
        data_o : out std_logic_vector (7 DOWNTO 0)
    );
    end component Reg;
  
    component Addr_decode
      port (
          addr_i : in std_logic_vector (7 DOWNTO 0);
          
          Rs_o : out std_logic_vector (7 DOWNTO 0);
          RsO_o : out std_logic_vector (7 DOWNTO 0)
       );
    end component Addr_decode;

    component Mult
    Port ( 
        A1_i : in std_logic_vector (7 DOWNTO 0);
        A2_i : in std_logic_vector (7 DOWNTO 0);
        A3_i : in std_logic_vector (7 DOWNTO 0);
        A4_i : in std_logic_vector (7 DOWNTO 0);
        B1_i : in std_logic_vector (7 DOWNTO 0);
        B2_i : in std_logic_vector (7 DOWNTO 0);
        B3_i : in std_logic_vector (7 DOWNTO 0);
        B4_i : in std_logic_vector (7 DOWNTO 0);
        
        C1_o : out std_logic_vector (15 DOWNTO 0);
        C2_o : out std_logic_vector (15 DOWNTO 0);
        C3_o : out std_logic_vector (15 DOWNTO 0);
        C4_o : out std_logic_vector (15 DOWNTO 0)
    );
    end component Mult;

    component Reg16To8
    Port ( 
        data_i : in std_logic_vector(15 DOWNTO 0);
        
        c1_o : out std_logic_vector (7 DOWNTO 0);
        c2_o : out std_logic_vector (7 DOWNTO 0)
    
    );
    end component Reg16To8;
    
    component MatrixMultiplexer
    Port ( 
        c11_i : in std_logic_vector(7 DOWNTO 0);
        c12_i : in std_logic_vector(7 DOWNTO 0);
        c21_i : in std_logic_vector(7 DOWNTO 0);
        c22_i : in std_logic_vector(7 DOWNTO 0);
        c31_i : in std_logic_vector(7 DOWNTO 0);
        c32_i : in std_logic_vector(7 DOWNTO 0);
        c41_i : in std_logic_vector(7 DOWNTO 0);
        c42_i : in std_logic_vector(7 DOWNTO 0);
        
        Rs_i  : in std_logic_vector(7 DOWNTO 0);
        
        data_o : out std_logic_vector(7 DOWNTO 0)
    
    );
    end component MatrixMultiplexer;
    
begin



decoder: Addr_decode
port map(
    addr_i => addr_i,
    Rs_o => Rs,
    RsO_o => RsO
);

RegA1: Reg
port map(
    clk_i => clk_i,
    reset_i => reset_i,
    enable_i => load_i,
    data_i => data_i,
    Rs_i => Rs(0),
    
    data_o => a1
);
RegA2: Reg
port map(
    clk_i => clk_i,
    reset_i => reset_i,
    enable_i => load_i,
    data_i => data_i,
    Rs_i => Rs(1),
    
    data_o => a2
);
RegA3: Reg
port map(
    clk_i => clk_i,
    reset_i => reset_i,
    enable_i => load_i,
    data_i => data_i,
    Rs_i => Rs(2),
    
    data_o => a3
);
RegA4: Reg
port map(
    clk_i => clk_i,
    reset_i => reset_i,
    enable_i => load_i,
    data_i => data_i,
    Rs_i => Rs(3),
    
    data_o => a4
);
RegB1: Reg
port map(
    clk_i => clk_i,
    reset_i => reset_i,
    enable_i => load_i,
    data_i => data_i,
    Rs_i => Rs(4),
    
    data_o => b1
);
RegB2: Reg
port map(
    clk_i => clk_i,
    reset_i => reset_i,
    enable_i => load_i,
    data_i => data_i,
    Rs_i => Rs(5),
    
    data_o => b2
);
RegB3: Reg
port map(
    clk_i => clk_i,
    reset_i => reset_i,
    enable_i => load_i,
    data_i => data_i,
    Rs_i => Rs(6),
    
    data_o => b3
);
RegB4: Reg
port map(
    clk_i => clk_i,
    reset_i => reset_i,
    enable_i => load_i,
    data_i => data_i,
    Rs_i => Rs(7),
    
    data_o => b4
);

multiplacter: Mult
port map(
    A1_i => a1,
    A2_i  => a2,
    A3_i  => a3,
    A4_i  => a4,
    B1_i  => b1,
    B2_i  => b2,
    B3_i  => b3,
    B4_i  => b4,
    
    C1_o  => c1,
    C2_o  => c2,
    C3_o  => c3,
    C4_o  => c4
);

RegC1: Reg16To8
port map(
    data_i => c1,
    
    c1_o => c11,
    c2_o => c12
);
RegC2: Reg16To8
port map(
    data_i => c2,
    
    c1_o => c21,
    c2_o => c22
);
RegC3: Reg16To8
port map(
    data_i => c3,
    
    c1_o => c31,
    c2_o => c32
);
RegC4: Reg16To8
port map(
    data_i => c4,
    
    c1_o => c41,
    c2_o => c42
);

MM: MatrixMultiplexer
port map(
    c11_i => c11,
    c12_i => c12,
    c21_i => c21,
    c22_i => c22,
    c31_i => c31,
    c32_i => c32,
    c41_i => c41,
    c42_i => c42,
    
    Rs_i  => RsO,
    
    data_o => data_o
);



process(clk_i, reset_i) 
    begin
        if reset_i = '1' then
            state <= eA1;
        elsif (rising_edge(clk_i)) then
            if CS_I = '1' then
                case state is
                    when others =>
                            state <= eA1;
                end case;
            end if;
        end if;

end process;


end Behavioral;
