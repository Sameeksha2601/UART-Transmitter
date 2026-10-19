`timescale 1ns/1ps

module uart_rx_tb;

    reg        clk;
    reg        rst;
    reg        rx;

    wire [7:0] data_out;
    wire       rx_done;

    uart_rx #(
        .CLKS_PER_BIT(5208)
    ) uut (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .data_out(data_out),
        .rx_done(rx_done)
    );

    // 50 MHz clock
    always #10 clk = ~clk;

    // Send one UART bit
    task send_bit;
        input bit_value;
        begin
            rx = bit_value;
            #104160;
        end
    endtask

    initial begin

        $dumpfile("uart_rx.vcd");
        $dumpvars(0, uart_rx_tb);

        clk = 1'b0;
        rst = 1'b1;
        rx  = 1'b1;       // UART idle = HIGH

        #100;
        rst = 1'b0;

        // START bit
        send_bit(1'b0);

        // B2 = 10110010
        // UART sends LSB first
        send_bit(1'b0);   // D0
        send_bit(1'b1);   // D1
        send_bit(1'b0);   // D2
        send_bit(1'b0);   // D3
        send_bit(1'b1);   // D4
        send_bit(1'b1);   // D5
        send_bit(1'b0);   // D6
        send_bit(1'b1);   // D7

        // STOP bit
        send_bit(1'b1);

        #100000;

        $display("Received data = %h", data_out);

        $finish;

    end

endmodule
