----------------------------------------------------------------------------------
-- Company: nope
-- Engineer: me
-- 
-- Create Date:    13:48:22 10/06/2016 
-- Design Name: 
-- Module Name:    cleaner - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------

--type servo_in_type is record
--    pos_i : std_logic_vector(10 downto 0);
--end record;
--
--type servo_out_type is record
--    servo_o : std_logic;
--end record;
library IEEE;
use IEEE.STD_LOGIC_1164.all;


package servo_comp is

component servo is
  Port ( clk_i : in  STD_LOGIC;
         reset_i : in STD_LOGIC;
         --pos_i : in std_logic_vector(10 downto 0);
         servo_o : out std_logic;
         led_o   : out std_logic
         );
end component;

end package;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.HostIoPckg.all;  -- Package for PC <=> FPGA communications.

library UNISIM;
use UNISIM.VComponents.all;

entity servo is
  Port ( clk_i : in  STD_LOGIC;
         --reset_i : in STD_LOGIC;
         --pos_i : in std_logic_vector(10 downto 0);
         servo_o : out std_logic;
         led_o   : out std_logic);
end servo;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
architecture twoproc of servo is

  signal clk_1MHz : std_logic;

  signal servo_h : std_logic;
  --XESS
  -- Connections between the shift-register module and the servo.
  signal toServo_s     : std_logic_vector(12 downto 0);  -- From PC to servo.
  signal fromServo_s   : std_logic_vector(21 downto 0);   -- From servo to PC.
  -- Connections between the shift-register module and the RAM.
  --signal toRAM_s     : std_logic_vector(11 downto 0);  -- From PC to RAM.
  --signal fromRAM_s   : std_logic_vector(11 downto 0);   -- From RAM to PC.

  --input
  alias led_i is   toServo_s(12 downto 12);
  alias reset_i is toServo_s(11 downto 11);
  alias pos_i    is toServo_s(10 downto  0);
  --output
  alias reported is fromServo_s(10 downto 0);
  alias cnt is fromServo_s(21 downto 11);
  
  
  -- Connections between JTAG entry point and the shift-register module.
  signal inShiftDr_s   : std_logic;     -- True when bits shift btwn PC & FPGA.
  signal drck_s        : std_logic;     -- Bit shift clock.
  signal tdi_s         : std_logic;     -- Bits from host PC to the blinker.
  signal tdo_s         : std_logic;     -- Bits from blinker to the host PC.
  signal tdoServo_s    : std_logic;
  --signal tdoRAM_s      : std_logic;
  
  constant REPETITIONS: integer := 3;
  constant T20MS: integer := 20_000;

  --signal cnt : std_logic(10 downto 0);
  signal counting : std_logic;
  
  
  signal d2, d3 : std_logic;
  --signal cnt : std_logic_vector(10 downto 0);
begin

  led_o <= led_i(12);
  --reset_i <= resetv_i(11);
  
  --servo_helper_1 <= reset_i;
----------------------------------------------------------------------------------
-- Digital Clock Manager
--
-- sensitivity : clk_i
-- extra inputs:
-- outputs     : clk_1MHz
----------------------------------------------------------------------------------
  DCM_SP_1MHz : DCM_SP
    generic map (
      CLKFX_DIVIDE   => 24, 
      CLKFX_MULTIPLY => 2
      )
    port map (
      CLKFX => clk_1MHz,  --  1MHz out
      CLKIN => clk_i,     -- 12MHz in
      RST   => reset_i(11)
      );



  comb : process(reset_i, pos_i, clk_1MHz) is
    variable counter : integer := 0;
    variable rep : integer := REPETITIONS;
  begin
    if reset_i(11) = '1' then
      rep := REPETITIONS;
      counter := 0;
      servo_o <= '0';
      servo_h <= '0';
    else
      if rising_edge(clk_1MHz) then
        if counter = T20MS then -- 50Hz trigger
          if rep > 0 then
            rep := rep - 1;
            servo_o <= '1';
            servo_h <= '1';
          end if;
          counter := 0;
        end if;
        if counter = pos_i then
          servo_o <= '0';
          servo_h <= '0';
        end if;
        counter := counter + 1;
      elsif falling_edge(clk_1MHz) then
        -- do nothing;
      else --pos_i changed
        rep := REPETITIONS;
      end if;
    end if;
  end process;

test_counter_a_pw: process(reset_i, clk_1Mhz)
begin
  if reset_i(11) = '1' then
    reported <= "00000000000";
  else
  if clk_1MHz'event and clk_1MHz='1' then -- Synchronous process, clock edge is outer "if"
      d2 <= servo_h;  -- First D FF stage (common synchronization point)
      d3 <= d2; -- Second D FF stage for edge detect
      if  d3 = '0' and d2 = '1' then -- Detect rising edge
        cnt <= "00000000000";
      elsif d3 = '1' and d2 = '0' then -- Detect falling edge
        reported <= cnt + 1;  -- Capture count
      else
        cnt <= cnt + 1;
      end if;
    end if;
    end if;
end process test_counter_a_pw;  

  -- XESS
  -------------------------------------------------------------------------
  -- JTAG entry point.
  -------------------------------------------------------------------------

  -- Main entry point for the JTAG signals between the PC and the FPGA.
  UBscanToHostIo : BscanToHostIo
    port map (
      inShiftDr_o => inShiftDr_s,
      drck_o      => drck_s,
      tdi_o       => tdi_s,
      tdo_i       => tdo_s
      );
  tdo_s <= tdoServo_s; -- or tdoRAM_s;
  -------------------------------------------------------------------------
  -- Shift-register 1 servo pos in, p1 out
  -------------------------------------------------------------------------

  -- This is the shift-register module between servo and JTAG entry point.
  UHostIoToServo : HostIoToDut
    generic map (ID_G => "00001001")    -- The identifier used by the PC.
    port map (
      -- Connections to the BscanToHostIo JTAG entry-point module.
      inShiftDr_i     => inShiftDr_s,
      drck_i          => drck_s,
      tdi_i           => tdi_s,
      tdo_o           => tdoServo_s,
      -- Connections to the blinker.
      vectorToDut_o   => toServo_s,   -- From PC to servo.
      vectorFromDut_i => fromServo_s  -- From servo to PC.
      );

--  -------------------------------------------------------------------------
--  -- Shift-register 2 data logger out
--  -------------------------------------------------------------------------
--
--  -- This is the shift-register module between data logger RAM and JTAG entry point.
--  UHostIoToRAM : HostIoToDut
--    generic map (ID_G => "00001010")    -- The identifier used by the PC.
--    port map (
--      -- Connections to the BscanToHostIo JTAG entry-point module.
--      inShiftDr_i     => inShiftDr_s,
--      drck_i          => drck_s,
--      tdi_i           => tdi_s,
--      tdo_o           => tdoRAM_s,
--      -- Connections to the RAM.
--      vectorToDut_o   => toRAM_s,   -- From PC to servo.
--      vectorFromDut_i => fromRAM_s  -- From servo to PC.
--      );
--
--   -- test second SHR
--   fromRAM_s <= toRAM_s + 1;
   
end twoproc;
