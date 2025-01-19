library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bcdtoseven is
    port (
        sw : in std_logic_vector(13 downto 0);
        clk : in std_logic;
        seg : out std_logic_vector(6 downto 0);
        an : out std_logic_vector(3 downto 0)
    );
end bcdtoseven;

architecture behavioral of bcdtoseven is
    type digit_type is (ones_digit, tens_digit, hundreds_digit, thousands_digit);
    signal current_digit : digit_type := ones_digit;
    signal ones, tens, hundreds, thousands : std_logic_vector(3 downto 0);
    signal slow_clk : std_logic := '0';
    signal clk_divider : integer := 0;
type binary_value_type is ( 
        ZERO, ONE, TWO, THREE, FOUR, FIVE, 
        SIX, SEVEN, EIGHT, NINE
);
 function binary_to_seven_segment(input : std_logic_vector(3 downto 0)) return std_logic_vector is
        variable seg_output : std_logic_vector(6 downto 0);
    begin
 case input is
            when ZERO => seg_output := "1000000";
            when ONE => seg_output := "1111001";
            when TWO => seg_output := "0100100";
            when THREE => seg_output := "0110000";
            when FOUR => seg_output := "0011001";
            when FIVE => seg_output := "0010010";
            when SIX => seg_output := "0000010";
            when SEVEN => seg_output := "1111000";
            when EIGHT => seg_output := "0000000";
            when NINE => seg_output := "0010000";
            when others => seg_output := "1111111";
        end case;
        return seg_output;
    end function;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if clk_divider = 50000 then
                slow_clk <= not slow_clk;
                clk_divider <= 0;
            else
                clk_divider <= clk_divider + 1;
            end if;
        end if;
    end process;
 process(sw)
        variable value_int : integer;
    begin
        value_int := to_integer(unsigned(sw));
        thousands <= std_logic_vector(to_unsigned(value_int / 1000, 4));
        hundreds <= std_logic_vector(to_unsigned((value_int / 100) mod 10, 4));
        tens <= std_logic_vector(to_unsigned((value_int / 10) mod 10, 4));
        ones <= std_logic_vector(to_unsigned(value_int mod 10, 4));
    end process;  

process(current_digit, ones, tens, hundreds, thousands)
    begin
        case current_digit is
            when ones_digit => an <= "1110"; seg <= binary_to_seven_segment(ones);
            when tens_digit => an <= "1101"; seg <= binary_to_seven_segment(tens);
            when hundreds_digit => an <= "1011"; seg <= binary_to_seven_segment(hundreds);
            when thousands_digit => an <= "0111"; seg <= binary_to_seven_segment(thousands);
            when others => an <= "1111"; seg <= (others => '1');
        end case;
    end process;
process(slow_clk)
    begin
        if rising_edge(slow_clk) then
            case current_digit is
                when ones_digit => current_digit <= tens_digit;
                when tens_digit => current_digit <= hundreds_digit;
                when hundreds_digit => current_digit <= thousands_digit;
                when thousands_digit => current_digit <= ones_digit;
                when others => current_digit <= ones_digit;
            end case;
        end if;
    end process;
end behavioral;




