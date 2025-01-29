----------------------------------------------------------------------------------
-- Company: FalsePaths
-- Engineer: Emir EROL
-- 
-- Create Date: 01/29/2025
-- Design Name: 
-- Module Name: generic_multiplier_tb - testbench
-- Project Name: Generic Multiplier
-- JIRA No: FIRF-11;
-- Target Devices: Kria KV260
-- Tool Versions: VHDL2019
-- Description: Generic multiplier module testbench
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library osvvm;
use osvvm.randompkg.all; --for random operations

entity generic_multiplier_tb is
end generic_multiplier_tb;

architecture testbench of generic_multiplier_tb is

    component generic_multiplier
        generic (
            sign : integer := 0; 
            size : integer := 8);
            
        port (
            mult_1 : in  std_logic_vector(7 downto 0);
            mult_2 : in  std_logic_vector(7 downto 0);
            mult_o : out std_logic_vector(15 downto 0)
        );
    end component;

    constant data_width       : integer := 8;
    constant uns_mult_type    : integer := 0;
    constant s_mult_type      : integer := 1;
    constant wait_time        : time := 10 ns;
    --for unsigned values
    constant uns_loop_start   : integer := 1;
    constant uns_loop_stop    : integer := 15;
    --for signed values  
    constant s_loop_start     : integer := -8;
    constant s_loop_stop      : integer := 7;

    signal uns_mult1   : std_logic_vector(data_width - 1 downto 0);
    signal uns_mult2   : std_logic_vector(data_width - 1 downto 0);
    signal uns_mult_o  : std_logic_vector(2 * data_width - 1 downto 0);

    signal s_mult1     : std_logic_vector(data_width - 1 downto 0);
    signal s_mult2     : std_logic_vector(data_width - 1 downto 0);
    signal s_mult_o    : std_logic_vector(2 * data_width - 1 downto 0);

    signal expected_output_uns : unsigned(2 * data_width - 1 downto 0);
    signal expected_output_s   : signed(2 * data_width - 1 downto 0);
    signal error_injection              : boolean := true;

begin
    P_STIMULI : process
        variable rand_gen : RandomPType; -- Declare random generator as variable
        variable random_value_uns : integer;
        variable random_value_s : integer;
    begin
        -- Initialize the random generator
        rand_gen.InitSeed(1);
        
        -- unsigned values
        for i in uns_loop_start to uns_loop_stop loop
            for j in uns_loop_start to uns_loop_stop loop
                uns_mult1 <= std_logic_vector(to_unsigned(i, data_width));
                uns_mult2 <= std_logic_vector(to_unsigned(j, data_width));
                expected_output_uns <= to_unsigned(i, data_width) * to_unsigned(j, data_width);

                random_value_uns := rand_gen.RandInt(uns_loop_start, uns_loop_stop);
                
                wait for wait_time;

                -- Error injection check for unsigned multiplication
                if er_inj and (random_value_uns = i) then
                    assert uns_mult_o /= std_logic_vector(expected_output_uns)
                            report "Error injection occurred for unsigned multiplication." severity note;
                else
                    assert uns_mult_o = std_logic_vector(expected_output_uns)
                            report "Unsigned multiplication failed: Expected " & 
                                integer'image(to_integer(expected_output_uns)) & 
                                ", Got " & integer'image(to_integer(unsigned(uns_mult_o)))
                            severity error;
                end if;
            end loop;
        end loop;

        -- signed values
        for i in s_loop_start to s_loop_stop loop
            for j in uns_loop_start to uns_loop_stop loop
                s_mult1 <= std_logic_vector(to_signed(i, data_width));
                s_mult2 <= std_logic_vector(to_signed(j, data_width));
                expected_output_s <= to_signed(i, data_width) * to_signed(j, data_width);

                random_value_s := rand_gen.RandInt(s_loop_start, s_loop_stop);
                
                wait for wait_time;

                -- Error injection check for signed multiplication
                if er_inj and (random_value_s = i) then
                    assert s_mult_o /= std_logic_vector(expected_output_s)
                            report "Error injection occurred for signed multiplication." severity note;
                else
                    assert s_mult_o = std_logic_vector(expected_output_s)
                            report "Signed multiplication failed: Expected " & 
                                integer'image(to_integer(expected_output_s)) & 
                                ", Got " & integer'image(to_integer(unsigned(s_mult_o)))
                            severity error;
                end if;
            end loop;
        end loop;

        report "Test is finished!" severity failure;
    end process;

    DUT_uns : generic_multiplier
        generic map (
            sign  => uns_mult_type,
            size => data_width
        )
        port map(
            mult_1   => uns_mult1,
            mult_2   => uns_mult2,
            mult_o => uns_mult_o
        );

    -- Instantiate DUT for signed multiplication
    DUT_s : generic_multiplier
        generic map (
            sign  => s_mult_type,
            size => data_width
        )
        port map(
            mult_1   => s_mult1,
            mult_2   => s_mult2,
            mult_o => s_mult_o
        );

end testbench;
