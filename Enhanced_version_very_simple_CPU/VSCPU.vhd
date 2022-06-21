library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.my_package.all;
entity VSCPU is
generic(
VSCPU_A_WIDTH : integer := 5 ;
VSCPU_D_WIDTH : integer := 8 ;
MEMSIZE : integer := ((2**5)-1) ;
PC_STARTS_AT : std_logic_vector( 4 downto 0) := "00001" );

port(clock,reset,start,rite : in std_logic;
addr : in std_logic_vector( VSCPU_A_WIDTH-1 downto 0);
data : in std_logic_vector(VSCPU_D_WIDTH-1 downto 0);
status : out t_state;
IR: out std_logic_vector(2 downto 0);
DR: out std_logic_vector(7 downto 0);
AC: out std_logic_vector(7 downto 0);
AR: out std_logic_vector(4 downto 0);
Drd: out std_logic_vector(7 downto 0);
PC:  out std_logic_vector(4 downto 0);
memory: out t_memory);
end VSCPU;

architecture behave of VSCPU is
constant INSTR_add : std_logic_vector(2 downto 0) := "000" ; 
constant INSTR_and : std_logic_vector(2 downto 0) := "001" ;
constant INSTR_jmp : std_logic_vector(2 downto 0) := "010" ;
constant INSTR_inc : std_logic_vector(2 downto 0) := "011" ;
constant INSTR_load: std_logic_vector(2 downto 0) := "100" ;
constant INSTR_store: std_logic_vector(2 downto 0) := "101";
constant INSTR_sub:   std_logic_vector(2 downto 0) := "110";
constant INSTR_cjmp: std_logic_vector(2 downto 0) := "111" ;
--type t_state is ( sthalt, ST_FETCH1, ST_FETCH2 , ST_FETCH3, ST_ADD1, ST_ADD2, ST_AND1, ST_AND2, ST_INC1, ST_JMP1,ST_LOAD1,ST_LOAD2,ST_STORE1,ST_STORE2);
signal stvar_ff, stvar_ns : t_state := sthalt  ;


signal mem : t_Memory;
signal wrt : std_logic;
signal rid : std_logic;
signal data_rd : std_logic_vector(7 downto 0) ;
signal address : std_logic_vector(4 downto 0) ;
signal AC_ff   : std_logic_vector(7 downto 0) ; -- Accumulator
signal AR_ff   : std_logic_vector(4 downto 0) ; -- Address register
signal PC_ff   : std_logic_vector(4 downto 0) ; --Program counter
signal DR_ff   : std_logic_vector(7 downto 0) ; --Data register
signal IR_ff   : std_logic_vector(2 downto 0) ; -- Instruction register
signal AC_ns   : std_logic_vector(7 downto 0) ; --Next state values
signal AR_ns   : std_logic_vector(4 downto 0) ;
signal PC_ns   : std_logic_vector(4 downto 0) ;
signal DR_ns   : std_logic_vector(7 downto 0) ;
signal IR_ns   : std_logic_vector(2 downto 0) ;
----signal stvar_ff : std_logic_vector(4 downto 0); 
----signal stvar_ns : std_logic_vector(4 downto 0);

begin
status <= stvar_ff;
address <= addr when (stvar_ff=sthalt) else AR_ff; 

