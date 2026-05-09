# 数字通信系统仿真 — MATLAB 实现说明

## 系统架构

```
信源文本
   │
   ▼
【信源统计】source_statistics.m
   统计字符频率，计算概率分布与信源熵
   │
   ▼
【信源编码】（三种方法对比）
   ├─ huffman_encode.m  → 哈夫曼编码（最优前缀码）
   ├─ shannon_encode.m  → 香农编码（累积概率取整）
   └─ fano_encode.m     → 费诺编码（递归二分）
   │
   ▼
【比特流编码】build_codec.m
   将文本符号序列映射为0/1比特串
   │
   ▼
【BSC信道】bsc_channel.m
   二进制对称信道：以概率p独立翻转每个比特
   │
   ▼
【译码】（两种方法）
   ├─ ml_decode.m   → 极大似然（ML）译码
   │     argmax P(r|c_i) = argmin 汉明距离
   └─ map_decode.m  → 最大后验概率（MAP）译码
         argmax P(r|c_i)·P(c_i)（先验加权）
   │
   ▼
【性能评估与可视化】plot_ber_cer_curve.m + compare_encodings.m
```

## 文件列表

| 文件 | 功能 |
|------|------|
| `main.m` | 主程序，串联完整流程 |
| `source_statistics.m` | 信源统计（字符频率、熵） |
| `huffman_encode.m` | 哈夫曼编码 |
| `shannon_encode.m` | 香农编码 |
| `fano_encode.m` | 费诺编码 |
| `build_codec.m` | 构建编/解码器（前缀树） |
| `bsc_channel.m` | BSC 二进制对称信道 |
| `ml_decode.m` | 极大似然译码 |
| `map_decode.m` | 最大后验概率译码 |
| `char_error_rate.m` | 字符错误率计算 |
| `plot_ber_cer_curve.m` | 可视化（3个图窗口） |
| `compare_encodings.m` | 三种编码性能汇总表 |

## 快速使用

在 MATLAB 中，切换到本目录后运行：
```matlab
main
```

## 参数调整（在 main.m 顶部修改）

```matlab
INPUT_TEXT    = '...';   % 替换为你的文本
P_ERROR       = 0.05;    % 信道误码率 (0~0.5)
ENCODE_METHOD = 'huffman'; % 'huffman' / 'shannon' / 'fano'
```

## 理论说明

### 香农编码
- 码长：lᵢ = ⌈−log₂ pᵢ⌉
- 累积概率 Fᵢ = Σⱼ₌₁ⁱ⁻¹ pⱼ 的二进制展开取前 lᵢ 位作为码字
- **效率**：H ≤ L̄ < H+1

### 费诺编码
- 递归二分：每次找使两组概率和之差最小的分割点
- 左组赋 `0`，右组赋 `1`，递归直到每组仅一个符号
- **效率**：接近但通常不如哈夫曼

### 哈夫曼编码
- 每次合并概率最小的两个节点构造最优二叉树
- 是所有前缀码中平均码长最短的方案（最优性证明：Huffman, 1952）
- **效率**：H ≤ L̄_Huffman < H+1（最优）

### BSC 信道
```
P(y|x) =  1−p   若 y=x
          p      若 y≠x
```
p = 误码率（0 ~ 0.5）

### 极大似然（ML）译码
```
ĉ = argmax P(r|cᵢ) = argmin d_H(r, cᵢ)
```
BSC 下等价于最小汉明距离判决。

### 最大后验概率（MAP）译码
```
ĉ = argmax P(cᵢ|r) ∝ P(r|cᵢ) · P(cᵢ)
```
引入先验概率 P(cᵢ)，高频符号在噪声下更不容易被误判，性能优于 ML（当先验不均匀时）。

## 可视化输出

运行后自动生成 3 个图窗：
1. **CER vs 误码率曲线**：对比哈夫曼+ML、哈夫曼+MAP、香农+ML、费诺+ML 的字符错误率随信道质量变化
2. **符号统计与编码码长**：概率分布、三种编码码长对比、码长vs自信息量
3. **ML vs MAP 决策得分**：单符号示例下的对数似然/后验概率直方图
