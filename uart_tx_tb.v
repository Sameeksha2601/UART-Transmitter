`timescale 1ns/1ps

module uart_tx_tb;

    reg        clk;
    reg        rst;
    reg        tx_start;
    reg [7:0]  data_in;

    wire       tx;
    wire       tx_busy;

    // Instantiate UART transmitter
    uart_tx #(
        .CLKS_PER_BIT(5208)
    ) uut (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .data_in(data_in),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    // 50 MHz clock
    // Period = 20 ns
    always #10 clk = ~clk;

    initial begin

        // Create waveform file
        $dumpfile("uart_tx.vcd");
        $dumpvars(0, uart_tx_tb);

        // Initial values
        clk      = 1'b0;
        rst      = 1'b1;
        tx_start = 1'b0;
        data_in  = 8'b0;

        // Reset
        #100;
        rst = 1'b0;

        // Data to transmit
        data_in = 8'b10110010;

        // Start transmission
        #20;
        tx_start = 1'b1;

        #20;
        tx_start = 1'b0;

        // Wait for complete transmission
        #1100000;

        // End simulation
        $finish;

    end

endmodule