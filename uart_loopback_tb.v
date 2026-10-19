`timescale 1ns/1ps

module uart_loopback_tb;

    reg        clk;
    reg        rst;

    reg        tx_start;
    reg [7:0]  data_in;

    wire       tx;
    wire       tx_busy;

    wire [7:0] data_out;
    wire       rx_done;


    // ---------------------------------------
    // UART TRANSMITTER
    // ---------------------------------------

    uart_tx #(
        .CLKS_PER_BIT(5208)
    ) transmitter (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .data_in(data_in),
        .tx(tx),
        .tx_busy(tx_busy)
    );


    // ---------------------------------------
    // UART RECEIVER
    // TX output connected directly to RX
    // ---------------------------------------

    uart_rx #(
        .CLKS_PER_BIT(5208)
    ) receiver (
        .clk(clk),
        .rst(rst),
        .rx(tx),
        .data_out(data_out),
        .rx_done(rx_done)
    );


    // 50 MHz clock
    always #10 clk = ~clk;


    // ---------------------------------------
    // TEST
    // ---------------------------------------

    initial begin

        $dumpfile("uart_loopback.vcd");
        $dumpvars(0, uart_loopback_tb);

        clk      = 1'b0;
        rst      = 1'b1;
        tx_start = 1'b0;
        data_in  = 8'h00;

        // Reset
        #100;
        rst = 1'b0;

        // Send B2
        data_in = 8'hB2;

        #20;
        tx_start = 1'b1;

        #20;
        tx_start = 1'b0;

        // Wait for complete transmission
        #1200000;

        $display("=================================");
        $display("TX DATA = %h", data_in);
        $display("RX DATA = %h", data_out);
        $display("=================================");

        if (data_out == data_in)
            $display("LOOPBACK TEST PASSED!");
        else
            $display("LOOPBACK TEST FAILED!");

        $finish;

    end

endmodule
