----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/06/2023 09:40:06 PM
-- Design Name: 
-- Module Name: reg_array - Behavioral
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
use work.util_pkg.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity reg_array is
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
end reg_array;

architecture Behavioral of reg_array is
signal reg_array_n, reg_array_c: std_logic_3d(REG_ARRAY_HEIGHT-1 downto 0,REG_ARRAY_WIDTH-1 downto 0, REG_DATA_WDITH-1 downto 0);
begin
process(clk,reset) begin
    if rising_edge(clk) then
        if reset='1' then
            for i in 0 to REG_ARRAY_HEIGHT-1 loop
                for j in 0 to REG_ARRAY_WIDTH-1 loop
                    for k in 0 to REG_DATA_WDITH-1 loop      
                        reg_array_c(i,j,k) <= '0';
                    end loop;
                end loop;
            end loop;           
        else
            reg_array_c <= reg_array_n;     
        end if;
    end if;
end process;  

reg_array_row_gen:for i in 0 to REG_ARRAY_HEIGHT-1 generate
    reg_array_column_gen:for j in 0 to REG_ARRAY_WIDTH-1 generate
        reg_array_element_gen:for k in 0 to REG_DATA_WDITH-1 generate      
            reg_array_n(i,j,k) <= data_in(i,j,k) when wen(i,j) = '1' else reg_array_c(i,j,k);
        end generate;
    end generate;
end generate;   
data_out <= reg_array_c;
end Behavioral;
