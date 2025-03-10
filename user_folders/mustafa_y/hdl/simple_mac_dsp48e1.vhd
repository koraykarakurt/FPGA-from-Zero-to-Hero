---------------------------------------------------------------------------------------------------
-- Author : Mustafa YETIS
-- Description: a MAC unit using DSP48E1 resource 
--					p_out =  a*b + p_out    
-- More information (optional) :     
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

entity mac_dsp48e1 is
    Port (
        clk   : in  STD_LOGIC;
        rst   : in  STD_LOGIC;
        a     : in  STD_LOGIC_VECTOR (29 downto 0);
        b     : in  STD_LOGIC_VECTOR (17 downto 0);
        p_out : out STD_LOGIC_VECTOR (47 downto 0)
    );
end mac_dsp48e1;

architecture behavioral of mac_dsp48e1 is

signal p_reg : STD_LOGIC_VECTOR(47 downto 0);

begin

DSP48E1_inst : DSP48E1
generic map (
    -- Feature Control Attributes
    USE_MULT      => "MULTIPLY",  -- Enable multiplier
    USE_SIMD      => "ONE48",     -- SIMD selection ("ONE48", "TWO24", "FOUR12")
    -- Register Control Attributes
    AREG         => 1,            -- Number of A input registers (0-2)
    BREG         => 1,            -- Number of B input registers (0-2)
    MREG         => 1,            -- Number of multiplier output registers (0-1)
    PREG         => 1             -- Number of P output registers (0-1)
)
port map (
    -- Cascade Ports
    P            => p_reg,        -- 48-bit output
    -- Control Inputs
    OPMODE       => "0100001",    -- Operation mode (Z = P, Y = 0, X = M)
    ALUMODE      => "0000",       -- ALU mode (add)
    CLK          => clk,          -- 1-bit input clock
    RST          => rst,          -- 1-bit input reset
    -- Data Ports
    A            => a,            -- 30-bit A input
    B            => b,            -- 18-bit B input
    C            => (others => '0'), -- 48-bit C input (not used)
    -- Carry Input
    CARRYIN      => '0',
    CARRYINSEL   => "000",
    -- Clock Enables
    CEA1         => '1',
    CEA2         => '1',
    CEB1         => '1',
    CEB2         => '1',
    CEM          => '1',
    CEP          => '1',
    -- Unused Ports
    D            => (others => '0'),
    INMODE       => "0000",       -- B input direct, A input direct
    PCIN         => (others => '0')
);

p_out <= p_reg;

end behavioral;