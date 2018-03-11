
#include "system.h"
#include "io.h"


unsigned read_pio_2(){
  return  IORD(PIO_2_IN_BASE, 0); 
}

unsigned read_pio_3(){
  return  IORD(PIO_3_IN_BASE, 0); 
}

void write_pio_0(unsigned int val){
  IOWR(PIO_0_OUT_BASE, 0, val );
}

void write_pio_1(unsigned int val){
  IOWR(PIO_1_OUT_BASE, 0, val );
}

