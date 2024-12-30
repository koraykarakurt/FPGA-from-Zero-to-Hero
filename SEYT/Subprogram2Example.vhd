library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package my_subprograms is
    function add_integer(a, b: integer) return integer;
end my_subprograms;

package body my_subprograms is
    function add_integer(a, b: integer) return integer is
    begin
        return a + b;
    end add_integer;
end my_subprograms;

use work.my_subprograms.all;

entity subprograminstantiationexample is
    port (
        a_in, b_in       : in  integer;
        c_in, d_in       : in  integer;  
        result_int : out integer;
        result_real: out integer  
    );
end subprograminstantiationexample;
architecture behavioral of subprograminstantiationexample is
    constant threshold : integer := 10;
begin
    process(a_in, b_in, c_in, d_in)
        variable tempresultint : integer; --temporary storage
        variable tempresultreal : integer; 
    begin
        if (a_in > threshold and b_in > threshold) then
            tempresultint := add_integer(a_in, b_in); 
            result_int <= tempresultint;
        else
            result_int <= 0; 
        end if;

        if (c_in > threshold and d_in > threshold) then 
            tempresultreal := add_integer(c_in, d_in); 
            result_real <= tempresultreal;
        else
            result_real <= 0;
        end if;
    end process;
end behavioral;
