module geofence ( clk,reset,X,Y,valid,is_inside);
input clk;
input reset;
input [9:0] X;
input [9:0] Y;
output reg valid;
output reg is_inside;
//reg valid;
//reg is_inside;

parameter IDLE = 0,R_data = 1,SORT = 2,CMP = 3,OUT = 4;
reg[2:0]state,next_state;
reg[2:0]counter;
reg switch;

always @(posedge clk or posedge reset) begin
	if (reset) begin
		// reset
		counter <= 1'b0;
	end
	else begin
		case(state)
		R_data:begin
			if (counter == 3'd6) begin
				counter <= 1'b0;
			end
			else begin
				counter <= counter + 1;
			end
		end
		SORT:begin
			if(counter == 3'd4)
				counter <= 0;
			else begin
				counter <= counter + 1;
			end
		end
		CMP:begin
			if(counter == 5)
				counter <= 0;
			else
				counter <= counter +1;
		end
		OUT:begin
			if(counter == 1)
				counter <= 0;
			else
				counter <= counter + 1;
		end
	    default:
	    	counter <= counter;
		endcase
	end
end

always @(posedge clk or posedge reset) begin
	if (reset) begin
		// reset
		state <= R_data;
	end
	else begin
		state <= next_state;
	end
end

always @(*) begin
	case(state)
		IDLE:begin
			next_state = R_data;
		end
		R_data:begin
			if(counter == 3'd6 )
				next_state = SORT;
			else
				next_state = R_data;
		end
		SORT:begin
			if(counter == 3'd4)
				next_state = CMP;
			else begin
				next_state = SORT;
			end
		end
		CMP:begin
			if(counter == 5)
				next_state = OUT;
			else
				next_state = CMP;
		end
		OUT:begin
			if(counter == 1)
				next_state = R_data;
			else
				next_state = OUT;
		end
		default:begin
			next_state = IDLE;
		end
	endcase
end

/* read data*/
reg[9:0] x_temp[0:6];
reg[9:0] y_temp[0:6];

/*calculate vector*/
reg signed [10:0] vector_x[0:4];
reg signed [10:0] vector_y[0:4];

integer i;
always @(posedge clk or posedge reset) begin
	if (reset) begin
		// reset
		for(i = 0;i<7;i=i+1)begin
			x_temp[i] <= 1'b0;
		end

		for(i = 0;i<5;i=i+1)begin
			vector_x[i] <= 1'b0;
		end
	end
	else begin
		case(state)
		R_data:begin
			x_temp[counter] <= X;
			if(counter >= 2)begin
				for(i = 0;i<5;i=i+1)begin
					vector_x[counter-2+i] <= X - x_temp[1];
		    	end
			end
			else begin
		    	vector_x[counter] <= vector_x[counter];
			end
		end
		
		SORT:begin
			if(!switch)begin
				for(i=0;i<3;i=i+2)begin
					if ((vector_x[i]*vector_y[i+1] - vector_y[i]*vector_x[i+1]) > 0) begin
						x_temp[i+2] <= x_temp[i+3];
						x_temp[i+3] <= x_temp[i+2];
						vector_x[i] <= vector_x[i+1];
						vector_x[i+1] <= vector_x[i]; 
					end
					else begin
						x_temp[i+2] <= x_temp[i+2];
						x_temp[i+3] <= x_temp[i+3];
						vector_x[i] <= vector_x[i];
						vector_x[i+1] <= vector_x[i+1]; 
					end
				end
			end
			else begin
				for(i=1;i<4;i=i+2)begin
					if ((vector_x[i]*vector_y[i+1] - vector_y[i]*vector_x[i+1]) > 0) begin
						x_temp[i+2] <= x_temp[i+3];
						x_temp[i+3] <= x_temp[i+2];
						vector_x[i] <= vector_x[i+1];
						vector_x[i+1] <= vector_x[i]; 
					end
					else begin
						x_temp[i+2] <= x_temp[i+2];
						x_temp[i+3] <= x_temp[i+3];
						vector_x[i] <= vector_x[i];
						vector_x[i+1] <= vector_x[i+1]; 
					end
				end
			end
		end
		
		default:begin
			for(i = 0;i<7;i=i+1)begin
				x_temp[i] <= x_temp[i];
		    end

		    for(i = 0;i<5;i=i+1)begin
				vector_x[i] <= vector_x[i];
			end
		end
		endcase
	end
end

always @(posedge clk or posedge reset) begin
	if (reset) begin
		// reset
		for(i = 0;i<7;i=i+1)begin
			y_temp[i] <= 0;
		end

		for(i = 0;i<5;i=i+1)begin
			vector_y[i] <= 0;
		end
	end
	else begin
		case(state)
		R_data:begin
			y_temp[counter] <= Y;
			if(counter >= 2)begin
				for(i = 0;i<5;i=i+1)begin
					vector_y[counter-2+i] <= Y - y_temp[1];
		    	end
			end
			else begin
		    	vector_y[counter] <= vector_y[counter];
			end
		end
		SORT:begin
			if(!switch)begin
				for(i=0;i<3;i=i+2)begin
					if ((vector_x[i]*vector_y[i+1] - vector_y[i]*vector_x[i+1]) > 0) begin
						y_temp[i+2] <= y_temp[i+3];
						y_temp[i+3] <= y_temp[i+2];
						vector_y[i] <= vector_y[i+1];
						vector_y[i+1] <= vector_y[i]; 
					end
					else begin
						y_temp[i+2] <= y_temp[i+2];
						y_temp[i+3] <= y_temp[i+3];
						vector_y[i] <= vector_y[i];
						vector_y[i+1] <= vector_y[i+1]; 
					end
				end
			end
			else begin
				for(i=1;i<4;i=i+2)begin
					if ((vector_x[i]*vector_y[i+1] - vector_y[i]*vector_x[i+1]) > 0) begin
						y_temp[i+2] <= y_temp[i+3];
						y_temp[i+3] <= y_temp[i+2];
						vector_y[i] <= vector_y[i+1];
						vector_y[i+1] <= vector_y[i]; 
					end
					else begin
						y_temp[i+2] <= y_temp[i+2];
						y_temp[i+3] <= y_temp[i+3];
						vector_y[i] <= vector_y[i];
						vector_y[i+1] <= vector_y[i+1]; 
					end
				end
			end
		end
		default:begin
			for(i = 0;i<7;i=i+1)begin
				y_temp[i] <= y_temp[i];
		    end
		end
		endcase
	end
end

always @(posedge clk or posedge reset) begin
	if (reset) begin
		// reset
		switch <= 0;
	end
	else begin
		case(state)
		SORT:begin
			switch <= ~switch;
			// if(counter >= 1)
			// 	switch <= ~switch;
			// else begin
			// 	switch <= switch;
			// end
		end
		default:
			switch <= switch;
		endcase
	end
end

reg signed[10:0] cal_x1,cal_x2;
reg signed[10:0] cal_y1,cal_y2;
always @(posedge clk or posedge reset) begin
	if (reset) begin
		// reset
		cal_x1 <= 0;
	end
	else begin
		case(state)
		CMP:begin
			cal_x1 <= x_temp[counter + 1] - x_temp[0];
		end
		default:
			cal_x1 <= cal_x1;
		endcase
	end
end

always @(posedge clk or posedge reset) begin
	if (reset) begin
		// reset
		cal_x2 <= 0;
	end
	else begin
		case(state)
		CMP:begin
			if(counter < 5)
				cal_x2 <= x_temp[counter + 2] - x_temp[counter + 1];
			else
				cal_x2 <= x_temp[1] - x_temp[counter + 1];
		end
		default:
			cal_x2 <= cal_x2;
		endcase
	end
end

always @(posedge clk or posedge reset) begin
	if (reset) begin
		// reset
		cal_y1 <= 0;
	end
	else begin
		case(state)
		CMP:begin
			cal_y1 <= y_temp[counter + 1] - y_temp[0];
		end
		default:
			cal_y1 <= cal_y1;
		endcase
	end
end

always @(posedge clk or posedge reset) begin
	if (reset) begin
		// reset
		cal_y2 <= 0;
	end
	else begin
		case(state)
		CMP:begin
			if(counter < 5)
				cal_y2 <= y_temp[counter + 2] - y_temp[counter + 1];
			else
				cal_y2 <= y_temp[1] - y_temp[counter + 1];
		end
		default:
			cal_y2 <= cal_y2;
		endcase
	end
end

reg[2:0] result_cnt;
always @(posedge clk or posedge reset) begin
	if (reset) begin
		// reset
		result_cnt <= 0;
	end
	else begin
		case(state)
		R_data:begin
			result_cnt <= 0;
		end
		CMP:begin
			if(counter > 0)begin
				if((cal_x1*cal_y2 - cal_y1*cal_x2) > 0)
					result_cnt <= result_cnt + 1;
				else begin
					result_cnt <= result_cnt;
				end
			end
			else begin
				result_cnt <= result_cnt;
			end
		end
		default:
			result_cnt <= result_cnt;
		endcase
	end
end

always @(posedge clk or posedge reset) begin
	if (reset) begin
		// reset
		is_inside <= 0;
	end
	else begin
		case(state)
		OUT:begin
			if((result_cnt == 6) || (result_cnt == 0))
				is_inside <= 1;
			else
				is_inside <= 0;
		end
		default:
			is_inside <= is_inside;
		endcase
	end
end

always @(posedge clk or posedge reset) begin
	if (reset) begin
		// reset
		valid <= 0;
	end
	else begin
		case(state)
		OUT:begin
			if(counter == 0)
				valid <= 1;
			else
				valid <= 0;
		end
		default:
			valid <= 0;
		endcase
	end
end
endmodule

