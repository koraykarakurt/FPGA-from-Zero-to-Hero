--Created by Mert Ecevit(mertecevit-ops)

--DECLARATIONS EXAMPLES
--Type declarations
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package custom is
    type boolean is (false, true);
    type bit_vector is array (7 downto 0) of bit; --type declarations

    subtype my_vector is std_logic_vector (3 downto 0);
    subtype word is unsigned(15 downto 0); --subtype declarations
end package custom;

entity example is
    Port (
        clk : in std_logic;
        reset : in std_logic;
        result : out std_logic
    );
end example;

architecture bhv of example is
    -- Constant declaration
    constant loop_number : integer := 7;
    -- Signal declarations
    signal sum, carry1, carry2 : bit := '0';
    -- Variable declaration (used in a process)
    signal Carry : std_logic := '0';
begin
    process(clk, reset)
        variable temp_result : std_logic := '0';
    begin
        if reset = '1' then
            sum <= '0';
            carry1 <= '0';
            carry2 <= '0';
            Carry <= '0';
            temp_result := '0';
            result <= '0';
        elsif rising_edge(clk) then
            for i in 0 to loop_number loop
                if i mod 2 = 0 then
                    Carry <= '1';
                    temp_result := Carry;
                else
                    Carry <= '0';
                    temp_result := Carry;
                end if;
            end loop;
            sum <= '1';
            carry1 <= bit(Carry);
            carry2 <= '1';
            result <= temp_result;
        end if;
    end process;
end bhv;


--interface declarations
type Axi4LiteWriteAddressType is record
  AWAddr     : std_logic_vector ;
  AWProt     : std_logic_vector ;
  AWValid    : std_logic ;
  AWReady    : std_logic ;
end record Axi4LiteWriteAddressType ; --encapsulation

view Axi4LiteWriteAddressMasterView of Axi4LiteWriteAddressType is
    AWAddr     : out ;
    AWProt     : out ;
    AWValid    : out ;
    AWReady    : in ;
  
end view Axi4LiteWriteAddressMasterView ; -- a view declaration for the mode replacement

AxiMaster1     : view Axi4LiteMasterView ;
AxiMaster2     : view Axi4LiteMasterView of Axi4LiteType ;
AxiResponder1  : view Axi4LiteResponderView ;
AxiResponder2  : view Axi4LiteResponderView ;  --Use the interface in an entity declaration

--alias declaration
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TimingExample is
    Port (
        clk : in std_logic;
        reset : in std_logic;
        signal_in : in std_logic;
        signal_out : out std_logic
    );
end TimingExample;

architecture Behavioral of TimingExample is
    -- Constant declaration
    constant tc : time := 2.5 ns;
    -- Alias declaration
    alias delay : time is tc;
begin
    process(clk, reset)
    begin
        if reset = '1' then
            signal_out <= '0' after delay;
        elsif rising_edge(clk) then
            signal_out <= signal_in after delay;
        end if;
    end process;
end Behavioral;



--attribute declarations
library ieee;
use ieee.std_logic_1164.all;

package My_Types is
    type T is (A, B, C, D, E);
    subtype S is T range D downto B;
end package My_Types;

entity Attribute_Example is
    port (
        input_A : in  std_logic_vector(7 downto 0);
        input_B : in  std_logic_vector(7 downto 0);
        result  : out std_logic_vector(15 downto 0)
    );
end Attribute_Example;

architecture Behavioral of Attribute_Example is
    use work.My_Types.all;
    signal signal_A : std_logic_vector(7 downto 0);
    signal signal_B : std_logic_vector(7 downto 0);
    signal product  : std_logic_vector(15 downto 0);
    signal my_enum  : S := D;  
