library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

function add(a, b: integer) return integer is
begin
    return a + b;
end add;

function add(a, b: real) return real is
begin
    return a + b;
end add;

function positiveadd is new add;

entity subprograminstantiationexample is
    port (
        a, b       : in  integer;
        c, d       : in  real;
        result_int : out integer;
        result_real: out real
    );
end subprograminstantiationexample;

architecture behavioral of subprograminstantiationexample is
    constant threshold : integer := 10;
begin
    process(a, b, c, d)
        variable tempresultint : integer;
        variable tempresultreal : real;
    begin
        if (a > threshold and b > threshold) then
            tempresultint := positiveadd(a, b);
            result_int <= tempresultint;
        else
            result_int <= 0; 
        end if;

        if (c > real(threshold) and d > real(threshold)) then
            tempresultreal := add(c, d);
            result_real <= tempresultreal;
        else
            result_real <= 0.0;
        end if;
    end process;
end behavioral;
