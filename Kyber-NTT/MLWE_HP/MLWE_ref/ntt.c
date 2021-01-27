#include "inttypes.h"
#include "ntt.h"
#include "params.h"
#include "reduce.h"
#include <stdio.h>

extern const uint16_t omegas_inv_bitrev_montgomery[];
extern const uint16_t psis_inv_montgomery[];
extern const uint16_t zetas[];

extern const uint16_t bvpsi_7681_256[];
extern const uint16_t invpsi_7681_256[];

static const unsigned char BitReverseTable256[] =
{
  0x00, 0x80, 0x40, 0xC0, 0x20, 0xA0, 0x60, 0xE0, 0x10, 0x90, 0x50, 0xD0, 0x30, 0xB0, 0x70, 0xF0,
  0x08, 0x88, 0x48, 0xC8, 0x28, 0xA8, 0x68, 0xE8, 0x18, 0x98, 0x58, 0xD8, 0x38, 0xB8, 0x78, 0xF8,
  0x04, 0x84, 0x44, 0xC4, 0x24, 0xA4, 0x64, 0xE4, 0x14, 0x94, 0x54, 0xD4, 0x34, 0xB4, 0x74, 0xF4,
  0x0C, 0x8C, 0x4C, 0xCC, 0x2C, 0xAC, 0x6C, 0xEC, 0x1C, 0x9C, 0x5C, 0xDC, 0x3C, 0xBC, 0x7C, 0xFC,
  0x02, 0x82, 0x42, 0xC2, 0x22, 0xA2, 0x62, 0xE2, 0x12, 0x92, 0x52, 0xD2, 0x32, 0xB2, 0x72, 0xF2,
  0x0A, 0x8A, 0x4A, 0xCA, 0x2A, 0xAA, 0x6A, 0xEA, 0x1A, 0x9A, 0x5A, 0xDA, 0x3A, 0xBA, 0x7A, 0xFA,
  0x06, 0x86, 0x46, 0xC6, 0x26, 0xA6, 0x66, 0xE6, 0x16, 0x96, 0x56, 0xD6, 0x36, 0xB6, 0x76, 0xF6,
  0x0E, 0x8E, 0x4E, 0xCE, 0x2E, 0xAE, 0x6E, 0xEE, 0x1E, 0x9E, 0x5E, 0xDE, 0x3E, 0xBE, 0x7E, 0xFE,
  0x01, 0x81, 0x41, 0xC1, 0x21, 0xA1, 0x61, 0xE1, 0x11, 0x91, 0x51, 0xD1, 0x31, 0xB1, 0x71, 0xF1,
  0x09, 0x89, 0x49, 0xC9, 0x29, 0xA9, 0x69, 0xE9, 0x19, 0x99, 0x59, 0xD9, 0x39, 0xB9, 0x79, 0xF9,
  0x05, 0x85, 0x45, 0xC5, 0x25, 0xA5, 0x65, 0xE5, 0x15, 0x95, 0x55, 0xD5, 0x35, 0xB5, 0x75, 0xF5,
  0x0D, 0x8D, 0x4D, 0xCD, 0x2D, 0xAD, 0x6D, 0xED, 0x1D, 0x9D, 0x5D, 0xDD, 0x3D, 0xBD, 0x7D, 0xFD,
  0x03, 0x83, 0x43, 0xC3, 0x23, 0xA3, 0x63, 0xE3, 0x13, 0x93, 0x53, 0xD3, 0x33, 0xB3, 0x73, 0xF3,
  0x0B, 0x8B, 0x4B, 0xCB, 0x2B, 0xAB, 0x6B, 0xEB, 0x1B, 0x9B, 0x5B, 0xDB, 0x3B, 0xBB, 0x7B, 0xFB,
  0x07, 0x87, 0x47, 0xC7, 0x27, 0xA7, 0x67, 0xE7, 0x17, 0x97, 0x57, 0xD7, 0x37, 0xB7, 0x77, 0xF7,
  0x0F, 0x8F, 0x4F, 0xCF, 0x2F, 0xAF, 0x6F, 0xEF, 0x1F, 0x9F, 0x5F, 0xDF, 0x3F, 0xBF, 0x7F, 0xFF
};

/*************************************************
* Name:        reverse
*
* Description: Computes
* Arguments:   - uint16_t *p: pointer to in/output polynomial
**************************************************/
int reverse(int x)
{
    int o;
    unsigned char x_char; // 8 bits at time
    unsigned char o_char;

    // Option 1:
    x_char = (unsigned char)x;
    o_char = BitReverseTable256[x_char];
    o = (int)o_char;

    return o;
}

