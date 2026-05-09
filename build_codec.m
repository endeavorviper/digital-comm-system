function [codec, tx_bits] = build_codec(codebook, text)
% BUILD_CODEC  构建编解码器，并对文本编码生成比特流
%   codebook : N×2 cell，{symbol, codeword}
%   text     : 待编码字符串
%   codec    : struct，含编码表和解码树
%   tx_bits  : 1×M double (0/1)，编码后比特流

N = size(codebook, 1);

% --- 编码映射 ---
enc_sym  = cell(1, N);
enc_code = cell(1, N);
for i = 1:N
    enc_sym{i}  = codebook{i, 1};
    enc_code{i} = codebook{i, 2};
end

% --- 文本 → 比特流 ---
bit_parts = cell(1, numel(text));
for k = 1:numel(text)
    c = text(k);
    found = false;
    for i = 1:N
        if enc_sym{i} == c
            bit_parts{k} = enc_code{i};
            found = true;
            break;
        end
    end
    if ~found
        bit_parts{k} = '';
    end
end
all_bits_str = strjoin(bit_parts, '');
tx_bits = double(all_bits_str == '1');  % char → 0/1 double

% --- 构建前缀树（用于解码）---
% 树节点用两个矩阵：child0, child1
% 节点 1 为根，0 表示无子节点
MAX_NODES = 4 * N + 10;
child0 = zeros(1, MAX_NODES);  % 走 '0' 到达的子节点
child1 = zeros(1, MAX_NODES);  % 走 '1' 到达的子节点
leaf_sym = cell(1, MAX_NODES); % 叶节点存符号，非叶为空
node_cnt = 1;                  % 根节点编号 = 1

for i = 1:N
    cw  = enc_code{i};
    sym = enc_sym{i};
    cur = 1;
    for b = 1:numel(cw)
        bit = cw(b);
        if bit == '0'
            if child0(cur) == 0
                node_cnt = node_cnt + 1;
                child0(cur) = node_cnt;
            end
            cur = child0(cur);
        else
            if child1(cur) == 0
                node_cnt = node_cnt + 1;
                child1(cur) = node_cnt;
            end
            cur = child1(cur);
        end
    end
    leaf_sym{cur} = sym;
end

% 打包 codec
codec.enc_sym  = enc_sym;
codec.enc_code = enc_code;
codec.child0   = child0(1:node_cnt);
codec.child1   = child1(1:node_cnt);
codec.leaf_sym = leaf_sym(1:node_cnt);
codec.probs    = zeros(1, N);   % 留给 map_decode 用，稍后由 main 填充

% 计算并显示平均码长
avg_len = numel(all_bits_str) / max(numel(text), 1);
fprintf('\n--- 编码器构建完成 ---\n');
fprintf('符号表大小: %d  |  比特流长度: %d  |  平均码长: %.4f bits/符号\n', ...
        N, numel(tx_bits), avg_len);
end
