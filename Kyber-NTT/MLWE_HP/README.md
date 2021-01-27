# Kyber_NTT-HP 高性能实现

## 说明
ASPDAC原实现的控制模块和BRAM存在较大路径延时
- MLWE_HP_MADDADD_L版本：执行POLY_MADD指令在ram_data_o[12:0]输出，这样路径延时大，没有加更多pipeline，Fmax约100MHz；
- MLWE_HP_REF版本：执行POLY_MADD指令在ram_data_o[25:13]输出，但没有加更多pipeline，Fmax稍大于100MHz；
- MLWE_HP_PIP-11版本：MLWE_HP_REF基础上加了多级流水，Fmax约232MHz；
- MLWE_HP_PIP-12版本：比MLWE_HP_PIP-11加了DSP的一层流水，Fmax约246MHz；
- MLWE_HP_PIP-13版本：模加减又加了流水，面积大了，频率基本不提升，Fmax约246MHz。
- MLWE_HP版本：MLWE_HP_PIP-12版本的FSM简洁版本；

### NTT_ref
单个多项式NTT参考

### MLWE_ref
MLWE结构，即多项式向量的NTT参考实现

## 创新点
发现：运算都是重复的，可以放在一起
可以执行不同的指令
发现：NTT/INTT控制逻辑可以用一样的
采用改进的算法，INTT的反地址线
发现：可配置的蝶形仍有空间
DSP使用
1. 运算单元结构
2. 之前我们只用了GS，现在我们把CT和GS写进同一个逻辑控制逻辑复用
3. 高频率
4. 实现更多功能 减法
5. 模约减三输入加法器
6.  FSM-based CU


- 可以写的更详细的地方
模加模减
控制信号集，和对应指令编码


- 未来可能的拓展方向
新的kyber
浮点数，有符号数ntt
非原位NTT
用FFT算NTT

## 写作思路
1. 介绍
- 背景
- 格密码
- 相关工作
- 本文贡献
- 文章结构

2. Kyber的多项式元运算
- 符号说明
- Kyber算法介绍
 > 表1：安全参数表

- 多项式运算：乘法，向量乘法
 - 介绍多项式算子
 > 图1：多项式向量运算示意3子图

 - NTT介绍:从基本公式引出基于蝶形符号的
 > 图2：用NTT算乘法过程，从采样到输出

 > 算法1：NTT DIT-CT

 > 算法2：NTT DIF-GS

 - INTT很像

 - 蝶形运算
 > 图3：两种蝶形运算

- 元操作化简与指令
 > 表2：操作指令表
 > 图4：kyber512,1024模乘模加优化量

   - 等效的模乘运算量，还省了order-reverse的量

3. NTT算法优化

- 控制逻辑比重大，我们采用控制逻辑
  - no->bo逻辑一致，可以复用
  > 算法3: 带GS no->bo，双列的表示

- 地址线反转连接
  > 图5：NTT正反过程

- 双列存储
 - 注意对算法3说明
  > 图6： swap circuit

4. 运算逻辑优化
- 可配置蝶形实现
  > 图7：可配置蝶形符号

- 模乘，模加，模减
  > 图8：模乘约减，最大27b/28b，macc

5. 实现
- 整体架构，全部功能
  > 图9：处理器整体架构

- 控制编码，为了控制不同层次
  - FSM CU， done next instruction (inst)
  > 表3：指令层析表，dataflow is difficult

- 运算模块流水线
  - 强调用了BRAM,DSP的REG
  > 图10：阶梯图描述流水线层次：swap，alu，read，write

6. 效果与比较
- 实验环境
 - The correctness of the Verilog implementation is tested by comparing the results of the Vivado simulator with the results of a software implementation of the Montgomery multiplication.
 - 各主要模块面积，控制逻辑可以和ASPDAC比较
  > 表4：各指令执行时间，512,1024

- NTT性能比较
  > 表5：NTT吞吐

- 多项式乘法比较，吞吐
  > 表6：乘法吞吐

7. 结论

## 性能比较
| Name | Slice | LUTs | FFs | DSP | BRAM | Freqency | Latency | Critical Path |
| -- | -- | -- |  -- |  -- |  -- |  -- |  -- |  -- |
| MLWE_HP_REF | Slice | LUTs | FFs | 1 | 2 | 100 | Latency | barrett->ram_s |
| MLWE_HP_PIP—11 | Slice |   |  | 1 | 2 | 222 | 4.500 | H_i->dsp |
| MLWE_HP_PIP—11 | Slice | 186 | 472 | 1 | 2 | 232 | 4.405 | dsp |
| MLWE_HP_PIP—12(DSP_pip) | 194 | 477 | 472 | 1 | 2 | 238 | 4.200 | fsm |
| MLWE_HP_PIP—12(DSP_pip) | 183 | 480 | 472 | 1 | 2 | 243 | 4.100 | o_bf_u |
| MLWE_HP_PIP—12(DSP_pip) | 181 | 479 | 472 | 1 | 2 | 246 | 4.065 | core_sel->dsp |
| MLWE_HP_PIP—12(DSP_pip) | 198 | 476 | 471 | 1 | 2 | 246 | 4.060 | core_sel->dsp |
| MLWE_HP_PIP—13(DSP_pip) | 192 | 476 | 499 | 1 | 2 | 246 | 4.065 | H_i_reg->dsp |
| MLWE_HP1024_PIP—13 | 212 | 533 | 514 | 1 | 3 | 240 | 4.153 | PE i_d->o_v |

- MLWE_HP_PIP—12 ntt 4109 cycles
 > CU 209LUT 120FF, ASPDAC 251,118 (实现后239,118)

- MLWE_HP1024_PIP—13 ntt 2060 cycles
 > CU 210LUT 132FF, ASPDAC 248,118

## 新内容大约60%
1. 原内容
- 双列（20%）
- 倒位（20%）
2. 新内容
- no->bo CT and GS(20%)
- 设计可配置蝶形结构(10%)
- 面向新指令设计数据通路(10%)
- 控制指令的信号编码(10%)
- 设计流水线，实现，并与原文对比(10%)

## Highlights
1. 设计了能够完成kyber元操作的处理器
2. 设计NTT，高效
3. 设计流水线，高速

## TODO
Kyber1024 对不对，barrett要改
KYber512 PVMADD fsm改了

## 测试向量
- NTT/INTT的first stage结果见testvector文件

- 其他主要阶段测试结果见对应的MLWE_ref文件夹（ref C实现和HDL实现结果完全匹配）
