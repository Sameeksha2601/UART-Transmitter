module uart_tx #(
    parameter CLKS_PER_BIT = 5208
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       tx_start,
    input  wire [7:0] data_in,
    output wire       tx,
    output wire       tx_busy
);

    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;

    reg [1:0]  state;
    reg [7:0]  data_reg;
    reg [2:0]  bit_count;
    reg [31:0] baud_count;

    assign tx =
        (state == START) ? 1'b0 :
        (state == DATA)  ? data_reg[bit_count] :
                           1'b1;

    assign tx_busy = (state != IDLE);

    always @(posedge clk) begin
        if (rst) begin
            state      <= IDLE;
            data_reg   <= 8'b0;
            bit_count  <= 3'b0;
            baud_count <= 32'b0;
        end
        else begin
            case (state)

                IDLE: begin
                    baud_count <= 32'b0;
                    bit_count  <= 3'b0;

                    if (tx_start) begin
                        data_reg <= data_in;
                        state    <= START;
                    end
                end

                START: begin
                    if (baud_count == CLKS_PER_BIT - 1) begin
                        baud_count <= 32'b0;
                        bit_count  <= 3'b0;
                        state      <= DATA;
                    end
                    else begin
                        baud_count <= baud_count + 1'b1;
                    end
                end

                DATA: begin
                    if (baud_count == CLKS_PER_BIT - 1) begin
                        baud_count <= 32'b0;

                        if (bit_count == 3'd7) begin
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

                STOP: begin
                    if (baud_count == CLKS_PER_BIT - 1) begin
                        baud_count <= 32'b0;
                        state      <= IDLE;
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