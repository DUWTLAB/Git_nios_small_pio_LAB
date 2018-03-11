#include <stdio.h>

#include "system.h"
#include "io.h"
#include "board_io.h"

#define DEBUG_EN    0

int main()
{ 
  unsigned int u32_pio_2_rd = 0, u32_pio_2_rd_old = 0;
  unsigned int u32_pio_3_rd = 0, u32_pio_3_rd_old = 0;

  /* Event loop never exits. */
  while (1)
  { 
    u32_pio_2_rd_old = u32_pio_2_rd;
    u32_pio_2_rd     = read_pio_2(); 

    u32_pio_3_rd_old = u32_pio_3_rd ; 
    u32_pio_3_rd     = read_pio_3(); 
    
    if(u32_pio_2_rd != u32_pio_2_rd_old){
      write_pio_0((u32_pio_2_rd&0xf));
# if (DEBUG_EN)
      printf("u32_pio_2_rd = %d\n", u32_pio_2_rd);
#endif
    }
    if(u32_pio_3_rd != u32_pio_3_rd_old){
      write_pio_1((u32_pio_3_rd&0xf));
# if (DEBUG_EN)
      printf("u32_pio_3_rd = %d\n", u32_pio_3_rd);
#endif
    }
    
  }

  return 0;
}
