LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

PACKAGE sevenseg IS
    COMPONENT seven_seg_driver
        PORT (
            binary_in    : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
            segments_out : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
        );
    END COMPONENT;
END PACKAGE sevenseg;
