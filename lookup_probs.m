function p_out = lookup_probs(enc_sym, symbols, probs)
% LOOKUP_PROBS  按符号表顺序查找先验概率
N = numel(enc_sym);
p_out = zeros(1, N);
for i = 1:N
    for j = 1:numel(symbols)
        if enc_sym{i} == symbols{j}
            p_out(i) = probs(j);
            break;
        end
    end
end
end