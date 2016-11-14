--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:31:41 10/17/2016
-- Design Name:   
-- Module Name:   D:/local/src/xula/Xula2Servo/servo_tb2.vhd
-- Project Name:  servo
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: servo
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
use work.servo_comp.all;  -- Package for PC <=> FPGA communications.
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY servo_tb2 IS
END servo_tb2;
 
ARCHITECTURE behavior OF servo_tb2 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT servo
    PORT(
         clk_i : IN  std_logic;
         reset_i : IN  std_logic;
         pos_i : IN  std_logic_vector(10 downto 0);
         servo_o : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk_i : std_logic := '0';
   signal reset_i : std_logic := '0';
   signal pos_i : std_logic_vector(10 downto 0) := (others => '0');

 	--Outputs
   signal servo_o : std_logic;

   -- Clock period definitions
   constant clk_i_period : time := 83.3333 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: servo PORT MAP (
          clk_i => clk_i,
          reset_i => reset_i,
          pos_i => pos_i,
          servo_o => servo_o
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
      -- hold reset state for 300 ns.
		reset_i <= '1';
      wait for 300 ns;	
		reset_i <= '0';

      wait for clk_i_period*10;
		pos_i <= std_logic_vector(to_unsigned(1000,11));
      wait for 100ms;
		pos_i <= std_logic_vector(to_unsigned(1500,11));
      wait for 100ms;
		pos_i <= std_logic_vector(to_unsigned(2000,11));

      wait;
   end process;

END;
