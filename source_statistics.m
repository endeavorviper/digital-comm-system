function [symbols, probs, H, text_filt] = source_statistics(text)
% SOURCE_STATISTICS  统计字符频率，计算信源熵
%   text    : 输入字符串
%   symbols : 1×N cell，符号列表
%   probs   : 1×N double，概率列表（降序排列）
%   H       : 信源熵（bits/符号）

% 支持任意可见字符（字母/数字/标点/中文等）和空格
% 过滤掉不可见控制字符（如换行、制表符）
t = char(text);
u = uint16(t);
mask = (u >= uint16(32)) & (u ~= uint16(127));
t = t(mask);

chars = unique(t);
N = numel(chars);
cnt = zeros(1, N);
for i = 1:N
    cnt(i) = sum(t == chars(i));
end
total = sum(cnt);
p = cnt / total;

% 按概率降序排列
[p_sorted, idx] = sort(p, 'descend');
chars_sorted = chars(idx);

symbols = cell(1, N);
for i = 1:N
    symbols{i} = chars_sorted(i);
end
probs = p_sorted;

% 信源熵
H = -sum(probs(probs>0) .* log2(probs(probs>0)));
text_filt = t;

fprintf('--- 信源统计 ---\n');
fprintf('符号数: %d  |  总字符数: %d  |  信源熵 H = %.4f bits/符号\n', N, total, H);
fprintf('概率最高的10个符号:\n');
for i = 1:min(10, N)
    if symbols{i} == ' '
        sym_disp = 'SP';
    else
        sym_disp = symbols{i};
    end
    fprintf('  %2s : p=%.4f\n', sym_disp, probs(i));
end
end
