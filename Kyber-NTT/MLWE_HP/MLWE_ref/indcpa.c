#include <stdint.h>
#include <math.h>
#include <stdio.h>
#include <string.h>
#include "poly.h"
#include "polyvec.h"
#include "ntt.h"
#include "params.h"

static uint16_t sk[KYBER_N] = {
        3,1,4,843,5472,9,7672,6,345,3,5,8,424,7,9,3,56,3,8,4,6,23,6,4,3,3,8,3,2,7,9,5,3,1,4,1,5,9,2,6,5,3,5,43,9,7,9,3,2,3,8,4,6,2,6,4,3,3,8,3,2,7,9,5,
        3,1,4,1,325,9,2,6,5,3,5,8,9,7,9,3,2,3,8,4,6,2,6,4,3,3,8,3,2,7,9,5,3,1,4,1,5,9,2,6,5,3,555,8,9,7,9,3,2,3,8,4,6,2,6,4,3,3,8,3,2,7,9,5,
        80,1,4,1,5,9,2,6,5,3,5,8,9,7,9,3,2,3,8,4,6,2,6,4,3,3,8,3,2,7,329,5,5123,1,4,1,5,9,2,6,5,3,5,8,9,7,9,3,2,3,8,4,6,2,6,4,3,3,8,3,2,7,9,5,
        54,1,4,1,5,9,2,6,5,3,5,8,933,7,9,3,2,3,8,4,6,2,6,4,3,3,8,3,2,7,9,5,3,1,4,1,5,9,32,6,5,3,5,8,9,7,9,3,2,3,8,4,6,2,635,4,3,3,8,433,33,7680,911,5321
        };
static uint16_t error[KYBER_N] = {
        3,1,4,1,5,9,2,6,5,3,5,8,9,7,9,3,2,3,8,4,6,2,6,4,3,3,8,3,2,7,9,5,3,1,4,1,5,9,2,6,5,3,5,8,9,7,9,3,2,3,8,4,6,2,6,4,3,3,8,3,2,7,9,5,
        3,1,4,1,5,9,2,6,5,3,5,8,9,7,9,3,2,3,8,4,6,2,6,4,3,3,8,3,2,7,9,5,3,1,4,1,5,9,2,6,5,3,5,8,9,7,9,3,2,3,8,4,6,2,6,4,3,3,8,3,2,7,9,5,
        3,1,4,1,5,9,2,6,5,3,5,8,9,7,9,3,2,3,8,4,6,2,6,4,3,3,8,3,2,7,9,5,3,1,4,1,5,9,2,6,5,3,5,8,9,7,9,3,2,3,8,4,6,2,6,4,3,3,8,3,2,7,9,5,
        3,1,4,1,5,9,2,6,5,3,5,8,9,7,9,3,2,3,8,4,6,2,6,4,3,3,8,3,2,7,9,5,3,1,4,1,5,9,2,6,5,3,5,8,9,7,9,3,2,3,8,4,6,2,6,4,3,3,8,3,2,7,9,5
        };

static uint16_t pk1[KYBER_N] = {
        3, 1, 4, 1, 4, 6292, 2, 6289, 4, 3, 4, 6291, 6292, 6290, 6292, 3, 2, 3, 6291, 4, 6289, 2,
        6289, 4, 3, 3, 6291, 3, 2, 6290, 6292, 4, 3, 1, 4, 1, 4, 6292, 2, 6289, 4, 3, 4, 6291,
        6292, 6290, 6292, 3, 2, 3, 6291, 4, 6289, 2, 6289, 4, 3, 3, 6291, 3, 2, 6290, 6292, 4, 3, 1,
        4, 1, 4, 6292, 2, 6289, 4, 3, 4, 6291, 6292, 6290, 6292, 3, 2, 3, 6291, 4, 6289, 2, 6289, 4,
        3, 3, 6291, 3, 2, 6290, 6292, 4, 3, 1, 4, 1, 4, 6292, 2, 6289, 4, 3, 4, 6291, 6292, 6290,
        6292, 3, 2, 3, 6291, 4, 6289, 2, 6289, 4, 3, 3, 6291, 3, 2, 6290, 6292, 4, 3, 1, 4, 1,
        4, 6292, 2, 6289, 4, 3, 4, 6291, 6292, 6290, 6292, 3, 2, 3, 6291, 4, 6289, 2, 6289, 4, 3, 3,
        6291, 3, 2, 6290, 6292, 4, 3, 1, 4, 1, 4, 6292, 2, 6289, 4, 3, 4, 6291, 6292, 6290, 6292, 3,
        2, 3, 6291, 4, 6289, 2, 6289, 4, 3, 3, 6291, 3, 2, 6290, 6292, 4, 3, 1, 4, 1, 4, 6292,
        2, 6289, 4, 3, 4, 6291, 6292, 6290, 6292, 3, 2, 3, 6291, 4, 6289, 2, 6289, 4, 3, 3, 6291, 3,
        2, 6290, 6292, 4, 3, 1, 4, 1, 4, 6292, 2, 6289, 4, 3, 4, 6291, 6292, 6290, 6292, 3, 2, 3,
        6291, 4, 6289, 2, 6289, 4, 3, 3, 6291, 3, 2, 6290, 6292, 7680};
