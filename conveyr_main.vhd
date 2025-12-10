LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use work.sevenseg.all;
use work.pcounter.all;

ENTITY conveyr IS
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
END conveyr;

ARCHITECTURE fsm_arch OF conveyr IS

    
    --------------------------------------------------------------------
    -- FSM STATES
    --------------------------------------------------------------------
    TYPE t_state IS (IDLE, MOVING, EMERGENCY_STOP);

    SIGNAL current_state : t_state := IDLE; -- initial state
    SIGNAL next_state    : t_state := IDLE;

    --------------------------------------------------------------------
    -- INTERNAL SIGNALS
    --------------------------------------------------------------------
    SIGNAL count_pulse       : STD_LOGIC := '0';
    SIGNAL clear_pulse       : STD_LOGIC := '0';
    SIGNAL count_value       : STD_LOGIC_VECTOR(3 DOWNTO 0);

    SIGNAL count_sensor_prev : STD_LOGIC := '0';
    SIGNAL clear_btn_prev    : STD_LOGIC := '0';
	 
	 signal product_detected   :STD_LOGIC := '0';
	 
	 signal obstacle_detected  : STD_LOGIC :=  '0';
	 
	signal count_filtered      : std_logic := '1';  -- debounced signal
	signal count_stable_cnt    : unsigned(17 downto 0) := (others => '0'); -- enough for 250k
	signal count_filtered_prev : std_logic := '1';


BEGIN

    --------------------------------------------------------------------
    -- GENERATE 1-CYCLE PULSE FROM count_sensor
    --------------------------------------------------------------------
  process(clk)
begin
    if rising_edge(clk) then
        
        -- ACTIVE LOW: detect when sensor == '0'
        if count_sensor = '0' and current_state = MOVING then
            if count_stable_cnt < 250000 then
                count_stable_cnt <= count_stable_cnt + 1;
            end if;
        else
            count_stable_cnt <= (others => '0');
        end if;

        -- After 5ms of continuous LOW → count_filtered goes LOW
        if count_stable_cnt = 250000 then
            count_filtered <= '0';
        else
            count_filtered <= '1';
        end if;

        -- Generate 1-cycle pulse when filtered signal goes 1 → 0
        count_filtered_prev <= count_filtered;

        if (count_filtered_prev = '1' and count_filtered = '0') then
            count_pulse <= '1';
        else
            count_pulse <= '0';
        end if;

    end if;
end process;
	
				 -- Sensor normalization
			product_detected  <= product_sensor;          -- Touch sensor, active HIGH
			--- counter_detected  <= not counter_sensor;      -- IR, active LOW → HIGH
			obstacle_detected <= not obstacle_sensor;     -- IR, active LOW → HIGH
			
	 

--------------------------------------------------------------------
    -- GENERATE 1-CYCLE PULSE FROM clear_button (Active Low Fix)
    --------------------------------------------------------------------
    gen_clear_pulse : PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            clear_btn_prev <= clear_btn;
            
            -- DETECT FALLING EDGE (1 -> 0)
            -- This happens exactly when you PUSH the button down.
            IF (clear_btn_prev = '1' AND clear_btn = '0') THEN
                clear_pulse <= '1';
            ELSE
                clear_pulse <= '0';
            END IF;
        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- PRODUCT COUNTER INSTANCE
    --------------------------------------------------------------------
    counter_inst : product_counter
        PORT MAP (
            clk          => clk,
            clear_pulse  => clear_pulse,
            count_pulse  => count_pulse,
            binary_count => count_value
        );

    --------------------------------------------------------------------
    -- SEVEN SEGMENT DISPLAY DRIVER INSTANCE
    --------------------------------------------------------------------
    seg_inst : seven_seg_driver
        PORT MAP (
            binary_in    => count_value,
            segments_out => segments_out
        );

    --------------------------------------------------------------------
    -- FSM STATE REGISTER (NO RESET)
    --------------------------------------------------------------------
    state_register : PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            current_state <= next_state;
        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- FSM TRANSITION LOGIC
    --------------------------------------------------------------------
    state_transition_logic : PROCESS(current_state, product_detected, obstacle_detected)
    BEGIN
        next_state <= current_state;

        CASE current_state IS

            WHEN IDLE =>
                IF product_detected = '1'AND obstacle_detected = '0' THEN
                    next_state <= MOVING;
                END IF;

            WHEN MOVING =>
                IF obstacle_detected = '1' THEN
                    next_state <= EMERGENCY_STOP;
                ELSIF product_detected = '0' THEN
                    next_state <= IDLE;
                END IF;

            WHEN EMERGENCY_STOP =>
                IF obstacle_detected = '0' and product_detected = '1' THEN
                    next_state <= MOVING;
					 ELSIF obstacle_detected = '0' THEN
						next_state <=IDLE;
                END IF;

        END CASE;
    END PROCESS;

    --------------------------------------------------------------------
    -- FSM OUTPUT LOGIC
    --------------------------------------------------------------------
   
	 output_logic : PROCESS(current_state)
    BEGIN
	 
        CASE current_state IS
        
            WHEN IDLE =>
                motor_out  <= '0';
                buzzer_out <= '0';

            WHEN MOVING =>
                motor_out  <= '1';
                buzzer_out <= '0';

            WHEN EMERGENCY_STOP =>
                motor_out  <= '0';
                buzzer_out <= '1';

        END CASE;
    END PROCESS;

END fsm_arch;