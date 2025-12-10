
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

package pcounter is
	COMPONENT product_counter
			  PORT (
					clk          : IN  STD_LOGIC;
					clear_pulse  : IN  STD_LOGIC;
					count_pulse  : IN  STD_LOGIC;
					binary_count : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
			  );
	END COMPONENT;
end  package pcounter;


