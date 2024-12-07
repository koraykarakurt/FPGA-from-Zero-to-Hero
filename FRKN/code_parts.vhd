constant Array_Size: integer := 10;

type array_def is array (0 to Array_Size) of std_logic_vector(15 downto 0);
signal my_array    : array_def;

signal data_in : std_logic_vector(7 downto 0);
-- "data_in" is a name

library MKS;
use MKS.MEASUREMENTS, STD.STANDARD;
-- The name "MEASUREMENTS.VOLTAGE" denotes a named entity declared in
-- a package and the name "STANDARD.all" denotes all named entities
-- declared in a package.

REGISTER_ARRAY(5) -- An element of a one-dimensional array
MEMORY_CELL(1024,7) -- An element of a two-dimensional array

signal R15: BIT_VECTOR (0 to 31);
constant DATA: BIT_VECTOR (31 downto 0);
R15(0 to 7) -- A slice with an ascending range.
DATA(24 downto 1) -- A slice with a descending range.
DATA(1 downto 24) -- A null slice.
DATA(24 to 25) -- An error.

REG'LEFT(1) -- The leftmost index bound of array REG
INPUT_P'PATH_NAME -- The hierarchical path name of
-- the port INPUT_P
CLK'DELAYED(5 ns) -- The signal CLK delayed by 5 ns

wait until RESET = '0';

if condition1 then
target <= delay_mechanism waveform1;
elsif condition2 then
target <= delay_mechanism waveform2;
-- ....
elsif conditionN-1 then
target <= delay_mechanism waveformN-1;
else
target <= delay_mechanism waveformN;
end if;

assert Status = OPEN_OK
  report "The call to FILE_OPEN was not successful"
  severity WARNING;

assert not (S= '1' and R= '1')
  report "Both values of signals S and R are equal to '1'"
  severity ERROR;

assert Operation_Code = "0000"
  report "Illegal Code of Operation"
  severity FAILURE;
  
Count := Count + 1;

if Condition then
  Statements;
elsif Condition then
  Statements;
else
  Statements;
end if;

procedure Proc_3 (X,Y : inout Integer) is
  type Word_16 is range 0 to 65536;
  subtype Byte is Word_16 range 0 to 255;
  variable Vb1,Vb2,Vb3 : Real;
  constant Pi : Real :=3.14;
  procedure Compute (variable V1, V2: Real) is
  begin
    -- subprogram_statement_part
  end procedure Compute;
begin
    -- subprogram_statement_part
end procedure Proc_3;

type SENSOR_STATES is (
  POR_WAIT         , 
  CONFIG_SENSOR    ,
  TAKE_SENSOR_DATA ,
  BFT_WAIT           
);
signal SENSOR_STATE : SENSOR_STATES;
-- ...
  SENSOR_CTRL_P : process (RESET, CLOCK)
  begin
    if (RESET = '1') then 
	  SENSOR_STATE <= POR_WAIT;
	elsif (rising_edge(CLOCK)) then 
	  case SENSOR_STATE is 
	    when POR_WAIT         => 
		-- sequence_of_statements
		when CONFIG_SENSOR    => 
		-- sequence_of_statements
		when TAKE_SENSOR_DATA => 
		-- sequence_of_statements
		when BFT_WAIT         =>
	    -- sequence_of_statements
		when others => 
	  end case;
	end if;
  end process SENSOR_CTRL_P;

for I in 1 to N loop
  Statements;
end loop;

for I in 0 to 7 loop
  if SKIP = '1' then
    next;
  else
    N_BUS <= TABLE(I);
    wait for 5 ns;
  end if;
end loop;

for I in 0 to 7 loop
  if FINISH_LOOP_EARLY = '1' then
    exit;
  else
    A_BUS <= TABLE(I);
    wait for 5 ns;
  end if;
end loop;

subtype my_type2 is std_logic_vector(4 downto 0);
function my_function (a,b : my_type2) return my_type1 is
  begin
  return ( a & b );
end function;

case OPCODE is
  when "001" => TmpData := RegA and RegB;
  when "010" => TmpData := RegA or RegB;
  when "100" => TmpData := not RegA;
  when others => null;
end case;