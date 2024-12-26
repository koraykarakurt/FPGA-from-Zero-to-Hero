--Created by Mert Ecevit(mertecevit-ops)

--DECLARATIONS EXAMPLES
--Type declarations
type boolean is (false, true);
type bit_vector is array (7 downto 0) of bit;

--Subtype declarations
subtype my_vector is std_logic_vector (3 downto 0);
subtype word is unsigned(15 downto 0);

--Object declarations
constant loop_number : integer := 7;    --constant declaration
signal sum, carry1, carry2 : bit;       --signal declaration
variable Carry: STD_LOGIC := '0';       --variable declaration

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
constant tc : time := 2.5 ns ;
alias delay : time IS tc ;


--attribute declarations
type T is (A, B, C, D, E);
subtype S is T range D downto B;
S'left = D
S'right = B
S'low = B
S'high = D
S'base'left = A
T'ascending = TRUE
S'ascending = FALSE
T'image(A) = "a"
T'value("E") = E
T'pos(A) = 0
S'pos(B) = 1
T'val(4) = E
S'succ(B) = C
S'pred(C) = B
S'leftof(B) = C
S'rightof(C) = B

signal A: std_logic_vector(7 downto 0);
A'left = 7
A'right = 0
A'low = 0
A'high = 7
A'range = 7 downto 0
A'reverse_range = 0 to 7
A'length = 8
A'ascending = FALSE

--component declarations
component mux4
    port (sel, A, B, C, D: in  V2;
          F              : out V2);
end component;

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