process(clock)
begin
if (clock'event and clock='1') then
   if (reset='1') then
      mem <= (others =>(others=>'0'));
   else
      if (rite ='1' and rid='0') then
           for i in 7 downto 0 loop
              mem(to_integer(unsigned(address)),i)<=data(i);
	        end loop;
	   end if;
		if (wrt= '1' and rite = '0' and rid = '0') then
		   for i in 7 downto 0 loop
			   mem(to_integer(unsigned(AR_ff)),i)<=AC_ff(i); 
			end loop;
		end if;
				
    end if;

end if;
end process;


data_rd(7) <= mem(to_integer(unsigned(address)),7)  when (rid='1' and rite = '0') else 'Z';
data_rd(6) <= mem(to_integer(unsigned(address)),6)  when (rid='1' and rite = '0') else 'Z';
data_rd(5) <= mem(to_integer(unsigned(address)),5)  when (rid='1' and rite = '0') else 'Z';
data_rd(4) <= mem(to_integer(unsigned(address)),4)  when (rid='1' and rite = '0') else 'Z';
data_rd(3) <= mem(to_integer(unsigned(address)),3)  when (rid='1' and rite = '0') else 'Z';
data_rd(2) <= mem(to_integer(unsigned(address)),2)  when (rid='1' and rite = '0') else 'Z';
data_rd(1) <= mem(to_integer(unsigned(address)),1)  when (rid='1' and rite = '0') else 'Z';
data_rd(0) <= mem(to_integer(unsigned(address)),0)  when (rid='1' and rite = '0') else 'Z';



process(clock)
begin
if (clock'event and clock='1') then
   if (reset = '1') then
	    stvar_ff<=sthalt;
	elsif (start='1') then
		   stvar_ff<=ST_FETCH1;
	else
         stvar_ff<=stvar_ns;
end if;
end if;
end process;

process(clock)
begin
if (clock'event and clock='1') then
    if (reset ='1') then
	    AC_ff <= "00000000" ;
       PC_ff <= "00001";
       AR_ff <= "00000" ;
       IR_ff <= "000" ;
       DR_ff <= "00000000" ;
	 else 
	    AC_ff <= AC_ns ;
		 PC_ff <= PC_ns ;
       AR_ff <= AR_ns ; 
       IR_ff <= IR_ns ;
       DR_ff <= DR_ns ;
	 end if;
end if;
end process;

process(stvar_ff)
begin
stvar_ns<=stvar_ff;
case stvar_ff is 
when sthalt => stvar_ns <= sthalt;
when ST_FETCH1 => stvar_ns <= ST_FETCH2;
when ST_FETCH2 => stvar_ns <= ST_FETCH3;
when ST_FETCH3 => 
case IR_ff is
    when INSTR_add => stvar_ns <= ST_ADD1;
    when INSTR_and => stvar_ns <= ST_AND1;
    when INSTR_jmp => stvar_ns <= ST_JMP1 ;
    when INSTR_inc => stvar_ns <= ST_INC1 ;
	 when INSTR_load => stvar_ns <= ST_LOAD1;
	 when INSTR_store => stvar_ns <= ST_STORE1;
	 when INSTR_sub => stvar_ns <= ST_SUB1;
	 when INSTR_cjmp => stvar_ns <= ST_CJMP1;
	 when others => null;
end case;

when ST_ADD1 => stvar_ns <= ST_ADD2;
when ST_AND1=> stvar_ns <= ST_AND2;
when ST_JMP1 => stvar_ns <= ST_FETCH1;
when ST_INC1 => stvar_ns <= ST_FETCH1;
when ST_ADD2 => stvar_ns <= ST_FETCH1;
when ST_AND2 => stvar_ns <= ST_FETCH1;
when ST_LOAD1 => stvar_ns <= ST_LOAD2;
when ST_LOAD2 => stvar_ns <= ST_FETCH1;
when ST_STORE1 => stvar_ns <= ST_FETCH1;
when ST_SUB1 => stvar_ns <= ST_SUB2;
when ST_SUB2 => stvar_ns <= ST_FETCH1;
when ST_CJMP1 => stvar_ns <= ST_FETCH1;
when others => null;
end case;
 
end process;

process(stvar_ff)
begin
if ( ( stvar_ff = ST_FETCH2) or ( stvar_ff = ST_ADD1) or( stvar_ff = ST_AND1) or( stvar_ff = ST_LOAD1 ) or( stvar_ff = ST_SUB1)) then
    rid <= '1' ;
else
    rid <= '0' ;
end if;
end process;


process(stvar_ff)
begin
if ( ( stvar_ff = ST_STORE1)) then
    wrt <= '1' ;
else
    wrt <= '0' ;
end if;
end process;


process (AR_ff,PC_ff,DR_ff,IR_ff,AC_ff,stvar_ff,data_rd,DR_ns)
begin
AR_ns <= AR_ff ; 
PC_ns <= PC_ff ;
DR_ns <= DR_ff ;
IR_ns <= IR_ff ;
AC_ns <= AC_ff ;
case stvar_ff is
when ST_FETCH1 => AR_ns <= PC_ff ;
when ST_FETCH2 =>
         PC_ns <= std_logic_vector(unsigned(PC_ff) + 1 ); 
			DR_ns <= data_rd ;
         IR_ns <= DR_ns(7 downto 5);
         AR_ns <= DR_ns(4 downto 0);

when ST_FETCH3 => null;
when ST_ADD1 => DR_ns <= data_rd ;
when ST_ADD2 => AC_ns <= std_logic_vector(unsigned(AC_ff) + unsigned(DR_ff)) ;
when ST_AND1 => DR_ns <= data_rd ;
when ST_AND2 => AC_ns <= AC_ff and DR_ff ;
when ST_JMP1 => PC_ns <= DR_ff(4 downto 0);
when ST_INC1 => AC_ns <= std_logic_vector(unsigned(AC_ff) + 1) ;
when ST_LOAD1 => DR_ns <= data_rd;
when ST_LOAD2 => AC_ns <= DR_ff;
when ST_STORE1 =>AR_ns <= DR_ff(4 downto 0);
when ST_SUB1 => DR_ns <= data_rd ;
when ST_SUB2 => AC_ns <= std_logic_vector(unsigned(AC_ff)-unsigned(DR_ff)) ;
when ST_CJMP1 => if(AC_ff(7)='1') then PC_ns <= DR_ff(4 downto 0); end if;
when others => null;
end case;
end process;

process(clock)
begin
if(clock'event and clock='1')then
  if(stvar_ff=ST_FETCH1)then
     report "-------------> AC = " & integer'image(to_integer(unsigned(AC_ff)));
  end if;
end if;
end process;


process(clock)
begin

report "clk=" & std_logic'image(clock);
report "rst=" & std_logic'image(reset);
report "start=" & std_logic'image(start);
report "write=" & std_logic'image(rite);
report "pc=" & integer'image(to_integer(unsigned(PC_ff)));
report "cstate=" & t_state'image(stvar_ff);
report "ac=" & integer'image(to_integer(unsigned(AC_ff)));
report "ir=" & integer'image(to_integer(unsigned(IR_ff)));
report "dr=" & integer'image(to_integer(unsigned(DR_ff)));
report "ar=" & integer'image(to_integer(unsigned(AR_ff)));
report "data_rd=" & integer'image(to_integer(unsigned(data_rd)));
report "read=" & std_logic'image(rid);
report "address=" & integer'image(to_integer(unsigned(address)));
end process;
AR <= AR_ff;
AC <= AC_ff;
DR <= DR_ff;
IR <= IR_ff;
Drd <= data_rd;
PC <= PC_ff;
memory <= mem;
end behave;