function codebook = shannon_encode(symbols, probs)
% SHANNON_ENCODE  香农编码（累积概率法）
%   symbols : 1×N cell
%   probs   : 1×N double（降序）
%   codebook: N×2 cell，{symbol, codeword_string}

N = numel(symbols);

% 按概率降序排列（保险）
[p, idx] = sort(probs, 'descend');
syms = symbols(idx);

codebook = cell(N, 2);
cum_p = 0;

for i = 1:N
    % 码长 li = ceil(-log2(pi))
    li = ceil(-log2(p(i) + 1e-15));
    li = max(li, 1);

    % 累积概率转二进制，取前 li 位
    val = cum_p;
    code = '';
    for b = 1:li
        val = val * 2;
        if val >= 1
            code = [code '1'];
            val  = val - 1;
        else
            code = [code '0'];
        end
    end

    codebook{i, 1} = syms{i};
    codebook{i, 2} = code;
    cum_p = cum_p + p(i);
end
end
