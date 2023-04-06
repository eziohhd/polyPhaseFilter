----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/06/2023 11:16:24 PM
-- Design Name: 
-- Module Name: reg_array_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use work.util_pkg.all;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity reg_array_tb is
--  Port ( );
end reg_array_tb;

architecture Behavioral of reg_array_tb is
component input_gen is
    generic (
        FILE_NAME: string ;
        INPUT_WIDTH: positive
        ); 
    Port (
        clk: in std_logic;
        reset: in std_logic;
        input_write_en: in std_logic;
        input_sample: out std_logic_vector(INPUT_WIDTH-1 downto 0)
        );
end component;

component reg_array is
    generic (
        REG_ARRAY_HEIGHT  : integer := 512;
        REG_ARRAY_WIDTH   : integer := 1016; 
        REG_DATA_WDITH    : integer := 32        
        );
    port(
        clk   : in std_logic;
        reset  : in std_logic;
        wen     : in std_logic_2d(REG_ARRAY_HEIGHT-1 downto 0, REG_ARRAY_WIDTH-1 downto 0);
        data_in: in std_logic_3d(REG_ARRAY_HEIGHT-1 downto 0,REG_ARRAY_WIDTH-1 downto 0, REG_DATA_WDITH-1 downto 0);
        data_out: out std_logic_3d(REG_ARRAY_HEIGHT-1 downto 0,REG_ARRAY_WIDTH-1 downto 0, REG_DATA_WDITH-1 downto 0)  
        );
end component;
begin


end Behavioral;
