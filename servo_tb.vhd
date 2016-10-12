--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   09:33:04 10/03/2016
-- Design Name:   
-- Module Name:   D:/local/src/xula/servo/servi_tb.vhd
-- Project Name:  servo
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: fast_blinker
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY servi_tb IS
END servi_tb;
 
ARCHITECTURE behavior OF servi_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT erlkoenig
    PORT(
         clk_i     : IN  std_logic;
         pos_i     : IN  STD_LOGIC_VECTOR(10 downto 0);
         blinker_o : OUT  std_logic;
         reset_i   : in std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk_i : std_logic := '0';
   signal pos_i : STD_LOGIC_VECTOR(10 downto 0) := (others => '0');
   signal reset_i : std_logic := '0';

 	--Outputs
   signal blinker_o : std_logic;

   -- Clock period definitions
   constant clk_i_period : time := 83.3333 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: erlkoenig PORT MAP (
          clk_i => clk_i,
          pos_i => pos_i,
          blinker_o => blinker_o,
			 reset_i => reset_i
        );

   -- Clock process definitions
   clk_i_process :process
   begin
		clk_i <= '0';
		wait for clk_i_period/2;
		clk_i <= '1';
		wait for clk_i_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		reset_i <= '1';
      wait for 100 ns;	
		reset_i <= '0';

      wait for clk_i_period*10;
		pos_i <= "00000001000";
      wait for 20ms;
		pos_i <= "00001001000";
      wait for 80ms;
		pos_i <= "00101001000";

      wait;
   end process;

END;
