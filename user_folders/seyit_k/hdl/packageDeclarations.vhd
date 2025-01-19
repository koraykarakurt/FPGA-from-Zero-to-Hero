library IEEE;
use IEEE.std_logic_1164.all;

package mypackage is
    constant default_value: integer := 10; 
    function double(value: integer) return integer; 
    function triple(value: integer) return integer; 
end package mypackage;

package body mypackage is
    function double(value: integer) return integer is
    begin
        return value * 2; 
    end function double;

    function triple(value: integer) return integer is
    begin
        return value * 3; 
    end function triple;
end package body mypackage;

entity packageexample is
    port (
        inputvalue  : in integer;
        outputvalue : out integer;
        triplevalue : out integer
    );
end packageexample;

architecture behavioral of packageexample is
    use work.mypackage.all; 
begin
    process(inputvalue)
    begin
        outputvalue <= double(inputvalue); 
        triplevalue <= triple(inputvalue); 
    end process;
end behavioral;

