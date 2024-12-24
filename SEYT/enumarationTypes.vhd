library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity vhdl_fsm is
   port(
      clk: in std_logic;
      reset: in std_logic;
      in1: in unsigned(4 downto 0);
      in2: in unsigned(4 downto 0);
      out_1: out unsigned(4 downto 0)
      );
end vhdl_fsm;

architecture rtl of vhdl_fsm is
   type tstate is (state_0, state_1, state_2, state_3, state_4);
   signal state: tstate;
   signal next_state: tstate;
begin
   process(clk, reset)
   begin
      if reset = '1' then
            state <= state_0;
      elsif rising_edge(clk) then
            state <= next_state;
      end if;
   end process;

   process(state, in1, in2)
      variable tmp_out_0: unsigned(4 downto 0);
      variable tmp_out_1: unsigned(4 downto 0);
   begin
      tmp_out_0 := in1 + in2;
      tmp_out_1 := in1 - in2;
      case state is
         when state_0 =>
            out_1 <= in1;
            next_state <= state_1;
         when state_1 =>
            if (in1 < in2) then
               next_state <= state_2;
               out_1 <= tmp_out_0;
            else
               next_state <= state_3;
               out_1 <= tmp_out_1;
            end if;
         when state_2 =>
            if (in1 < "0100") then
               out_1 <= tmp_out_0;
            else
               out_1 <= tmp_out_1;
            end if;
               next_state <= state_3;
         when state_3 =>
               out_1 <= "11111";
               next_state <= state_4;
         when state_4 =>
               out_1 <= in2;
               next_state <= state_0;
         when others =>
               out_1 <= "00000";
               next_state <= state_0;
      end case;
   end process;
end rtl;
