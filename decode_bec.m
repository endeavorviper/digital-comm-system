function decoded_text = decode_bec(rx_bits, erasure_mask, codec, p_erasure, decode_type, verbose)
% DECODE_BEC  BEC 信道下的译码（ML 和 MAP 两种模式）
%   rx_bits      : 1×M double (0/1)，接收比特（删除位置已占位为 0）
%   erasure_mask : 1×M logical，true 表示对应位置被删除
%   codec        : build_codec 返回的结构体
%   p_erasure    : BEC 删除概率
%   decode_type   : 'ml' 或 'map'
%   verbose      : 是否打印（默认 true）
%   decoded_text : 译码后字符串
%
%  BEC 译码策略：
%   利用 erasure_mask 知道哪些比特被删除，在码字匹配时：
%   - 未删除的比特必须完全匹配
%   - 删除的比特不计入匹配惩罚（通配符）
%   MAP 模式额外引入先验概率加权

if nargin < 6; verbose = true; end
decode_type = lower(string(decode_type));

enc_sym  = codec.enc_sym;
enc_code = codec.enc_code;
probs    = codec.probs;

N = numel(enc_sym);
M = numel(rx_bits);

% 预计算各码字长度
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

        cw_bits  = double(enc_code{i} == '1');
        r_window = rx_bits(pos:pos+L-1);
        e_window = erasure_mask(pos:pos+L-1);

        % 计算匹配情况：只检查未删除的比特
        non_erased = ~e_window;
        if sum(non_erased) == 0
            % 全部被删除：无法判断，依赖先验
            d = 0;
        else
            d = sum(r_window(non_erased) ~= cw_bits(non_erased));
        end

        % 未删除比特的数目
        n_valid = sum(non_erased);

        if strcmp(decode_type, "map")
            % MAP：log P(r|cw) + log P(cw)
            % BEC 下：未删除且正确接收 → 贡献 log(1-p_erasure)
            %           未删除但（不可能）不匹配 → 贡献 -inf（BEC 不会错）
            % 实际上 BEC 未删除比特一定正确，所以只需检查是否匹配
            % 若有不匹配的未删除比特 → 该码字不可能，跳过
            if d > 0
                continue;  % 未删除比特不匹配，该码字不可能
            end
            % 所有未删除比特都匹配 → 该码字是候选
            % log P(r|cw) = n_valid * log(1-p_erasure) + (L-n_valid) * log(p_erasure)
            pe    = min(max(p_erasure, 1e-10), 1 - 1e-10);
            log_likelihood = n_valid * log(1 - pe) + (L - n_valid) * log(pe);
            log_prior     = log(max(probs(i), 1e-10));
            score          = log_likelihood + log_prior;
        else
            % ML：最小化（未删除比特中的）不匹配数
            % BEC 下未删除比特一定正确，若有不匹配则 d>0 → 不可能
            if d > 0
                continue;
            end
            % 所有未删除比特都匹配 → 该码字是候选
            % ML 等价于：选码长最短的（可译码性保证唯一）
            % 若有多个候选（不同码长），选最短的（最可能是真的）
            score = -L;  % ML：偏好短码字（等价于最小汉明距离在 BEC 下的类比）
        end

        if score > best_score
            best_score = score;
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
    fprintf('%s 译码完成（BEC），共恢复 %d 个符号\n', upper(char(decode_type)), numel(decoded_text));
end
end
