function cer = char_error_rate(original, decoded)
% CHAR_ERROR_RATE  计算字符错误率
%   按最短长度对齐后逐字符比对

len = min(length(original), length(decoded));
if len == 0
    cer = 1.0;
    return;
end
errors = sum(original(1:len) ~= decoded(1:len));
% 长度差也算错误
errors = errors + abs(length(original) - length(decoded));
cer = errors / length(original);
end
