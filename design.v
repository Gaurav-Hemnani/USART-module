module UART_module(
	input wire clk,
	input wire rst,
	input wire start,
	input wire [7:0] data_in,
	output reg tx,
	output wire busy
);

	reg [2:0] state = 3'b000;
	reg [7:0] tx_data = 8'h00;
	reg [3:0] count = 4'b0000;
	
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			state <= 3'b000;
			count <= 4'b0000;
		end else begin
			case(state)
				3'b000: begin //Idle
					tx_data <= data_in;
					if (start)
						state <= 3'b001;
				end
				3'b001: begin //Start bit
					tx <= 0;
					state <= 3'b010;
				end
				3'b010: begin //Data bits
					tx <= tx_data[0];
					tx_data <= tx_data >> 1;
					count <= count + 1;
					if (count == 3)
						state <= 3'b011;
				end
				3'b011: begin //Stop bit
					tx <= 1;
					state <= 3'b000;
					count <= 4'b0000;
				end
			endcase
		end
	end
	
	assign busy = (state != 3'b000);

endmodule