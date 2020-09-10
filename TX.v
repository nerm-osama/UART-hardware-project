
module TX(clock,tx,tx_en,data_in,reset);
input clock,tx_en,reset;
input [7:0] data_in;
output reg tx;
//parameters 
parameter BR_count_width  = 5;
parameter BR_clock_cycles = 20;
//internal wires and reg 
reg [2:0] current_state, next_state;

reg [BR_count_width-1:0]BR_count;
reg [3:0]bit_count;
reg [7:0]data;
wire parity_bit;
//control signals
reg BR_count_on;
reg BR_count_clear;
reg [1:0]tx_sel;
reg bit_count_clear;
reg tx_change;
//flages and status signal
wire trig;

//states encoding
parameter 
idle=3'b000,
start=3'b001,
transmit=3'b010,
parity=3'b011,
stop=3'b100;
//continous assignment
assign parity_bit = ^ data ;//0 for even 1 for odd
assign trig = (BR_count == BR_clock_cycles - 1 )? 1'b1:1'b0 ;
//Next State and output logic FSM
always@(*)
begin
// default values for outputs
tx_sel=2'b01;
bit_count_clear=0; //bit_counter control signals
BR_count_clear=0; //BR_counter control signals
BR_count_on=1;
tx_change=1'b0;
case(current_state)
idle:	
begin
	if(tx_en)
	begin
	next_state=start;
	tx_sel=2'b00;
	tx_change=1'b1;
	bit_count_clear=1; //bit_counter control signals
	BR_count_clear=1; //BR_counter control signals
	BR_count_on=1;
	end
	
	else 
	begin
	next_state=idle;
	tx_sel=2'b01;
	tx_change=1'b1;
	BR_count_on=0;
	end 
end
start:
begin
	if(trig)
	begin
	next_state = transmit;
	tx_sel = 2'b10;
	tx_change=1'b1;
	end
	
	else
	begin
	next_state = start;
	end
end
transmit:
begin
	if(trig && bit_count <=7)
	begin
	next_state=transmit;
	tx_sel = 2'b10;
	tx_change=1'b1;
	end
	else if(trig && bit_count == 8)
	begin
	next_state=parity;
	tx_sel = 2'b11;
	tx_change=1'b1;
	bit_count_clear=1;
	end
	else
	begin
	next_state=transmit;
	end
end
parity:
begin
	if(trig)	
	begin
	next_state=stop;
	tx_sel= 2'b01;
	tx_change=1'b1;
	end
	else
	begin
	next_state=parity;
	end
end
stop:
begin
	if(trig)
	begin 
	next_state=idle;
	tx_sel=2'b01;
	tx_change=1'b1;
	end
	else
	begin
	next_state=stop;
	end
end
default:next_state=idle;
endcase
end
//sequential part of FSM
always@(posedge clock or negedge reset)
begin
if(!reset) current_state <= idle;
else
current_state <= next_state;
end
//data parallel in 
always@(posedge clock or negedge reset)
begin 
if(!reset) data <=8'b0;
else if (tx_en) data<=data_in;
end 
//baud rate generator counter
always@(posedge clock or negedge reset)
begin
if(!reset) BR_count <= 0;
else if(BR_count_clear || trig ) BR_count <= 0;
else if(BR_count_on)BR_count<=BR_count[4:0]+1;
end
//TX
always@(posedge clock)
begin
if(tx_change)
begin
case(tx_sel)
2'b00:tx<=1'b0;
2'b01:tx<=1'b1;
2'b10:tx<=data[bit_count];
2'b11:tx<=parity_bit;
endcase
end
end
//bit_counter
always@(posedge clock)
begin
if(bit_count_clear)bit_count <= 8'b0;
else if(trig) bit_count<=bit_count[2:0]+1;
end
endmodule