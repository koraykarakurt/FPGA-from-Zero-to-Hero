library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;  -- for to_unsigned and unsigned types

entity bcdtoseven is
    port (
        sw                      : in std_logic_vector(13 downto 0);  -- 14-bit switch input (range: 0-9999)
        clk                     : in std_logic;                      -- clock input for multiplexing the displays
        seg                     : out std_logic_vector(6 downto 0);  -- 7-segment display output (a, b, c, d, e, f, g)
        an                      : out std_logic_vector(3 downto 0)   -- anode control for 4 digits
    );
end bcdtoseven;

architecture behavioral of bcdtoseven is
    -- declare an enumeration type for the digits
    type digit_type is (ones_digit, tens_digit, hundreds_digit, thousands_digit);
    signal current_digit : digit_type := ones_digit;  -- keep track of the active digit

    signal ones, tens, hundreds, thousands : std_logic_vector(3 downto 0); -- bcd for each digit
    signal slow_clk : std_logic := '0';  -- slow clock signal for multiplexing
    signal clk_divider : integer := 0;  -- clock divider counter

    -- function to convert bcd to 7-segment output
    function binary_to_seven_segment(input : std_logic_vector(3 downto 0)) return std_logic_vector is
        variable seg_output : std_logic_vector(6 downto 0);  -- 7-bit output for 7-segment display
    begin
        case input is
            when "0000" => seg_output := "1000000"; -- 0
            when "0001" => seg_output := "1111001"; -- 1
            when "0010" => seg_output := "0100100"; -- 2
            when "0011" => seg_output := "0110000"; -- 3
            when "0100" => seg_output := "0011001"; -- 4
            when "0101" => seg_output := "0010010"; -- 5
            when "0110" => seg_output := "0000010"; -- 6
            when "0111" => seg_output := "1111000"; -- 7
            when "1000" => seg_output := "0000000"; -- 8
            when "1001" => seg_output := "0010000"; -- 9
            when others => seg_output := "1111111"; -- display off
        end case;
        return seg_output;
    end function;

begin

    -- clock divider to slow down the clock
    process(clk)
    begin
        if rising_edge(clk) then
            if clk_divider = 50000 then  -- divide 100 mhz clock to approx 1 khz
                slow_clk <= not slow_clk;
                clk_divider <= 0;
            else
                clk_divider <= clk_divider + 1;
            end if;
        end if;
    end process;

    -- convert binary input to bcd
    process(sw)
        variable value_int : integer;
    begin
        value_int := to_integer(unsigned(sw));  -- convert binary input to integer
        thousands <= std_logic_vector(to_unsigned(value_int / 1000, 4)); -- thousands place
        hundreds <= std_logic_vector(to_unsigned((value_int / 100) mod 10, 4)); -- hundreds place
        tens <= std_logic_vector(to_unsigned((value_int / 10) mod 10, 4)); -- tens place
        ones <= std_logic_vector(to_unsigned(value_int mod 10, 4)); -- ones place
    end process;

    -- update the 7-segment display and anodes based on the current active digit
    process(current_digit, ones, tens, hundreds, thousands)
    begin
        case current_digit is
            when ones_digit =>
                an <= "1110";  -- enable the first digit (ones)
                seg <= binary_to_seven_segment(ones);
            when tens_digit =>
                an <= "1101";  -- enable the second digit (tens)
                seg <= binary_to_seven_segment(tens);
            when hundreds_digit =>
                an <= "1011";  -- enable the third digit (hundreds)
                seg <= binary_to_seven_segment(hundreds);
            when thousands_digit =>
                an <= "0111";  -- enable the fourth digit (thousands)
                seg <= binary_to_seven_segment(thousands);
            when others =>
                an <= "1111";  -- disable all digits
                seg <= (others => '1');
        end case;
    end process;

    -- switch to the next digit on every slow clock edge
    process(slow_clk)
    begin
        if rising_edge(slow_clk) then
            case current_digit is
                when ones_digit =>
                    current_digit <= tens_digit;
                when tens_digit =>
                    current_digit <= hundreds_digit;
                when hundreds_digit =>
                    current_digit <= thousands_digit;
                when thousands_digit =>
                    current_digit <= ones_digit;
                when others =>
                    current_digit <= ones_digit;
            end case;
        end if;
    end process;

end behavioral;
