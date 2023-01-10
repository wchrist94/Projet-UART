
SRC = ../clkUnit/clkUnit.vhd
      ../TxUnit/TxUnit.vhd
      diviseurClk.vhd\
      echoUnit.vhd\
      RxUnit.vhd\
      ctrlUnit.vhd\
      UART.vhd\
      UART_FPGA_N4.vhd\
      compteur16.vhd\
      controleRecep.vhd\
      test_RxUnit.vhd

# for synthesis:
UNIT = UART_FPGA_N4
ARCH = synthesis
UCF = UART_FPGA_N4.ucf

# for simulation:
TEST = RxUnitTest
TIME = 10000ns
PLOT = output