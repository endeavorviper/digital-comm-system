function decoded_text = map_decode(rx_bits, codec, p_error, verbose)
% MAP_DECODE  最大后验概率译码（Maximum A Posteriori）
%   在 BSC 信道下：
%     P(c_i | r) ∝ P(r | c_i) * P(c_i)
%               = (p_e)^d * (1-p_e)^(L-d) * P(c_i)
%   其中 d = 汉明距离，L = 码字长度，P(c_i) = 符号先验概率
%
%   rx_bits      : 1×M double (0/1)
%   codec        : build_codec 返回的结构体
%   p_error      : 信道误码率
%   verbose      : 是否打印（默认 true）
%   decoded_text : 译码后字符串

if nargin < 4; verbose = true; end

enc_sym  = codec.enc_sym;
enc_code = codec.enc_code;
probs    = codec.probs;

N = numel(enc_sym);
M = numel(rx_bits);

code_len = zeros(1, N);
for i = 1:N
    code_len(i) = numel(enc_code{i});
end

text    = '';
pos     = 1;
max_len = max(code_len);
min_len = min(code_len);

while pos <= M - min_len + 1
    best_score = -inf;
    best_sym   = '';
    best_len   = min_len;

    for i = 1:N
        L = code_len(i);
        if pos + L - 1 > M
            continue;
        end

        r_window = rx_bits(pos : pos+L-1);
        cw_bits  = double(enc_code{i} == '1');
        d        = sum(r_window ~= cw_bits);

        pe = min(max(p_error, 1e-10), 1 - 1e-10);
        log_likelihood = d * log(pe) + (L - d) * log(1 - pe);
        log_map        = log_likelihood + log(max(probs(i), 1e-10));

        if log_map > best_score
            best_score = log_map;
            best_sym   = enc_sym{i};
            best_len   = L;
        end
    end

    if ~isempty(best_sym)
        text = [text best_sym];
    end
    pos = pos + best_len;
end

decoded_text = text;
if verbose
    fprintf('MAP 译码完成，共恢复 %d 个符号\n', numel(decoded_text));
end
end