module UART_module_tb();

    // Inputs
    reg clk;
    reg rst;
    reg start;
    reg [7:0] data_in;
    
    // Outputs
    wire tx;
    wire busy;
    
    // Instantiate the DUT (Device Under Test)
    UART_module uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .data_in(data_in),
        .tx(tx),
        .busy(busy)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Generate 100 MHz clock (10 ns period)
    end
    
    // Task to simulate a UART data transfer
    task send_uart_data(input [7:0] data);
        begin
            @(posedge clk); // Wait for clock edge
            start = 1;
            data_in = data;
            @(posedge clk);
            start = 0;
            wait (busy == 0); // Wait until UART is not busy
        end
    endtask
    
    // Test procedure
    initial begin
        // Initialize inputs
        rst = 1;
        start = 0;
        data_in = 8'b0;
        
        // Apply reset
        #20;
        rst = 0;
        
        // Test Case 1: Send a byte of data (e.g., 8'hA5)
        $display("Test Case 1: Sending 0xA5");
        send_uart_data(8'hA5);
        
        // Test Case 2: Send another byte of data (e.g., 8'h3C)
        $display("Test Case 2: Sending 0x3C");
        send_uart_data(8'h3C);
        
        // Test Case 3: Send data during busy state (should wait for completion)
        $display("Test Case 3: Sending 0xFF");
        send_uart_data(8'hFF);
        
        // End simulation
        #100;
        $display("Simulation Completed");
        $finish;
    end
    
    // Monitor outputs
    initial begin
        $monitor("Time=%0t | clk=%b | rst=%b | start=%b | data_in=0x%h | tx=%b | busy=%b", 
                 $time, clk, rst, start, data_in, tx, busy);
    end

    initial begin
      $dumpfile("dump.vcd");
      $dumpvars(0);
    end

endmodule
