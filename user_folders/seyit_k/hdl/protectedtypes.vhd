library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

protected type sharedcounter is
  procedure increment;
  function getvalue return integer;
end protected;

protected body sharedcounter is
  variable count: integer := 0;
  procedure increment is
  begin
    count := count + 1;
  end procedure;
  function getvalue return integer is
  begin
    return count;
  end function;
end protected body;

entity protectedtypes is
  port (
    clk : in std_logic;
    out_counter : out integer
  );
end protectedtypes;

architecture behavior of protectedtypes is
  shared variable counter: sharedcounter;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      counter.increment;
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      out_counter <= counter.getvalue;
    end if;
  end process;
end behavior;
