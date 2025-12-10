
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY tb_conveyor_simple IS
END tb_conveyor_simple;

ARCHITECTURE sim OF tb_conveyor_simple IS

    -- COMPONENT DECLARATION
    -- (This must match your conveyr entity EXACTLY)
    COMPONENT conveyr
        PORT (
            clk             : IN  STD_LOGIC;
            product_sensor  : IN  STD_LOGIC;
            count_sensor    : IN  STD_LOGIC;
            obstacle_sensor : IN  STD_LOGIC;
            clear_btn       : IN  STD_LOGIC;
            motor_out       : OUT STD_LOGIC;
            buzzer_out      : OUT STD_LOGIC;
            segments_out    : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
        );
    END COMPONENT;

    -- SIGNALS
    SIGNAL clk             : STD_LOGIC := '0';
    SIGNAL product_sensor  : STD_LOGIC := '0'; -- Idle (Assuming Active High)
    SIGNAL count_sensor    : STD_LOGIC := '1'; -- Idle (Assuming Active Low)
    SIGNAL obstacle_sensor : STD_LOGIC := '1'; -- Idle (Assuming Active Low)
    SIGNAL clear_btn       : STD_LOGIC := '1'; -- Idle (Assuming Active Low)

    -- OUTPUTS
    SIGNAL motor_out       : STD_LOGIC;
    SIGNAL buzzer_out      : STD_LOGIC;
    SIGNAL segments_out    : STD_LOGIC_VECTOR(6 DOWNTO 0);

    -- CLOCK PERIOD
    CONSTANT CLK_PERIOD : time := 20 ns;

BEGIN

    -- INSTANTIATION
    uut: conveyr
        PORT MAP (
            clk             => clk,
            product_sensor  => product_sensor,
            count_sensor    => count_sensor,
            obstacle_sensor => obstacle_sensor,
            clear_btn       => clear_btn,
            motor_out       => motor_out,
            buzzer_out      => buzzer_out,
            segments_out    => segments_out
        );

    -- CLOCK PROCESS
    clk_process : PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR CLK_PERIOD / 2;
        clk <= '1';
        WAIT FOR CLK_PERIOD / 2;
    END PROCESS;

    -- STIMULUS PROCESS
    stim_proc: PROCESS
    BEGIN
        -- 1. Initialize
        WAIT FOR 100 ns;
        
        -- 2. Simulate Product Touch (Start Belt)
        product_sensor <= '1'; -- Touch
        WAIT FOR 2 ms;         -- Hold for debounce
        product_sensor <= '0'; -- Release
        WAIT FOR 2 ms;

        -- 3. Simulate Product Counting (Active Low Pulse)
        count_sensor <= '0';   -- Object detected
        WAIT FOR 10 ms;
        count_sensor <= '1';   -- Object leaves
        WAIT FOR 10 ms;

        -- 4. Simulate Obstacle (Emergency Stop)
        obstacle_sensor <= '0'; -- Obstacle detected
        WAIT FOR 5 ms;
        obstacle_sensor <= '1'; -- Obstacle removed
        WAIT FOR 5 ms;

        -- 5. End Simulation
        WAIT;
    END PROCESS;

END sim;