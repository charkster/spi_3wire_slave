# spi_3wire_slave
SystemVerilog implementation of a SPI 3 wire slave with a simple register map. Auto-increment reads and writes supported.

The first byte's most significant bit is the RNW, followed by a 7bit address (128 bytes can be addressed). If a write is being performed, write data follows the first byte. If a read is being performed, zero padding is needed. Note that read data is shifted by one nibble (4bits).

A standard 4wire SPI master can interface to this FPGA SPI 3wire slave.

![picture](https://github.com/charkster/spi_3wire_slave/blob/main/spi_4wire_to_3wire.png)

MicroPython example (included):

![picture](https://github.com/charkster/spi_3wire_slave/blob/main/micropython_spi_write_and_read.png)

Vivado simulation using tb_spi_3wire.sv testbench (included):

![picture](https://github.com/charkster/spi_3wire_slave/blob/main/spi_3wire_write_and_read.png)
