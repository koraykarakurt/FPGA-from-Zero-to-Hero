----------------------------------------------------------------------------------
-- Company:  FPGA_FROM_ZERO_TO_HERO
-- Engineer: Abdullah Furkan Kaya
-- 
-- Create Date: 15.01.2025 21:33:19
-- Design Name: 
-- Module Name: gfir_transposed - Behavioral
-- Project Name: FILTER
-- Target Devices: Design will be optimized for ZedBoard
-- Tool Versions: Xilinx Vivado 2023.2
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.03 - File Created
-- Additional Comments:
--
---- TO DO:
-- 1 -> What should be the width of output? How this output should be assigned with the last sum? Because we are adding bunch of numbers
-- 2 -> Make coeff_len generic more usable if filter coefficients has fixed length remove this generic. coefficients constant array could be DYNAMIC array
-- 3 -> Overflow underflow issue should be solved with the pattern detector logic
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity gfir_transposed is

   -- Q1: what is the difference between the following 2 statements
   -- constant const1 : integer range 0 to 15 := 13;
   -- constant const2 : integer := 13;
   -- these constants could become generics as well
  
   generic (
      filter_taps   : integer := 60; -- filter order
      input_len     : integer := 24; -- filter input  length
      coeff_len     : integer := 16; -- filter coefficient length  
      output_len    : integer := 24  -- filter output length
   );
   port (
      clock         : in  std_logic;                                            -- system clock
      reset         : in  std_logic;                                            -- synchronous active-high reset
      filter_data_i : in  std_logic_vector(input_len  - 1 downto 0);            -- filter's input
      din_vld       : in  std_logic;                                            -- valid indicator of the filter's input  | if '1' input  of the filter is valid else invalid
      filter_data_o : out std_logic_vector(input_len + coeff_len - 1 downto 0); -- filter's output
      dout_vld      : out std_logic                                             -- valid indicator of the filter's output | if '1' output of the filter is valid else invalid
   );
end gfir_transposed;

architecture behavioral of gfir_transposed is

   -- types 
   type product_inp_coeff is array (0 to filter_taps - 1) of signed(input_len + coeff_len - 1 downto 0);
   type add_res           is array (0 to filter_taps - 3) of signed(input_len + coeff_len - 1 downto 0);
   type coefficients      is array (0 to filter_taps - 1) of signed(coeff_len - 1             downto 0);

   -- type related constants & signals
   constant filter_coeff : coefficients := (
      x"0000", x"0001", x"0005", x"000C", 
      x"0016", x"0025", x"0037", x"004E", 
      x"0069", x"008B", x"00B2", x"00E0", 
      x"0114", x"014E", x"018E", x"01D3", 
      x"021D", x"026A", x"02BA", x"030B", 
      x"035B", x"03AA", x"03F5", x"043B", 
      x"047B", x"04B2", x"04E0", x"0504", 
      x"051C", x"0528", x"0528", x"051C", 
      x"0504", x"04E0", x"04B2", x"047B", 
      x"043B", x"03F5", x"03AA", x"035B", 
      x"030B", x"02BA", x"026A", x"021D", 
      x"01D3", x"018E", x"014E", x"0114", 
      x"00E0", x"00B2", x"008B", x"0069", 
      x"004E", x"0037", x"0025", x"0016", 
      x"000C", x"0005", x"0001", x"0000"
   );

   signal product_ar     : product_inp_coeff := (others => (others => '0'));
   signal add_ar         : add_res           := (others => (others => '0'));

   -- signals
   signal mult1_d0       : signed(input_len + coeff_len - 1 downto 0) := (others => '0');

   -- attributes
   attribute use_dsp               : string;
   attribute use_dsp of Behavioral : architecture is "yes";  

begin

   -- this process is used to implement Transposed FIR Filter
   transposed_fir_p : process (clock)
   begin
      if (rising_edge(clock)) then 
         if (reset = '1') then
            filter_data_o              <= (others => '0');
            dout_vld                   <= '0';
         else
            if (din_vld = '1') then -- validity check of the filter's input if '1' input of the filter is valid -----------***************************(?) not sure usage of din_vld is correct or not
               
               -- this for loop is used to calculate multiplication of input data and filter coefficients
               for mult_idx in 0 to filter_taps - 1 loop 
                  product_ar(mult_idx) <= signed(filter_data_i) * filter_coeff(mult_idx); -- Q2: when converting from signed to integer, what will be the integer size default 32 bit or optimized according to signed vectors width?
               end loop;
               
               -- this delays first product 
               mult1_d0                <= product_ar(0);
               
               -- this for loop is used to add delayed and non-delayed product
               -- for the first stage delayed version of first product and second product added
               -- other stages adds previous sum and next product
               for add_idx in 0 to filter_taps - 2 loop
                  if (add_idx = filter_taps - 2) then 
                     filter_data_o     <= std_logic_vector(add_ar(filter_taps - 3) + product_ar(filter_taps - 1)); -- output of transposed FIR filter means filtered data which is converted from signed to std_logic_vector 
                     dout_vld          <= '1';
                  elsif (add_idx = 0) then 
                     add_ar(0)         <= mult1_d0 + product_ar(1);
                  else 
                     add_ar(add_idx)   <= add_ar(add_idx - 1) + product_ar(add_idx + 1);
                  end if;
               end loop;
            
            else -----------***************************(?) not sure usage of din_vld is correct or not
               dout_vld                <= '0';
            end if;
         end if;
      end if;
   end process transposed_fir_p;

end behavioral;