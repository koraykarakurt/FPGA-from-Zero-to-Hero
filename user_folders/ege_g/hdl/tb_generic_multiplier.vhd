---------------------------------------------------------------------------------------------------
-- Author : Ege ömer Göksu
-- Description : FIRF-41 Generic Multiplier Testbench
-- More information (optional) : Error injection rate is 10%
--procedure check inside a package?
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.env.all;

library OSVVM;
use OSVVM.RandomPkg.all;

entity tb_generic_multiplier is
end tb_generic_multiplier;

architecture sim of tb_generic_multiplier is
   component generic_multiplier is
   generic(
      SIGNED_FLAG : boolean := true;
      DATA_LENGTH : integer := 32 
   );
   port(
      mult_in_1 : in std_logic_vector (DATA_LENGTH-1 downto 0);
      mult_in_2 : in std_logic_vector (DATA_LENGTH-1 downto 0);
      mult_out  : out std_logic_vector (2*DATA_LENGTH-1 downto 0)
   );
   end component;
   
   constant DATA_LENGTH : integer := 32;
   constant CLK_PERIOD  : time := 10 ns;
   constant TEST_NUMBER : integer := 50;
   
   signal mult_in_1_signed    : std_logic_vector (DATA_LENGTH-1 downto 0);
   signal mult_in_1_unsigned  : std_logic_vector (DATA_LENGTH-1 downto 0);
   signal mult_in_2_signed    : std_logic_vector (DATA_LENGTH-1 downto 0);
   signal mult_in_2_unsigned  : std_logic_vector (DATA_LENGTH-1 downto 0);
   signal mult_out_unsigned   : std_logic_vector (2*DATA_LENGTH-1 downto 0);
   signal mult_out_signed     : std_logic_vector (2*DATA_LENGTH-1 downto 0);
   
   signal signed_done   : std_logic := '0';
   signal unsigned_done : std_logic := '0';
 
   procedure check(
      constant output_value      : in std_logic_vector(2*DATA_LENGTH-1 downto 0);
      constant output_expected   : in std_logic_vector(2*DATA_LENGTH-1 downto 0);
      constant ERROR_INJECTION   : in boolean;
      constant SIGNED_FLAG       : in boolean
   ) is
   begin
      if (SIGNED_FLAG = true) then
         if ERROR_INJECTION = true then
            report   "ERROR INJ! expected: " & integer'image(to_integer(signed(output_expected)))  & " / value: " &
                     integer'image(to_integer(signed(output_value))) severity note;            
         elsif (output_value /= output_expected) then
            report   "Mismatch! expected: " & integer'image(to_integer(signed(output_expected)))  & " / value: " &
                     integer'image(to_integer(signed(output_value))) severity error;
         end if;
      else
         if ERROR_INJECTION = true then
            report   "ERROR INJ! expected: " & integer'image(to_integer(unsigned(output_expected)))  & " / value: " &
                     integer'image(to_integer(unsigned(output_value))) severity note;              
         elsif (output_value /= output_expected) then
            report   "Mismatch! expected: " & integer'image(to_integer(unsigned(output_expected)))  & " / value: " & 
                     integer'image(to_integer(unsigned(output_value))) severity error;
         end if;
      end if;
   end check;
   
begin
   DUT_SIGNED : generic_multiplier
   generic map(
      SIGNED_FLAG => true, 
      DATA_LENGTH => DATA_LENGTH 
   )
   port map(
      mult_in_1 => mult_in_1_signed, 
      mult_in_2 => mult_in_2_signed, 
      mult_out  => mult_out_signed  
   );
   
   DUT_UNSIGNED : generic_multiplier
   generic map(
      SIGNED_FLAG => false, 
      DATA_LENGTH => DATA_LENGTH 
   )
   port map(
      mult_in_1 => mult_in_1_unsigned, 
      mult_in_2 => mult_in_2_unsigned, 
      mult_out  => mult_out_unsigned  
   );
   
   SIGNED_TEST : process
      variable rand_gen_signed     : RandomPType;
      variable signed_in1, signed_in2  : signed (DATA_LENGTH-1 downto 0);
      variable signed_out_exp 		: signed (2*DATA_LENGTH-1 downto 0);
      variable mult_out_expected 	: std_logic_vector (2*DATA_LENGTH-1 downto 0);
      variable mult_out_err_inj	   : std_logic_vector (2*DATA_LENGTH-1 downto 0);
      variable error_inj            : boolean := false;
   begin
      rand_gen_signed.InitSeed(95);
      for i in 1 to TEST_NUMBER loop
         signed_in1     := to_signed(rand_gen_signed.RandInt(-50,50) ,DATA_LENGTH);
         signed_in2   	:= to_signed(rand_gen_signed.RandInt(-50,50) ,DATA_LENGTH);
         mult_in_1_signed   <= std_logic_vector(signed_in1);
         mult_in_2_signed   <= std_logic_vector(signed_in2);
         signed_out_exp    := signed_in1 * signed_in2;
         mult_out_expected := std_logic_vector(signed_out_exp);
         
         wait for 10 ns; --wait for processing
         --error injection
         --Flip the LSB of the output
         error_inj := (rand_gen_signed.RandInt(1,10) = 1);
         if error_inj then
            mult_out_err_inj := mult_out_signed;
            mult_out_err_inj(0) := not mult_out_err_inj(0);
            check(mult_out_err_inj, mult_out_expected, error_inj, true);
            error_inj := false;
         else 
         	check(mult_out_signed, mult_out_expected, error_inj, true);
         end if;       
      end loop;
      signed_done <= '1';
      wait;
   end process SIGNED_TEST;
   
   UNSIGNED_TEST : process
      variable rand_gen_unsigned    : RandomPType;
      variable unsigned_in1, unsigned_in2  : unsigned (DATA_LENGTH-1 downto 0);
      variable unsigned_out_exp 		: unsigned (2*DATA_LENGTH-1 downto 0);
      variable mult_out_expected 	: std_logic_vector (2*DATA_LENGTH-1 downto 0);
      variable mult_out_err_inj	   : std_logic_vector (2*DATA_LENGTH-1 downto 0);
      variable error_inj            : boolean := false;
   begin
      rand_gen_unsigned.InitSeed(95);
      for i in 1 to TEST_NUMBER loop
         unsigned_in1     := to_unsigned(rand_gen_unsigned.RandInt(0,100) ,DATA_LENGTH);
         unsigned_in2   	:= to_unsigned(rand_gen_unsigned.RandInt(0,100) ,DATA_LENGTH);
         mult_in_1_unsigned   <= std_logic_vector(unsigned_in1);
         mult_in_2_unsigned   <= std_logic_vector(unsigned_in2);
         unsigned_out_exp    := unsigned_in1 * unsigned_in2;
         mult_out_expected := std_logic_vector(unsigned_out_exp);

         wait for 10 ns; --wait for processing
         --error injection
         --Flip the LSB of the output
         error_inj := (rand_gen_unsigned.RandInt(1,10) = 1);
         if error_inj then
            mult_out_err_inj := mult_out_unsigned;
            mult_out_err_inj(0) := not mult_out_err_inj(0);
            check(mult_out_err_inj, mult_out_expected, error_inj, false);
            error_inj := false;
         else 
         	check(mult_out_unsigned, mult_out_expected, error_inj, false);
         end if;       
      end loop;
      unsigned_done <= '1';
      wait;         
   end process UNSIGNED_TEST;
   
   SIM_FINISHED : process
   begin
      if (signed_done and unsigned_done) = '1' then
         report "Simulation finished";
         std.env.stop;
      end if;
      wait;
   end process SIM_FINISHED;
end sim;