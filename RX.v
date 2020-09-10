module RX(clock, RX_en, RX,reset,data_ready,data,Pb_error,Sb_error);
input clock,RX_en,RX,reset;
output reg data_ready,Pb_error,Sb_error;
output reg [7:0] data;
//parameters 
parameter BR_count_width  = 5;
parameter BR_clock_cycles = 20;
parameter half_BR_clock_cycles =BR_clock_cycles/2 ;
//--------control signals----------------
reg BR_count_clear ,BR_count_on;
reg bit_count_clear;
reg Sb_error_ckeck, Pb_error_check;
reg sample_RX_data;
reg end_frame;
//-----------internal reg--------------
reg RX1,RX_sync,RX_sync_old;
reg [BR_count_width-1:0]BR_count; 
reg [2:0]bit_count;
reg bit_count_OF;

//------------internal wires--------------------- 
wire bit_trig,half_bit_trig;
wire parity_bit;
wire STb_check;
wire detect_negedge;
//------continuous assignment----------------------
assign bit_trig=(BR_count==BR_clock_cycles-1)? 1'b1:1'b0;
assign half_bit_trig=(BR_count==half_BR_clock_cycles-1)? 1'b1:1'b0;
assign parity_bit = ^ data;
assign STb_check =(RX_sync == 1'b0);
assign detect_negedge = RX_sync_old&(~RX_sync);
//-------parameters for FSM--------
reg [2:0]next_state,current_state;
parameter 
idle           =3'b000,
wait_frame     =3'b001,
start_recieve  =3'b010,
data_recieve   =3'b011,
parity_recieve =3'b100,
stop_recieve   =3'b101;	
//----------sequential part of FSM ---------------
always@(posedge clock or negedge reset)
begin
if(!reset) current_state <= idle;
else current_state<=next_state;
end 
//------FSM next state logic & output logic-------
always@(*)
begin
//defaut outputs
Pb_error_check=1'b0;
Sb_error_ckeck=1'b0;
BR_count_clear=1'b0;
BR_count_on=1'b1;
bit_count_clear=1'b0;
sample_RX_data=1'b0;
end_frame=1'b0;
case(current_state)
idle:
begin
	BR_count_on=1'b0;
	if(RX_en)
	begin
	next_state = wait_frame;
	BR_count_clear=1'b1;
	end
	
	else
	begin
	next_state = idle;
	end 
end
wait_frame:
begin
	if(detect_negedge)
	begin
	next_state=start_recieve;
	
	end
	
	else
	begin
	next_state = wait_frame;
	BR_count_on=1'b0;
	end
end
start_recieve:
begin
	if(half_bit_trig&&STb_check)
	begin
	next_state=data_recieve;
	BR_count_clear = 1'b1;
	bit_count_clear= 1'b1;
	end
	else if(half_bit_trig&& ~STb_check)
	begin
	next_state   =idle;
	BR_count_on=1'b0;
	end
	else 
	begin
	next_state= start_recieve;
	end
end

data_recieve:
begin 
	if(bit_trig && (!bit_count_OF))
	begin
	next_state = data_recieve;
	sample_RX_data= 1'b1;
	end
	
	else if(bit_trig && (bit_count_OF))
	begin
	next_state=parity_recieve;
	Pb_error_check=1'b1;
	end
	
	else
	begin
	next_state=data_recieve;
	end
end
parity_recieve:
begin 
	if(bit_trig)
	begin
	next_state=stop_recieve;
	Sb_error_ckeck=1'b1;
	end
	else
	begin
	next_state=parity_recieve;
	end
end
stop_recieve:
begin
	next_state=idle;
	end_frame=1'b1;
end
default:next_state=idle;
endcase

end
//-----Synchronize RX to the module clock----------
always@(posedge clock or negedge reset)
begin
if(!reset) begin RX1<=1'b0; RX_sync<=1'b0; end
else
begin
RX1<=RX;
RX_sync<=RX1;
RX_sync_old <= RX_sync;
end 
end
//-----Baud rate counter------------
always@(posedge clock or negedge reset)
begin
if(!reset) BR_count <= 0;
else if(BR_count_clear || bit_trig ) BR_count <= 0;
else if(BR_count_on)BR_count<=BR_count+1;
end
//------------bit counter---------------
always@(posedge clock or negedge reset)
begin
if(!reset || bit_count_clear) begin bit_count<=3'b0; bit_count_OF<=1'b0;  end
else if(bit_trig) {bit_count_OF,bit_count} <= bit_count+1'b1;
end
//---- Pb & Sb check-------------
always@(posedge clock or negedge reset)
begin
if(!reset)              Sb_error <=1'b0;  
else if(Sb_error_ckeck) Sb_error<=(RX_sync != 1'b1)? 1'b1:1'b0;

if(!reset)              Pb_error<=1'b0;
else if (Pb_error_check)Pb_error<=(RX_sync != parity_bit)? 1'b1:1'b0;
end
//------------data_out------------
always@(posedge clock or negedge reset)
begin
if(!reset) data<=8'b0;
else if(sample_RX_data) data[bit_count]<=RX_sync;
end



//------------data ready ----------
always@(posedge clock or negedge reset)
begin
if(!reset) data_ready<=1'b0;
else data_ready<=end_frame;
end
endmodule