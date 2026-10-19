module uart_top #(
    parameter CLKS_PER_BIT = 5208
)(
    input  wire       clk,
    input  wire       rst,

    input  wire       tx_start,
    input  wire [7:0] tx_data,

    output wire       tx_busy,

    output wire [7:0] rx_data,
    output wire       rx_done
);

    wire serial_line;

    // UART Transmitter
    uart_tx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) transmitter (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .data_in(tx_data),
        .tx(serial_line),
        .tx_busy(tx_busy)
    );

    // UART Receiver
    uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) receiver (
        .clk(clk),
        .rst(rst),
        .rx(serial_line),
        .data_out(rx_data),
        .rx_done(rx_done)
    );

endmodule
