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
        a, b       : in  integer;
        c, d       : in  integer;  
        result_int : out integer;
        result_real: out integer  
    );
end subprograminstantiationexample;

architecture behavioral of subprograminstantiationexample is
    constant threshold : integer := 10;
begin
    process(a, b, c, d)
        variable tempresultint : integer; --temporary storage
        variable tempresultreal : integer; 
    begin
        if (a > threshold and b > threshold) then
            tempresultint := add_integer(a, b); 
            result_int <= tempresultint;
        else
            result_int <= 0; 
        end if;

        if (c > threshold and d > threshold) then 
            tempresultreal := add_integer(c, d); 
            result_real <= tempresultreal;
        else
            result_real <= 0;
        end if;
    end process;
end behavioral;
