---------------------------------------------------------------------------------------------------
-- Author : Abdullah Furkan Kaya
-- Description : Transposed FIR Filter design
--   
--   
--  
-- More information (optional) :
-- 
-- TO DO:
--   1 -> What should be the width of output? How this output should be assigned with the last sum? Because we are adding bunch of numbers
--   2 -> Make coeff_len generic more usable if filter coefficients has fixed length remove this generic. coefficients constant array could be DYNAMIC array
--   3 -> Overflow underflow issue should be solved with the pattern detector logic
--    
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.gfir_transposed_pkg.all;

entity gfir_transposed is
   generic (
      filter_taps   : integer range 0 to 20 :=  5; -- filter order
      input_len     : integer range 0 to 25 := 24; -- filter input  length
      coeff_len     : integer range 0 to 18 := 16; -- filter coefficient length  
      output_len    : integer range 0 to 48 := 24  -- filter output length
   );
   port (
      clock         : in  std_logic;                                            -- system clock
      reset         : in  std_logic;                                            -- synchronous active-high reset
      data_in       : in  std_logic_vector(input_len  - 1 downto 0);            -- filter's input
      valid_in      : in  std_logic;                                            -- valid indicator of the filter's input  | if '1' input  of the filter is valid else invalid
      data_out      : out std_logic_vector(input_len + coeff_len - 1 downto 0); -- filter's output
      valid_out     : out std_logic                                             -- valid indicator of the filter's output | if '1' output of the filter is valid else invalid
   );
end gfir_transposed;

architecture behavioral of gfir_transposed is

   -- types 
   type product_inp_coeff is array (0 to filter_taps - 1) of signed(input_len + coeff_len - 1 downto 0);
   type add_res           is array (0 to filter_taps - 3) of signed(input_len + coeff_len - 1 downto 0); 

   -- type related constants & signals
   signal product_ar     : product_inp_coeff := (others => (others => '0'));
   signal add_ar         : add_res           := (others => (others => '0'));

   -- signals
   signal mult1_d0       : signed(input_len + coeff_len - 1 downto 0) := (others => '0');
   signal tap_cnt        : integer range 0 to filter_taps := 0;

   -- attributes
   attribute use_dsp               : string;
   attribute use_dsp of Behavioral : architecture is "yes";  

begin

   -- this process is used to implement Transposed FIR Filter
   transposed_fir_p : process (clock)
   begin
      if (rising_edge(clock)) then 
         if (reset = '1') then
            data_out                   <= (others => '0');
            valid_out                  <= '0';
            tap_cnt                    <= 0;
         else
            if (valid_in = '1') then
               if (tap_cnt = filter_taps) then 
                  valid_out            <= '1';
               else  
                  tap_cnt              <= tap_cnt + 1;
               end if;
               
               -- this for loop is used to calculate multiplication of input data and filter coefficients
               for mult_idx in 0 to filter_taps - 1 loop 
                  product_ar(mult_idx) <= signed(data_in) * filter_coeff(mult_idx); -- Q2: when converting from signed to integer, what will be the integer size default 32 bit or optimized according to signed vectors width?
               end loop;
               
               -- this delays first product 
               mult1_d0                <= product_ar(0);
               
               -- this for loop is used to add delayed and non-delayed product
               -- for the first stage delayed version of first product and second product added
               -- other stages adds previous sum and next product
               for add_idx in 0 to filter_taps - 2 loop
                  if (add_idx = filter_taps - 2) then 
                     data_out          <= std_logic_vector(add_ar(filter_taps - 3) + product_ar(filter_taps - 1)); -- output of transposed FIR filter means filtered data which is converted from signed to std_logic_vector 
                  elsif (add_idx = 0) then 
                     add_ar(0)         <= mult1_d0 + product_ar(1);
                  else 
                     add_ar(add_idx)   <= add_ar(add_idx - 1) + product_ar(add_idx + 1);
                  end if;
               end loop;
            else
               valid_out               <= '0';
               tap_cnt                 <= 0;
               add_ar                  <= (others => (others => '0')); --************ (?) 
               product_ar              <= (others => (others => '0')); --************ (?) 
            end if;
         end if;
      end if;
   end process transposed_fir_p;

end behavioral;