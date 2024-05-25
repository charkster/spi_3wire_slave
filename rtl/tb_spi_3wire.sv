module tb_spi_3wire ();

   parameter EXT_CLK_PERIOD_NS = 83;
   parameter SCLK_PERIOD_NS = 83;
   
   reg  reset;
   reg  sclk;
   reg  ss_n;
   reg  sdata_out;
   reg  sdata_oe;
   wire sdata;
   
   bidir bidir_sdata
   (
    .pad    (sdata),     // inout
    .to_pad (sdata_out), // input
    .oe     (sdata_oe)   // input
    );

   task send_byte (input [7:0] byte_val);
      begin
         $display("Called send_byte task: given byte_val is %h",byte_val);
         sclk     = 1'b0;
         for (int i=7; i >= 0; i=i-1) begin
            $display("Inside send_byte for loop, index is %d",i);
            sdata_out = byte_val[i];
            #(SCLK_PERIOD_NS/2);
            sclk  = 1'b1;
            #(SCLK_PERIOD_NS/2);
            sclk  = 1'b0;
         end
      end
   endtask

   initial begin
      reset     = 1'b1;
      sclk      = 1'b0;
      ss_n      = 1'b1;
      sdata_oe  = 1'b1;
      sdata_out = 1'b0;
      #SCLK_PERIOD_NS;
      reset     = 1'b0;    
      $display("Write 1 byte to regmap address 0x00");
      #(SCLK_PERIOD_NS*8);
      ss_n      = 1'b0;
      #(SCLK_PERIOD_NS/2);
      sdata_oe  = 1'b1;
      send_byte(8'h00);
      send_byte(8'hE5);
      sdata_oe  = 1'b0;
      #(SCLK_PERIOD_NS/2);
      ss_n      = 1'b1;
      $display("Read 1 byte from regmap address 0x00");
      #(SCLK_PERIOD_NS*8);
      ss_n      = 1'b0;
      #(SCLK_PERIOD_NS/2);
      sdata_oe  = 1'b1;
      send_byte(8'h80);
      sdata_oe  = 1'b0;
      send_byte(8'h00);
      send_byte(8'h00);
      #(SCLK_PERIOD_NS/2);
      ss_n      = 1'b1;
      $display("Write 1 byte to regmap address 0x01");
      #(SCLK_PERIOD_NS*8);
      ss_n      = 1'b0;
      #(SCLK_PERIOD_NS/2);
      sdata_oe  = 1'b1;
      send_byte(8'h01);
      send_byte(8'h91);
      sdata_oe  = 1'b0;
      #(SCLK_PERIOD_NS/2);
      ss_n      = 1'b1;
      $display("Read 1 byte from regmap address 0x01");
      #(SCLK_PERIOD_NS*8);
      ss_n      = 1'b0;
      #(SCLK_PERIOD_NS/2);
      sdata_oe  = 1'b1;
      send_byte(8'h80);
      sdata_oe  = 1'b0;
      send_byte(8'h00);
      send_byte(8'h00);
      #(SCLK_PERIOD_NS/2);
      ss_n      = 1'b1;
      #10us;
      $finish;
   end

   spi_3wire_slave_regmap_top u_spi_3wire_slave_regmap_top
     ( .reset,
       .sclk,
       .ss_n,
       .sdata
       );

endmodule
