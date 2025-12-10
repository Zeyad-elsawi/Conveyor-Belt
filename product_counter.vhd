LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY product_counter IS
    PORT (
        clk         : IN  STD_LOGIC;  -- System clock
        
        clear_pulse : IN  STD_LOGIC;  -- 1-cycle pulse from clear button
        count_pulse : IN  STD_LOGIC;  -- 1-cycle pulse from count sensor
        binary_count: OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END product_counter;

ARCHITECTURE rtl OF product_counter IS

    SIGNAL s_count : UNSIGNED(3 DOWNTO 0) := (OTHERS => '0');
    -- One 7-segment digit can show max 0–9

BEGIN

    counter_proc : PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            
            -- Priority 1: Clear Pulse (push button)
            IF clear_pulse = '1' THEN
                s_count <= (OTHERS => '0');

            -- Priority 2: Count Pulse
            ELSIF count_pulse = '1' THEN
                s_count <= s_count + 1;
            END IF;

        END IF;
    END PROCESS;

    binary_count <= STD_LOGIC_VECTOR(s_count);

END rtl;
