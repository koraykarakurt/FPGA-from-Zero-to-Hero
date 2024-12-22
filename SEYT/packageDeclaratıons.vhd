library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package MyPackage is
    constant DEFAULT_VALUE: integer := 10; 
    function Double(Value: integer) return integer; 
    function Triple(Value: integer) return integer; 
end package MyPackage;

package body MyPackage is
    function Double(Value: integer) return integer is
    begin
        return Value * 2; 
    end function Double;

    function Triple(Value: integer) return integer is
    begin
        return Value * 3; 
    end function Triple;
end package body MyPackage;

entity PackageExample is
    Port (
        InputValue  : in integer;
        OutputValue : out integer;
        TripleValue : out integer
    );
end PackageExample;

architecture Behavioral of PackageExample is
    use work.MyPackage.all; 
begin
    process(InputValue)
    begin
        OutputValue <= Double(InputValue); 
        TripleValue <= Triple(InputValue); 
    end process;
end Behavioral;