begin
    process
    begin
        signal_A <= input_A;
        signal_B <= input_B;
        product <= std_logic_vector(unsigned(signal_A) * unsigned(signal_B));
        product(product'left) <= '1'; 
        wait;
    end process;
end Behavioral;



--component declarations
library IEEE;
use IEEE.std_logic_1164.all;

entity component_instantiation is
  port     (add1, add2: in integer;
            sum_1: out integer);
  end;
  architecture example of component_instantiation is
  component adder is
  port     (a, b: in integer;
            sum: out integer);
  end component;
  begin
  component_inst: adder_component
  port map (a => add1
            b => add2,
            sum => sum);
end example;


--Group declarations

architecture RTL of Ent is
    group operations is (signal <>);
    group adders: operations (x, y, z);
  begin
    a1: x <= a + b;
    a2: y <= c + d;
    a3: z <= e + f;
end architecture RTL;

--Expressions examples


--Concurrent statements examples
--block statement
architecture rtl of dsp is
  ...
 begin
  mac_unit: block
  port (a, b: in float32; mac_out: out float32);
  port map (a = > x, b = > y, mac_out = > acc);
  signal multiplier_out: float32;
  signal adder_out: float32 ;

  begin
    multiplier_out <= a * b;
    adder_out <= multiplier_out + mac_out;
    process (clock, reset) begin
      if reset then
        mac_out <= ( others = > '0');
      elsif rising_edge(clock) then
        mac_out <= adder_out;
      end if ;
    end process ;
  end block ;
    ...
end architecture rtl;

--process example
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity D_FF is
  port( d,clk: in std_logic;
  q: out std_logic);
  end D_FF;
   
  architecture bhv of D_FF is
  begin
  process(clk)
  begin
  if rising_edge(clk) then
    Q <= D;
  end if;
end process;
end bhv;

-- concurrent procedure call
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity adder is
  port (a, b: in integer;
        sum: out integer);
  end adder;
architecture behavior of adder is
  begin
    sum <= a + b;
end;

architecture bhv of adder is
  procedure add(a, b: in integer;
          signal sum: out integer) is begin
    sum <= a + b;
    end;
begin
  adder_component : adder port map (add1, add2, sum1);
  adder_procedure : add(add1, add2, sum2),
end architecture bhv;
--equivalent statements
architecture sensitiviy_list of adder is
begin
  process(add1, add2)
  begin
    add(add1, add2, sum2);
  end process;
end architecture; --sensitivity list

architecture wait_statement of adder is
  begin
    process
    begin
      add(add1, add2, sum2);
      wait on add1, add2;
    end process;
end wait_statement; --wait statement     this sensitivity list and wait statement are equivalent each other


--Concurrent assertion statement
library IEEE;
use IEEE.IEEE.std_logic_1164.all;
use IEEE._std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity tb_address_check is
end tb_address_check;

architecture behavior of tb_address_check is
    signal address : STD_LOGIC_VECTOR(31 downto 0);
    component address_check
        Port ( address : in STD_LOGIC_VECTOR(31 downto 0));
    end component;
begin
    uut: address_check Port map (address => address);

    stim_proc: process
    begin
        address <= x"0000_1234"; wait for 10 ns; 
        address <= x"9000_1234"; wait for 10 ns; 
        address <= x"4000_0000"; wait for 10 ns; 
        address <= x"1000_0000"; wait for 10 ns; 
        wait;
    end process;
    -- Concurrent assertion
    assert (to_integer(unsigned(address)) < x"1000_0000" or to_integer(unsigned(address)) >= x"8000_0000")
    report "Invalid access at address " & to_string(address)
    severity warning;
end behavior;


--Concurrent signal assignment
library IEEE;
use IEEE.IEEE.std_logic_1164.all;

entity add_1 is
  port ( a, b, cin: in bit;
         s, cout: out bit);
 end add_1;
 architecture concurrent of add_1 is
  signal s1, s2, s3, s4: bit;
 begin
        s1 <= b xor cin;
        s2 <= a and b;
        s3 <= a and cin;
        s4 <= b and cin;
        s <= a xor s1;
        cout <= s2 or s3 or s4;
 end concurrent;

--component instantiation
--same example as component example

--entity instantiation statements
entity WORK.X (Y) port map (P1 => S1, P2 => S2);


--generate statements
entity full_adder1 is
  Port (a        : in std_logic;
        b        : in std_logic;
        carry_in : in std_logic;
        sum      : out std_logic;
        carry_out: out std_logicr);
end full_adder1;

--full code
library IEEE;
use IEEE.IEEE.std_logic_1164.all;
use IEEE._std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

architecture structural of adder is
  signal carry_in_vector: std_logic_vector( 0 to WIDTH- 1);
  signal carry_out_vector: std_logic_vector( 0 to WIDTH- 1);
  begin
    instantiate_adders: for i in 0 to WIDTH- 1 generate --generate statement and entity instantiation
    adder_bit: entity work.full_adder1
    port map (a = > a(i), b = > b(i), carry_in = > carry_in_vector(i),
    sum = > sum(i), carry_out = > carry_out_vector(i));
  end generate ;
  carry_in_vector <= (carry_in, carry_out_vector( 0 to WIDTH- 2));
  carry_out <= carry_out_vector(WIDTH- 1);
 end structural;