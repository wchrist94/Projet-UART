
SRC = RxUnit.vhd\
      test_RxUnit_bit_parite_faux.vhd\
      test_RxUnit_bit_stop_faux.vhd\
      test_RxUnit_double_emission.vhd\
      test_RxUnit_normal.vhd\
      test_RxUnit_read_absent.vhd\
      echoUnit.vhd\
      diviseurClk.vhd\
      UART.vhd\
      UART_FPGA_N4.vhd\
      ctrlUnit.vhd\
      ../TxUnit/TxUnit.vhd\
      ../TxUnit/clkUnit/clkUnit.vhd

# for synthesis:
UNIT = UART_FPGA_N4
ARCH = synthesis
UCF = UART_FPGA_N4.ucf

# for simulation:
#TEST = test_RxUnit_bit_parite_faux
#TIME = 2000ns
#PLOT = output_bit_parite_faux

# for simulation:
#TEST = test_RxUnit_bit_stop_faux
#TIME = 2000ns
#PLOT = output_bit_stop_faux

# for simulation:
#TEST = test_RxUnit_read_absent
#TIME = 2000ns
#PLOT = output_read_absent

# for simulation:
#TEST = test_RxUnit_normal
#TIME = 2000ns
#PLOT = output_normal

# for simulation:
#TEST = test_RxUnit_double_emission
#TIME = 5000ns
#PLOT = output_double_emission