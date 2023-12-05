library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
-- RS232 Protocol Serial UART 
entity lab06 is
	port(
		clk: in    std_logic;
		rx:  in    std_logic;
		tx:  out   std_logic;
		srx: out   std_logic;-- PIC pin 9 RS-232
		stx: in    std_logic;-- PIC pin 10 RS-232
		nss: out   std_logic;-- PIC pin 11 SPI
		sck: out   std_logic;-- PIC pin 12 SPI
		sdi: out   std_logic;-- PIC pin 4 SPI
		sdo: in    std_logic;-- PIC pin 3 SPI
		scl: inout std_logic;-- PIC pin 6 I2C
		sda: inout std_logic -- PIC pin 5 I2C
	);
end lab06;

architecture arch of lab06 is
	component lab06_gui
		port(
			clk:    in  std_logic;
			rx:     in  std_logic;
			tx:     out std_logic;
			data_i: in  std_logic_vector(7 downto 0);
			data_o: out std_logic_vector(7 downto 0);
			trig_o: out std_logic
		);
	end component;
	signal data_i: std_logic_vector(7 downto 0);
	signal data_o: std_logic_vector(7 downto 0);
	signal trig_o: std_logic;
	type FSM_type is (idle, start, transfer, stop);
	signal counter: integer:= 0;
	signal bitsend: integer:= 0;
	signal FSM: FSM_type;
begin
	gui: lab06_gui port map(clk=>clk,rx=>rx,tx=>tx,
		data_i=>data_i,data_o=>data_o,trig_o=>trig_o);

	-- Example default state of FPGA outputs
	--srx<='1';
	nss<='1';
	sck<='0';
	sdi<='0';
	scl<='Z';
	sda<='Z';

	process(clk)
	begin
		case FSM is 
			when idle =>
				 if (trig_o='1') then
	                   FSM <= start;
	        
	                   srx <= data_o(7);
	               end if;

			when start =>
				
				index <= 0;
				FSM <= transfer;
			when transfer =>
				if(bitsend = 0) then
					bitsend <= 105;
					srx <= data_o(7-index);
				index <= index + 1;
				if (index = 7) then
					FSM <= stop;
				end if;
				else 
					bitsend <= bitsend - 1;
					FSM <= transfer;
				end if;
				

			when stop =>
				bitsend <= 0;
				index <= 0;
				FSM <= idle;
		end case;

	end process;
end arch;
