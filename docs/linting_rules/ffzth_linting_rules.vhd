---------------------------------------------------------------------------------------------------
-- Author      : Koray Karakurt
-- Description : generic_multiplier written as linting rule example template (ffzth_linting_rules.vhd)
--   
--   
--   
-- More information (optional) :
--    
--    
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ffzth_linting_rules is
   generic (
      MULT_TYPE   : std_logic              := '0'; -- '0': unsigned, '1': signed
      RESET_TYPE  : std_logic              := '0'; -- '0': synchronous, '1': asynchronous (asynchronous option assumes that reset de-assertion is done outside of this block)
      BIT_WIDTH   : natural range 2 to 256 :=  8   -- min value is 2, max value is 256
   );
   port (
      clk_400mhz  : in  std_logic;
      rst_400mhz  : in  std_logic;                                 -- active high reset input in clk_400mhz domain
      mult_1      : in  std_logic_vector(BIT_WIDTH - 1 downto 0);  -- multiplier 1 in clk_400mhz domain
      mult_2      : in  std_logic_vector(BIT_WIDTH - 1 downto 0);  -- multiplier 2 in clk_400mhz domain
      mult_result : out std_logic_vector(2*BIT_WIDTH - 1 downto 0) := (others => '0')
   );
end ffzth_linting_rules;

architecture behavioral of ffzth_linting_rules is
   -- below "constants, enumerated type definition and signals" are not used in the design but provided as examples
   -- so it conflicts with our fzth_linting_rules.docx "Remove signals and variables that are never written or read, and delete them"
   type ENUM_STATE is (IDLE, WAIT_TRIGGER, CHECK_HEADER, SEND_DATA, RECEIVE_DATA, CHECK_CRC)
   constant ERROR_COUNTER_WIDTH : integer := 32 ; 
   constant UPPER_THRESHOLD : integer := 2000 ; 
   constant LOWER_THRESHOLD : integer := -1928; 
   signal my_state : ENUM_STATE := IDLE;
   signal error_counter : unsigned (ERROR_COUNTER_WIDTH - 1 downto 0) := (others => '0');
begin
   -- signed multiplication and synchronous reset section
   signed_synchronous_gen : if MULT_TYPE = '1' and RESET_TYPE = '0' generate 
      process(clk_400mhz)
      begin
         if rising_edge(clk_400mhz) then
            if rst_400mhz = '1' then
               mult_result <= (others => '0');
            else 
               mult_result <= std_logic_vector(signed(mult_1) * signed(mult_2));
            end if;
         end if;
      end process;
   end generate signed_synchronous_gen;
   -- unsigned multiplication and synchronous reset section
   unsigned_synchronous_gen : if MULT_TYPE = '0' and RESET_TYPE = '0' generate  
      process(clk_400mhz)
      begin
         if rising_edge(clk_400mhz) then
            if rst_400mhz = '1' then
               mult_result <= (others => '0');
            else 
               mult_result <= std_logic_vector(unsigned(mult_1) * unsigned(mult_2));
            end if;
         end if;
      end process;
   end generate unsigned_synchronous_gen;
   -- signed multiplication and asynchronous reset section
   signed_asynchronous_gen : if MULT_TYPE = '1' and RESET_TYPE = '1' generate
      process(clk_400mhz,rst_400mhz)
      begin
         if rst_400mhz = '1' then 
            mult_result <= (others => '0');
         elsif rising_edge(clk_400mhz) then
            mult_result <= std_logic_vector(signed(mult_1) * signed(mult_2));
         end if;
      end process;
   end generate signed_asynchronous_gen;
   -- unsigned multiplication and asynchronous reset section
   unsigned_asynchronous_gen : if MULT_TYPE = '0' and RESET_TYPE = '1' generate  
      process(clk_400mhz,rst_400mhz)
      begin
         if rst_400mhz = '1' then 
            mult_result <= (others => '0');
         elsif rising_edge(clk_400mhz) then
            mult_result <= std_logic_vector(unsigned(mult_1) * unsigned(mult_2));
         end if;
      end process;
   end generate unsigned_asynchronous_gen;
end behavioral;
