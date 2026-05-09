function decoded_text = ml_decode(rx_bits, codec, verbose)
% ML_DECODE  极大似然译码
%   BSC 信道下，ML 等价于最小汉明距离判决（前缀树贪心匹配）
%   rx_bits      : 1×M double (0/1)
%   codec        : build_codec 返回的结构体
%   verbose      : 是否打印（默认 true）
%   decoded_text : 译码后字符串

if nargin < 3; verbose = true; end

child0   = codec.child0;
child1   = codec.child1;
leaf_sym = codec.leaf_sym;

M    = numel(rx_bits);
text = '';
cur  = 1;
i    = 1;

while i <= M
    bit = rx_bits(i);
    if bit == 0
        nxt = child0(cur);
    else
        nxt = child1(cur);
    end

    if nxt == 0
        % 当前路径无子节点（噪声破坏码字），丢弃该比特并重置到根
        cur = 1;
        i   = i + 1;
        continue;
    end

    cur = nxt;
    i   = i + 1;

    if child0(cur) == 0 && child1(cur) == 0
        if ~isempty(leaf_sym{cur})
            text = [text leaf_sym{cur}];
        end
        cur = 1;
    end
end

decoded_text = text;
if verbose
    fprintf('ML  译码完成，共恢复 %d 个符号\n', numel(decoded_text));
end
end