static uint16_t pk2[KYBER_N] = {
        3, 1, 4, 1, 965, 2240, 2, 7661, 965, 3, 965, 4047, 2240, 5854, 2240, 3, 2, 3, 4047, 4, 7661, 2,
        7661, 4, 3, 3, 4047, 3, 2, 5854, 2240, 965, 3, 1, 4, 1, 965, 2240, 2, 7661, 965, 3, 965, 4047,
        2240, 5854, 2240, 3, 2, 3, 4047, 4, 7661, 2, 7661, 4, 3, 3, 4047, 3, 2, 5854, 2240, 965, 3, 1,
        4, 1, 965, 2240, 2, 7661, 965, 3, 965, 4047, 2240, 5854, 2240, 3, 2, 3, 4047, 4, 7661, 2, 7661, 4,
        3, 3, 4047, 3, 2, 5854, 2240, 965, 3, 1, 4, 1, 965, 2240, 2, 7661, 965, 3, 965, 4047, 2240, 5854,
        2240, 3, 2, 3, 4047, 4, 7661, 2, 7661, 4, 3, 3, 4047, 3, 2, 5854, 2240, 965, 3, 1, 4, 1,
        965, 2240, 2, 7661, 965, 3, 965, 4047, 2240, 5854, 2240, 3, 2, 3, 4047, 4, 7661, 2, 7661, 4, 3, 3,
        4047, 3, 2, 5854, 2240, 965, 3, 1, 4, 1, 965, 2240, 2, 7661, 965, 3, 965, 4047, 2240, 5854, 2240, 3,
        2, 3, 4047, 4, 7661, 2, 7661, 4, 3, 3, 4047, 3, 2, 5854, 2240, 965, 3, 1, 4, 1, 965, 2240,
        2, 7661, 965, 3, 965, 4047, 2240, 5854, 2240, 3, 2, 3, 4047, 4, 7661, 2, 7661, 4, 3, 3, 4047, 3,
        2, 5854, 2240, 965, 3, 1, 4, 1, 965, 2240, 2, 7661, 965, 3, 965, 4047, 2240, 5854, 2240, 3, 2, 3,
        4047, 4, 7661, 2, 7661, 4, 3, 3, 4047, 3, 2, 5854, 2240, 0};

/*************************************************
* Name:        gen test vector
*
* Description: Generates test vector for BRAM .coe file in VIVADO
*
* Arguments:   - radix=10
**************************************************/
void genTV_13b(polyvec *coe)
{
    printf("%s", "vivado 13b coe\n");
    int i;
    for(i=0; i<KYBER_N; i++)
        printf("%d,\n", coe->vec->coeffs[i]);
    for(i=0; i<KYBER_N; i++)
        printf("%d,\n", (coe->vec+1)->coeffs[i]);
}

void genTV_26b(polyvec *coe)
{
    printf("%s", "vivado 26b coe\n");
    int i;
    for(i=0; i<KYBER_N; i++)
        printf("%d,\n", (coe->vec->coeffs[i]<<13)+((coe->vec+1)->coeffs[i]));
}


