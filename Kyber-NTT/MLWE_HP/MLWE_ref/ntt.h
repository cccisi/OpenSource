#ifndef NTT_H
#define NTT_H

#include <stdint.h>

void ntt(uint16_t* poly);
void invntt(uint16_t* poly);

void eff_ntt_CT_intt_GS(uint16_t* poly,int index);

#endif
