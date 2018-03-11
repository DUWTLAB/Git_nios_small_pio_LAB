/*
 * =====================================================================================
 *
 *       Filename:  board_io.h
 *
 *    Description:  
 *
 *        Version:  1.0
 *        Created:  2018/3/9 10:58:24
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  YOUR NAME (), 
 *        Company:  
 *
 * =====================================================================================
 */

#ifndef  BOARD_IO_INC
#define  BOARD_IO_INC



unsigned read_pio_2();

unsigned read_pio_3();

void write_pio_0(unsigned int val);

void write_pio_1(unsigned int val);


#endif   /* ----- #ifndef BOARD_IO_INC  ----- */
