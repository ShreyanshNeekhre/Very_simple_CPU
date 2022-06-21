library ieee;
use ieee.std_logic_1164.all;

package my_package is
type t_state is ( sthalt, ST_FETCH1, ST_FETCH2 , ST_FETCH3, ST_ADD1, ST_ADD2, ST_AND1, ST_AND2, ST_INC1, ST_JMP1,ST_LOAD1,ST_LOAD2,ST_STORE1,ST_SUB1,ST_SUB2,ST_CJMP1);
type t_Memory is array (31 downto 0, 7 downto 0) of std_logic;
end my_package;