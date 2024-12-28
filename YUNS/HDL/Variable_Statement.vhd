library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Variable_Statement is
end entity;

architecture sim of Variable_Statement is

    signal MySignal : integer := 0;

begin
    process
        variable MyVariable : integer := 0;
    begin

        MyVariable := MyVariable + 1;
        MySignal   <= MySignal + 1;

        report "MyVariable=" & integer'image(MyVariable) &
            ", MySignal=" & integer'image(MySignal);

        wait for 10ns;
    end process;

end architecture;