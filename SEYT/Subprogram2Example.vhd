library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

function Add(a, b: INTEGER) return INTEGER is
begin
    return a + b;
end Add;

function Add(a, b: REAL) return REAL is
begin
    return a + b;
end Add;

function PositiveAdd is new Add;

entity SubprogramInstantiationExample is
    Port (
        a, b       : in  INTEGER;
        c, d       : in  REAL;
        result_int : out INTEGER;
        result_real: out REAL
    );
end SubprogramInstantiationExample;

architecture Behavioral of SubprogramInstantiationExample is
    constant THRESHOLD : INTEGER := 10;
begin
    process(a, b, c, d)
        variable tempResultInt : INTEGER;
        variable tempResultReal : REAL;
    begin
        if (a > THRESHOLD and b > THRESHOLD) then
            tempResultInt := PositiveAdd(a, b);
            result_int <= tempResultInt;
        else
            result_int <= 0; 
        end if;

        if (c > REAL(THRESHOLD) and d > REAL(THRESHOLD)) then
            tempResultReal := Add(c, d);
            result_real <= tempResultReal;
        else
            result_real <= 0.0;
        end if;
    end process;
end Behavioral;
