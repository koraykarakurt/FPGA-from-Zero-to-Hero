--============================================================================
-- Generic Multiplier Entity
--============================================================================
-- Description: Configurable signed/unsigned multiplier with parametric width
-- Generics:
--   MULT_TYPE - '0' = unsigned, '1' = signed
--   WIDTH     - Bit width of input operands (default 8-bit)
-- Ports:
--   a      - Input operand 1 (WIDTH-bit)
--   b      - Input operand 2 (WIDTH-bit)
--   result - Output product (2*WIDTH-bit)
-- Author : Mustafa Yetis
--Revision History:
--30.01.2025 - Created Initial code
--============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity generic_multiplier is
   generic (
      MULT_TYPE : std_logic := '0';  -- Multiplication type selector
      WIDTH     : positive := 8      -- Operand bit width
   );
   port (
      a      : in  std_logic_vector(WIDTH-1 downto 0);
      b      : in  std_logic_vector(WIDTH-1 downto 0);
      result : out std_logic_vector(2*WIDTH-1 downto 0)
   );
end entity generic_multiplier;

architecture rtl of generic_multiplier is
begin

   ----------------------------------------------------------------------------
   -- Unsigned Multiplication Block
   ----------------------------------------------------------------------------
   unsigned_gen: if MULT_TYPE = '0' generate
      signal a_unsigned : unsigned(WIDTH-1 downto 0);
      signal b_unsigned : unsigned(WIDTH-1 downto 0);
   begin
      a_unsigned <= unsigned(a);
      b_unsigned <= unsigned(b);
      result     <= std_logic_vector(a_unsigned * b_unsigned);
   end generate unsigned_gen;

   ----------------------------------------------------------------------------
   -- Signed Multiplication Block
   ----------------------------------------------------------------------------
   signed_gen: if MULT_TYPE = '1' generate
      signal a_signed : signed(WIDTH-1 downto 0);
      signal b_signed : signed(WIDTH-1 downto 0);
   begin
      a_signed <= signed(a);
      b_signed <= signed(b);
      result   <= std_logic_vector(a_signed * b_signed);
   end generate signed_gen;

end architecture rtl;