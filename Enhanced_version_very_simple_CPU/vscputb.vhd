---------------------------------
---------------------------------

library ieee ; use ieee.std_logic_1164.all ;
use work.my_package.all;

entity vscputb is end entity ;
architecture stim of vscputb is 

  constant INSTR_add : std_logic_vector( 2 downto 0 ) := "000" ;
  constant INSTR_and : std_logic_vector( 2 downto 0 ) := "001" ;
  constant INSTR_jmp : std_logic_vector( 2 downto 0 ) := "010" ;
  constant INSTR_inc : std_logic_vector( 2 downto 0 ) := "011" ;
  constant INSTR_load: std_logic_vector(2 downto 0)   := "100" ;
  constant INSTR_store: std_logic_vector(2 downto 0)  := "101" ;
  constant INSTR_sub: std_logic_vector(2 downto 0)    := "110" ;
  constant INSTR_cjmp: std_logic_vector(2 downto 0)   := "111" ;

  constant A_WIDTH : integer := 5 ; 
  constant D_WIDTH : integer := 8 ;
  
  signal clk , reset , start , write_en : std_logic ;
  signal addr : std_logic_vector( A_WIDTH-1 downto 0 ) ; 
  signal data : std_logic_vector ( D_WIDTH-1 downto 0 ) ;
  signal status : t_state ;
  signal IR:std_logic_vector(2 downto 0);
  signal DR:std_logic_vector(7 downto 0);
  signal AC:std_logic_vector(7 downto 0);
  signal AR:std_logic_vector(4 downto 0);
  signal Drd:std_logic_vector(7 downto 0);
  signal PC:std_logic_vector(4 downto 0);
  signal memory: t_memory;

  procedure do_synch_active_high_half_pulse ( 
      signal formal_p_clk : in std_logic ; 
      signal formal_p_sig : out std_logic 
    ) is
  begin
    wait until formal_p_clk='0' ;  formal_p_sig <= '1' ;
    wait until formal_p_clk='1' ;  formal_p_sig <= '0' ;
  end procedure ;

  procedure do_program ( 
      signal formal_p_clk : in std_logic ; 
      signal formal_p_write_en : out std_logic ; 
      signal formal_p_addr_out , formal_p_data_out : out std_logic_vector ;
      formal_p_ADDRESS_in , formal_p_DATA_in : in std_logic_vector     
    ) is
  begin
    wait until formal_p_clk='0' ;  formal_p_write_en <= '1' ;
    formal_p_addr_out <= formal_p_ADDRESS_in ; 
    formal_p_data_out <= formal_p_DATA_in ;
    wait until formal_p_clk='1' ;  formal_p_write_en <='0' ;
  end procedure ;

begin

  dut_vscpu : entity work.VSCPU( behave )
      port map ( clock => clk , reset => reset , start => start ,
             rite => write_en , addr => addr  , data => data , status => status, IR => IR, DR => DR, AC =>AC,
				 AR => AR,Drd => Drd,PC => PC, memory => memory) ;
             
  process begin
    clk <= '0' ;
    for i in 0 to 99 loop 
      wait for 1 ns ; clk <= '1' ;  wait for 1 ns ; clk <= '0';--------------1ns
    end loop ;
    wait ;
  end process ;

  
  process begin
    reset <= '0' ;  start <= '0' ; write_en <= '0' ;
    addr <= "00000" ;  data <= "00000000" ;
    do_synch_active_high_half_pulse ( clk, reset ) ; -- acc=0
    do_program ( clk, write_en, addr, data, "00001" , INSTR_add & "0" & "1001"  ) ; 
    -- LABEL1 acc += mem [ 9 ]
    do_program ( clk, write_en, addr, data, "00010" , INSTR_and & "0" & "1010"  ) ; 
    -- acc &= mem [ 10 ]
    do_program ( clk, write_en, addr, data, "00011" , INSTR_inc & "0" & "0000"  ) ; 
    -- acc += 1
    do_program ( clk, write_en, addr, data, "00100" , INSTR_jmp & "0" & "0101"  ) ; 
    -- jmp to 00101
	 do_program ( clk, write_en, addr, data, "00101" , INSTR_LOAD & "0" & "1011"  ) ;
	 -- load from mem[11]
	 
	 do_program ( clk, write_en, addr, data, "00110" , INSTR_STORE & "0" & "1100"  ) ;
	 --store at mem[12]
	 do_program ( clk, write_en, addr, data, "00111" , INSTR_SUB & "0" & "1101"  ) ;
	 -- acc- = mem[13]
	 do_program ( clk, write_en, addr, data, "01000" , INSTR_cjmp & "0" & "0001"  ) ;
	 
    do_program ( clk, write_en, addr, data, "01001" , X"27"  ) ; -- mem[ 9 ]
    do_program ( clk, write_en, addr, data, "01010" , X"39"  ) ; -- mem[ 10 ]
	 do_program ( clk, write_en, addr, data, "01011" , X"44"  ) ; -- mem[ 11 ]
	 do_program ( clk, write_en, addr, data, "01101" , X"46"  ) ; -- mem[ 13 ]
    do_synch_active_high_half_pulse ( clk, start ) ; 
    wait ;
  end process ;
end architecture ;
