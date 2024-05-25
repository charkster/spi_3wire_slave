module spi_3wire_slave_regmap_top
  ( input  logic reset, // reset button
    input  logic sclk,  // SPI CLK
    input  logic ss_n,  // SPI CS_N
    inout  logic sdata  // MOSI/MISO combined
    );

  parameter MAX_ADDRESS = 7'd127;

  logic       rst_n;
  logic       rst_n_sync;
  logic       rst_n_spi;
  logic [4:0] bit_count;
  logic       rnw;
  logic [6:0] addr;
  logic       sdata_out;
  logic       sdata_oe;
  logic [7:0] write_data;
  logic [7:0] read_data;
  logic [7:0] hold_read_data;
  logic       read_pulse;
  logic       write_pulse;
  
  logic [7:0] registers[127:0]; // 128 bytes
  
  assign rst_n = !reset;

//  synchronizer u_synchronizer_rst_n_sync
//   ( .clk      (sclk),
//     .rst_n    (rst_n),
//     .data_in  (1'b1),
//     .data_out (rst_n_sync)
//     );

  assign rst_n_sync = rst_n; // don't synchronize for now

  bidir bidir_sdata
  (
   .pad    (sdata),     // inout
   .to_pad (sdata_out), // input
   .oe     (sdata_oe)   // input
   );

  assign rst_n_spi = rst_n && !ss_n; // clear the SPI when the chip_select is inactive
   
  always_ff @(posedge sclk, negedge rst_n_spi)
    if (~rst_n_spi)                         bit_count <= 'd0;
    else if ((!rnw) && (bit_count == 'd15)) bit_count <= 'd8; // allow for address auto increment on write
    else if (  rnw  && (bit_count == 'd18)) bit_count <= 'd11; // allow for address auto increment on read
    else                                    bit_count <= bit_count + 1;
    
  always_ff @(posedge sclk, negedge rst_n_spi)
     if (~rst_n_spi)              rnw <= 1'd0;
     else if ((bit_count == 'd0)) rnw <= sdata;

   always_ff @(posedge sclk, negedge rst_n_spi)
     if (~rst_n_spi)                                    addr <= 7'd0;
     else if ((bit_count >= 'd1) && (bit_count <= 'd7)) addr <= {addr[5:0],sdata};
     else if (bit_count == 'd15)                        addr <= addr + 1'd1; // auto increment both read and write
   
   always_ff @(posedge sclk, negedge rst_n_spi)
     if (~rst_n_spi)                      write_data <= 8'd0;
     else if (!rnw && (bit_count >= 'd8)) write_data <= {write_data[6:0],sdata};
   
   assign write_pulse = (bit_count == 'd15) && (!rnw);

   // NOTE: registers are only reset by button press, not the CS_N pin
   integer i;
   always_ff @(posedge sclk, negedge rst_n_sync)
     if (~rst_n_sync)     for (i=0; i<=MAX_ADDRESS; i=i+1) registers[i]    <= 8'h00;
     else if (write_pulse)                                 registers[addr] <= {write_data[6:0],sdata}; // last bit might be last SCLK posedge

   always_comb
     read_data = registers[addr];
   
   assign read_pulse = ((bit_count == 'd10) || (bit_count == 'd18)) && rnw; // addr is updated on bit_count == 15
   
   always_ff @(posedge sclk, negedge rst_n_spi)
     if (~rst_n_spi)      hold_read_data <= 8'd0;
     else if (read_pulse) hold_read_data <= read_data;
   
   assign sdata_oe = (bit_count >= 'd9) && rnw;
   
   always_ff @(posedge sclk, negedge rst_n_spi)
     if (~rst_n_spi)                sdata_out <= 1'd0;
     else if (rnw) case(bit_count)
                              'd11: sdata_out <= hold_read_data[7];
                              'd12: sdata_out <= hold_read_data[6];
                              'd13: sdata_out <= hold_read_data[5];
                              'd14: sdata_out <= hold_read_data[4];
                              'd15: sdata_out <= hold_read_data[3];
                              'd16: sdata_out <= hold_read_data[2];
                              'd17: sdata_out <= hold_read_data[1];
                              'd18: sdata_out <= hold_read_data[0];
                         endcase
     else                           sdata_out <= 1'b0;

endmodule
