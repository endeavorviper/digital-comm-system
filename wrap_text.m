function lines = wrap_text(str, max_chars)
% WRAP_TEXT  按空白字符切词并限制每行长度
% 用法：lines = wrap_text(str, max_chars)
% 直接调用无参数时返回空，不报错
if nargin < 1 || isempty(str)
    lines = {''};
    return;
end
if nargin < 2 || max_chars <= 0
    max_chars = 80;
end
words = regexp(str, '\s+', 'split');
words = words(~cellfun('isempty', words));
if isempty(words)
    lines = {''};
    return;
end
lines  = {};
current = words{1};
for i = 2:numel(words)
    candidate = [current ' ' words{i}];
    if numel(candidate) <= max_chars
        current = candidate;
    else
        lines{end+1} = current; %#ok<AGROW>
        current = words{i};
    end
end
lines{end+1} = current;
end