/*************************************************
* Name:        indcpa_keypair
*
* Description: Generates public and private key for the CPA-secure
*              public-key encryption scheme underlying Kyber
*
* Arguments:   - unsigned char *pk: pointer to output public key (of length KYBER_INDCPA_PUBLICKEYBYTES bytes)
*              - unsigned char *sk: pointer to output private key (of length KYBER_INDCPA_SECRETKEYBYTES bytes)
**************************************************/
int main(void)
{
    int i,j;
    polyvec A[KYBER_K], e, Ase_pv, s;

    for(i=0;i<KYBER_N;i++) {
    A[0].vec->coeffs[i] = pk1[i];
    (A[0].vec + 1)->coeffs[i] = pk2[i];
    A[1].vec->coeffs[i] = pk1[i];
    (A[1].vec + 1)->coeffs[i] = pk2[i];
    s.vec->coeffs[i] = sk[i];
    (s.vec + 1)->coeffs[i] = sk[i];
    e.vec->coeffs[i] = error[i];
    (e.vec + 1)->coeffs[i] = error[i];
  }

//  // gen Test Vector
//  genTV_26b(&A[0]);
//  genTV_26b(&skpv);
//  genTV_13b(&e);

/*************************************************
* Description: 测试NTT/INTT 是否正确
**************************************************/
//  printf("%s", "original polyvec\n");
//  for(i=0; i<KYBER_N; i++)       // 利用for循环对int数组中的数字进行逐个输出
//    printf("%d ", s.vec->coeffs[i]);
//
//  //Original NTT
//  polyvec_ntt(&s);
//  printf("%s", "\n\npolyvec after NTT\n");
//  for(i=0; i<KYBER_N; i++)       // 利用for循环对int数组中的数字进行逐个输出
//    printf("%d ", s.vec->coeffs[i]);
//
//  polyvec_invntt(&s);
//  printf("%s", "\n\npolyvec after INTT\n");
//  for(i=0; i<KYBER_N; i++)       // 利用for循环对int数组中的数字进行逐个输出
//    printf("%d ", s.vec->coeffs[i]);
//
//  //Test NTT
//  hw_polyvec_ntt(&s);
//  printf("%s", "\n\nHardware polyvec algorithm after NTT\n");
//  for(i=0; i<KYBER_N; i++)       // 利用for循环对int数组中的数字进行逐个输出
//    printf("%d ", s.vec->coeffs[i]);
//
//  hw_polyvec_invntt(&s);
//  printf("%s", "\n\nHardware polyvec algorithm after INTT\n");
//  for(i=0; i<KYBER_N; i++)       // 利用for循环对int数组中的数字进行逐个输出
//    printf("%d ", s.vec->coeffs[i]);

/*************************************************
* Description: 测试整个As+e
**************************************************/
//  polyvec_ntt(&s);
    hw_polyvec_ntt(&s);
    printf("%s", "\nHardware polyvec algorithm after NTT\n");
    for(i=0; i<KYBER_N; i++)       // 利用for循环对int数组中的数字进行逐个输出
        printf("%d ", s.vec->coeffs[i]);

//  matrix-vector multiplication
    for(i=0;i<KYBER_K;i++)
        polyvec_pointwise_acc(&Ase_pv.vec[i],&s,A+i);
    printf("%s", "\n\npolyvec after pointwise multiple\n");
    for(i=0; i<KYBER_N; i++)       // 利用for循环对int数组中的数字进行逐个输出
        printf("%d ", Ase_pv.vec->coeffs[i]);

//  polyvec_invntt(&Ase_pv);
    hw_polyvec_invntt(&Ase_pv);
    printf("%s", "\n\npolyvec As after INTT\n");
    for(i=0; i<KYBER_N; i++)       // 利用for循环对int数组中的数字进行逐个输出
        printf("%d ", Ase_pv.vec->coeffs[i]);

    polyvec_add(&Ase_pv, &Ase_pv, &e);
    for(i=0;i<KYBER_K;i++) {
    printf("\n\npolyvec As+e result poly %d \n", i);
        for(j=0;j<KYBER_N;j++) {
            printf("%d ", (Ase_pv.vec + i)->coeffs[j]);
        }
    }

//    printf("\n\nPV_PWM result\n");
//    for(i=0; i<KYBER_N; i++)       // 利用for循环对int数组中的数字进行逐个输出
//        printf("%d ", (pk1[i]*sk[i]+pk2[i]*sk[i])%7681);
//    printf("\n\nPOLY_MADD result\n");
//    for(i=0; i<KYBER_N; i++)       // 利用for循环对int数组中的数字进行逐个输出
//        printf("%d ", (7651*sk[i]+error[i])%7681);
//    printf("\n\nPOLY_MSUB result\n");
//    for(i=0; i<KYBER_N; i++)       // 利用for循环对int数组中的数字进行逐个输出
//        printf("%d ", (7681+error[i]-(7651*sk[i]%7681))%7681); //in KYBER, it's not error-sk, we just take it as a test.
//    printf("\n\nPOLY_MADD_ADD result\n");
//    for(i=0; i<KYBER_N; i++)       // 利用for循环对int数组中的数字进行逐个输出
//        printf("%d ", (7651*sk[i]+error[i]+1)%7681);

}
