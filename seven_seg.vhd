LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


ENTITY seven_seg_driver IS
    PORT (
      
        binary_in    : IN  STD_LOGIC_VECTOR(3 DOWNTO 0); 
        segments_out : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
END seven_seg_driver;

ARCHITECTURE rtl OF seven_seg_driver IS
BEGIN
    
    decoder_proc : PROCESS(binary_in)
    BEGIN
        
        CASE binary_in IS
            WHEN "0000" => segments_out <= "0000001"; -- 0
            WHEN "0001" => segments_out <= "1001111"; -- 1
            WHEN "0010" => segments_out <= "0010010"; -- 2
            WHEN "0011" => segments_out <= "0000110"; -- 3
            WHEN "0100" => segments_out <= "1001100"; -- 4
            WHEN "0101" => segments_out <= "0100100"; -- 5
            WHEN "0110" => segments_out <= "0100000"; -- 6
            WHEN "0111" => segments_out <= "0001111"; -- 7
            WHEN "1000" => segments_out <= "0000000"; -- 8
            WHEN "1001" => segments_out <= "0000100"; -- 9
            WHEN "1010" => segments_out <= "0001000"; -- A
            WHEN "1011" => segments_out <= "1100000"; -- b
            WHEN "1100" => segments_out <= "0110001"; -- C
            WHEN "1101" => segments_out <= "1000010"; -- d
            WHEN "1110" => segments_out <= "0110000"; -- E
            WHEN "1111" => segments_out <= "0111000"; -- F
            WHEN OTHERS => segments_out <= "1111111"; -- Off
        END CASE;
    END PROCESS;
END rtl;

