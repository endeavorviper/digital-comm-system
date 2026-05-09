function codebook = fano_encode(symbols, probs)
% FANO_ENCODE  费诺编码（递归二分）
%   symbols : 1×N cell
%   probs   : 1×N double
%   codebook: N×2 cell，{symbol, codeword_string}

N = numel(symbols);

% 按概率降序排列
[p_sorted, idx] = sort(probs, 'descend');
syms_sorted = symbols(idx);

codes = cell(1, N);
for i = 1:N
    codes{i} = '';
end

% 用显式栈实现费诺分组（避免递归）
% 栈元素：起始下标、终止下标、当前前缀
stack_start  = zeros(1, N*2);
stack_end    = zeros(1, N*2);
stack_prefix = cell(1, N*2);
sp = 1;
stack_start(1)  = 1;
stack_end(1)    = N;
stack_prefix{1} = '';

while sp > 0
    s      = stack_start(sp);
    e      = stack_end(sp);
    prefix = stack_prefix{sp};
    sp     = sp - 1;

    if s == e
        % 单个符号，直接赋码（前缀就是码字）
        if isempty(prefix)
            codes{s} = '0';
        else
            codes{s} = prefix;
        end
        continue;
    end

    % 找最优二分点：两侧概率之和尽量相等
    total = sum(p_sorted(s:e));
    half  = total / 2;
    cum   = 0;
    best_split = s;
    best_diff  = inf;
    for k = s:e-1
        cum = cum + p_sorted(k);
        diff = abs(cum - half);
        if diff < best_diff
            best_diff  = diff;
            best_split = k;
        end
    end

    % 左半：0；右半：1
    sp = sp + 1;
    stack_start(sp)  = s;
    stack_end(sp)    = best_split;
    stack_prefix{sp} = [prefix '0'];

    sp = sp + 1;
    stack_start(sp)  = best_split + 1;
    stack_end(sp)    = e;
    stack_prefix{sp} = [prefix '1'];
end

% 组装 codebook（恢复原始符号顺序）
codebook = cell(N, 2);
for i = 1:N
    codebook{i, 1} = syms_sorted{i};
    codebook{i, 2} = codes{i};
end
end
