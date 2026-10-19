module uart_rx #(
    parameter CLKS_PER_BIT = 5208
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       rx,

    output reg [7:0]  data_out,
    output reg        rx_done
);

    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;

    reg [1:0]  state;
    reg [31:0] baud_count;
    reg [2:0]  bit_count;
    reg [7:0]  data_reg;

    always @(posedge clk) begin

        if (rst) begin
            state      <= IDLE;
            baud_count <= 32'b0;
            bit_count  <= 3'b0;
            data_reg   <= 8'b0;
            data_out   <= 8'b0;
            rx_done    <= 1'b0;
        end

        else begin

            rx_done <= 1'b0;

            case (state)

                // --------------------------------
                // IDLE: wait for START bit
                // --------------------------------
                IDLE: begin

                    baud_count <= 32'b0;
                    bit_count  <= 3'b0;

                    if (rx == 1'b0) begin
                        state <= START;
                    end

                end


                // --------------------------------
                // START: sample middle of start bit
                // --------------------------------
                START: begin

                    if (baud_count == (CLKS_PER_BIT/2) - 1) begin

                        baud_count <= 32'b0;

                        if (rx == 1'b0) begin
                            state <= DATA;
                        end
                        else begin
                            state <= IDLE;
                        end

                    end

                    else begin
                        baud_count <= baud_count + 1'b1;
                    end

                end


                // --------------------------------
                // DATA: receive 8 bits
                // --------------------------------
                DATA: begin

                    if (baud_count == CLKS_PER_BIT - 1) begin

                        baud_count <= 32'b0;

                        data_reg[bit_count] <= rx;

                        if (bit_count == 3'd7) begin
                            bit_count <= 3'b0;
                            state <= STOP;
                        end

                        else begin
                            bit_count <= bit_count + 1'b1;
                        end

                    end

                    else begin
                        baud_count <= baud_count + 1'b1;
                    end

                end


                // --------------------------------
                // STOP: wait for stop bit
                // --------------------------------
                STOP: begin

                    if (baud_count == CLKS_PER_BIT - 1) begin

                        baud_count <= 32'b0;

                        data_out <= data_reg;
                        rx_done  <= 1'b1;

                        state <= IDLE;

                    end

                    else begin
                        baud_count <= baud_count + 1'b1;
                    end

                end


                default: begin

                    state      <= IDLE;
                    baud_count <= 32'b0;
                    bit_count  <= 3'b0;

                end

            endcase

        end

    end

endmodule
