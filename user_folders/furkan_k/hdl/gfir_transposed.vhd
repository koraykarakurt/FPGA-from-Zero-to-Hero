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
-- Revision 0.02 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity gfir_transposed is

  -- Q1: what is the difference between the following 2 statements
  -- constant const1 : integer range 0 to 15 := 13;
  -- constant const2 : integer := 13;
  -- these constants could become generics as well
  
  generic (
    filter_taps : integer := 5; -- filter order
    input_len   : integer := 24; -- filter input  length
	coeff_len   : integer := 16; -- filter coefficient length  
	output_len  : integer := 24  -- filter output length
  );
  port ( 
    reset              : in  std_logic; -- active high reset -- not sure it is necessary or not
	clock              : in  std_logic; -- system clock
--	filtering_ena      : in  std_logic; -- filter's enable if '1' --> filter starts operating | '0' --> filter 
	filter_data_i      : in  std_logic_vector(input_len  - 1 downto 0); -- filter's input
	filter_data_o      : out std_logic_vector(output_len - 1 downto 0)  -- filter's output
  
  
  );
end gfir_transposed;

architecture Behavioral of gfir_transposed is
  
  -- types 
  type product_inp_coeff is array (0 to filter_taps - 1) of signed(input_len + coeff_len - 1 downto 0);
  type coefficients      is array (0 to filter_taps - 1) of signed(coeff_len - 1             downto 0);

  -- type related constants & signals
  constant filter_coeff : coefficients := (
    x"0001",
    x"0002",
	x"0003",
    x"0004",
    x"0005"
  );
  signal product_ar     : product_inp_coeff;
  
  -- signals
  signal sum            : signed(input_len + coeff_len - 1 downto 0);
  signal product_idx    : integer range 0 to filter_taps - 1;

  signal mult1_d0       : signed(input_len + coeff_len downto 0);
  signal sig1           : signed(input_len + coeff_len downto 0);
  signal sig2           : signed(input_len + coeff_len downto 0);
  signal sig3           : signed(input_len + coeff_len downto 0);
  signal sig4           : signed(input_len + coeff_len downto 0);
  -- attributes
--  attribute use_dsp : string;
--  attribute use_dsp of Behavioral : architecture is "yes";  

begin

--  transposed_fir_p : process (reset, clock)
--  begin
--    if (reset = '1') then
--	  product_ar      <= (others => (others => '0'));
--	  sum             <= (others => '0');
--	  product_idx     <= 0;
--	elsif (rising_edge(clock)) then 
--
--	  for i in 0 to filter_taps - 1 loop 
--	    product_ar(i) <= signed(filter_data_i) * filter_coeff(i); -- Q2: when converting from signed to integer, what will be the integer size default 32 bit or optimized according to signed vectors width?		
--	  end loop;
--
--      if (product_idx /= filter_taps) then -- adding the multiplication results
--	    sum           <= sum + product_ar(product_idx);
--		product_idx   <= product_idx + 1; -- incrementing product index
--      else 
--	    product_idx   <= 0;
--		sum           <= (others => '0'); -- ???????????????????? not sure this should used or not
--      end if;
--	  
--	end if;
--  end process transposed_fir_p;
--
--  filter_data_o       <= std_logic_vector(sum(output_len-1 downto 0));

  transposed_fir_p : process (reset, clock)
  begin
    if (reset = '1') then
	  product_ar      <= (others => (others => '0'));
--	  sum             <= (others => '0');
--	  product_idx     <= 0;
	  
	  mult1_d0        <= (others => '0');
	  sig1            <= (others => '0');
	  sig2            <= (others => '0');
	  sig3            <= (others => '0');
	  sig4            <= (others => '0');
	  filter_data_o   <= (others => '0');
	elsif (rising_edge(clock)) then 
      filter_data_o   <= std_logic_vector(sig4(output_len-1 downto 0));
	  mult1_d0        <= '0' & product_ar(0);
	  sig1            <= mult1_d0 + product_ar(1);
	  sig2            <= sig1     + product_ar(2);
	  sig3            <= sig2     + product_ar(3);
	  sig4            <= sig3     + product_ar(4);
	  
	  for i in 0 to filter_taps - 1 loop 
	    product_ar(i) <= signed(filter_data_i) * filter_coeff(i); -- Q2: when converting from signed to integer, what will be the integer size default 32 bit or optimized according to signed vectors width?		
	  end loop;

--      if (product_idx /= filter_taps) then -- adding the multiplication results
--	    sum           <= sum + product_ar(product_idx);
--		product_idx   <= product_idx + 1; -- incrementing product index
--      else 
--	    product_idx   <= 0;
--		sum           <= (others => '0'); -- ???????????????????? not sure this should used or not
--      end if;
	  
	end if;
  end process transposed_fir_p;




end Behavioral;
