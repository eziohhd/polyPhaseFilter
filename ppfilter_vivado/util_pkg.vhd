----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2022/05/04 12:43:57
-- Design Name: 
-- Module Name: util_pkg - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package util_pkg is
    type std_logic_3d is
        array(integer range <>, integer range <>, integer range <>) of std_logic;
    type std_logic_2d is
        array(integer range <>, integer range <>) of std_logic;
    function log2c (n: integer) return integer;
end util_pkg;

package body util_pkg is
    function log2c (n: integer) return integer is
        variable m, p: integer;
    begin
        m := 0;
        p := 1;
        while p < n loop
            m := m + 1;
            p := p * 2;
        end loop;
        return m;
    end log2c;
    

end util_pkg;