/* Forward NTT, normal to bitreversed order */
void ntt(uint16_t *p)
{
  int level, start, j, k;
  uint16_t zeta, t;

  k = 1;
  for(level = 7; level >= 0; level--)
  {
    for(start = 0; start < KYBER_N; start = j + (1<<level))
    {
      zeta = zetas[k++];
      for(j = start; j < start + (1<<level); ++j)
      {
        t = montgomery_reduce((uint32_t)zeta * p[j + (1<<level)]);

        p[j + (1<<level)] = barrett_reduce(p[j] + 4*KYBER_Q - t);

        if(level & 1) /* odd level */
          p[j] = p[j] + t; /* Omit reduction (be lazy) */
        else
          p[j] = barrett_reduce(p[j] + t);
      }
    }
  }
}

/* Inverse NTT, bitreversed to normal order */
void invntt(uint16_t * a)
{
  int start, j, jTwiddle, level;
  uint16_t temp, W;
  uint32_t t;

  for(level=0;level<8;level++)
  {
    for(start = 0; start < (1<<level);start++)
    {
      jTwiddle = 0;
      for(j=start;j<KYBER_N-1;j+=2*(1<<level))
      {
        W = omegas_inv_bitrev_montgomery[jTwiddle++];
        temp = a[j];

        if(level & 1) /* odd level */
          a[j] = barrett_reduce((temp + a[j + (1<<level)]));
        else
          a[j] = (temp + a[j + (1<<level)]); /* Omit reduction (be lazy) */

        t = (W * ((uint32_t)temp + 4*KYBER_Q - a[j + (1<<level)]));

        a[j + (1<<level)] = montgomery_reduce(t);
      }
    }
  }

  for(j = 0; j < KYBER_N; j++)
    a[j] = (montgomery_reduce((a[j] * psis_inv_montgomery[j]))) % KYBER_Q;
}

/*************************************************
* Name:        [Efficient version] A NTT with CT forward and GS inverse£¬using the same data stream other than the inner loop.
*              NTT  index = 0
*              INTT index = 1
*
* Description: Computes negacyclic number-theoretic transform (NTT) of
*              a polynomial (vector of 256 coefficients) in place;
*              inputs assumed to be in normal order, output in bitreversed order
*               GS
* Arguments:   - uint16_t *p: pointer to in/output polynomial
**************************************************/
void eff_ntt_CT_intt_GS(uint16_t *a, int index)
{
  int i, j, k, m, t, addr, jFirst, jLast;
  uint16_t omega;
  uint32_t U, V;

  t = KYBER_N;
  for(m = 1; m < KYBER_N; m= m*2)
  {
    t = t/2;
    for(i = 0; i < m; i++)
    {//pip j,jFirst,jLast
      jFirst = 2*i*t;
      jLast = 2*i*t+t;
      for(j = 0 ; j < t ; j++)
      {
          if(index == 0){
          addr = m+i; omega = bvpsi_7681_256[addr];
          U = a[j+jFirst];
          V = (a[j+jLast] * (uint32_t)omega) % 7681;
          a[j+jFirst] = (U + V) % 7681;

          if(U>V)
            a[j+jLast] = (U - V) % 7681;
          else
            a[j+jLast] = (7681- V + U) % 7681;
          }else{
          addr = ((j<<1)+1)*m; omega = invpsi_7681_256[addr];
          U = a[reverse(j+jFirst)];
          V = a[reverse(j+jLast)];
          a[reverse(j+jFirst)] = (U + V) % 7681;
          if(U>V)
            a[reverse(j+jLast)] = ((U - V) * (uint32_t)omega) % 7681;
          else
            a[reverse(j+jLast)] = ((7681- V + U) * (uint32_t)omega) % 7681;
          }
      }
    }
//      // gen intermediate
//    if(m == 1 && index==1){
//        printf("\ntestvector stage intermidiate\n");
//        for(i=0; i<KYBER_N; i++)       // 利用for循环对int数组中的数字进行逐个输出
//        printf("%d\n", a[i]);}
  }
//    if(index == 1){
//    for(k = 0; k < KYBER_N; k++)
//        a[k] = (a[k] * 7651) % 7681;
//    }

//      // gen mont param
//        printf("\ngen mont param bvpsi\n");
//        for(i=0; i<KYBER_N; i++)       // 利用for循环对int数组中的数字进行逐个输出
//            printf("%d,\n", (8192*bvpsi_7681_256[i])%7681);
//        printf("\ngen mont param invpsi\n");
//        for(i=0; i<KYBER_N; i++)       // 利用for循环对int数组中的数字进行逐个输出
//            printf("%d,\n", (8192*invpsi_7681_256[i])%7681);
}
