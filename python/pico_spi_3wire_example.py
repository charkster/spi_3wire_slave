import machine

spi = machine.SPI(0,
                  baudrate=1000000,
                  polarity=1,
                  phase=1,
                  bits=8,
                  firstbit=machine.SPI.MSB,
                  sck=machine.Pin(2),
                  mosi=machine.Pin(3),
                  miso=machine.Pin(4))

spi_cs = machine.Pin(1, machine.Pin.OUT)
spi_cs.value(1) # active low

# buffer for echoed write data
write_bytes = bytearray([0x00] * 2)

print("Write to Address 0x00 Data 0xE5")
spi_cs.value(0)
spi.write_readinto(bytearray([0x00, 0xE5]),write_bytes)
spi_cs.value(1) 
print(list(map(hex, write_bytes)))

# buffer for echoed first write byte and then two bytes read data
read_bytes = bytearray([0x00] * 3)

print("Read from Address 0x00")
spi_cs.value(0)
spi.write_readinto(bytearray([0x80, 0x00, 0x00]),read_bytes)
spi_cs.value(1) 
print(list(map(hex, read_bytes)))
