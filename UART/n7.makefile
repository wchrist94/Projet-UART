
SRC = ../clkUnit/clkUnit.vhd
      ../TxUnit/TxUnit.vhd
      diviseurClk.vhd\
      echoUnit.vhd\
      RxUnit.vhd\
      ctrlUnit.vhd\
      UART.vhd\
      UART_FPGA_N4.vhd

# for synthesis:
UNIT = UART_FPGA_N4
ARCH = synthesis
UCF = UART_FPGA_N4.ucf