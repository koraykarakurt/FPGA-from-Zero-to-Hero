library IEEE;
use IEEE.std_logic_1164.all;

package multiplier_types_pkg is
    -- Type definitions for multiplier signals
    type t_multiplier_inputs is record
        input1 : std_logic_vector;
        input2 : std_logic_vector;
    end record;
    
    type t_test_control is record
        error_inject_enable : boolean;
        error_inject_test  : integer;
        error_inject_type  : integer;
        error_inject_value : std_logic_vector;
    end record;
    
    type t_test_status is record
        test_done   : boolean;
        error_count : integer;
        test_number : integer;
    end record;
end package multiplier_types_pkg; 