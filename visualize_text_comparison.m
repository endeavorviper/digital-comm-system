function visualize_text_comparison(original_text, decoded_text, decode_label, encode_method, p_error, channel_type)
% VISUALIZE_TEXT_COMPARISON  可视化原始文本与译码文本并保存图片
%
% 支持 channel_type: 'bsc'（显示"误码率"）或 'bec'（显示"删除率"）

% 参数默认值处理（兼容 R2019b 之前版本）
if nargin < 3 || isempty(decode_label);  decode_label  = 'MAP';     end
if nargin < 4 || isempty(encode_method); encode_method = 'unknown'; end
if nargin < 5 || isempty(p_error);       p_error       = NaN;       end
if nargin < 6 || isempty(channel_type);   channel_type   = 'bsc';     end

orig = char(original_text);
dec  = char(decoded_text);

len_ref    = numel(orig);
len_dec    = numel(dec);
common_len = min(len_ref, len_dec);
if common_len > 0
    sim = sum(orig(1:common_len) == dec(1:common_len)) / len_ref;
else
    sim = 0;
end

orig_show = strjoin(wrap_text(orig, 90), newline);
dec_show  = strjoin(wrap_text(dec,  90), newline);

% 根据信道类型选择标签
if strcmpi(channel_type, 'bec')
    channel_str = sprintf('编码=%s | 译码=%s | 删除率=%.3f | 文本相似度=%.2f%%%%', ...
        upper(encode_method), upper(decode_label), p_error, sim * 100);
else
    channel_str = sprintf('编码=%s | 译码=%s | 误码率=%.3f | 文本相似度=%.2f%%%%', ...
        upper(encode_method), upper(decode_label), p_error, sim * 100);
end

fig = figure('Name', '文本传输结果可视化', ...
             'NumberTitle', 'off', 'Color', 'w', 'Position', [120 120 1100 640], ...
             'Visible', 'off');

annotation('textbox', [0.05 0.93 0.9 0.06], ...
    'String', channel_str, ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
    'FontWeight', 'bold', 'FontSize', 13);

annotation('textbox', [0.05 0.08 0.42 0.82], ...
    'String', ['原始信源文本' newline newline orig_show], ...
    'Interpreter', 'none', 'EdgeColor', [0.20 0.55 0.85], 'LineWidth', 1.5, ...
    'BackgroundColor', [0.95 0.98 1.00], 'FontName', 'Consolas', ...
    'FontSize', 10, 'VerticalAlignment', 'top');

annotation('textbox', [0.53 0.08 0.42 0.82], ...
    'String', [sprintf('最终传输后译码文本（%s）', upper(decode_label)) newline newline dec_show], ...
    'Interpreter', 'none', 'EdgeColor', [0.10 0.65 0.35], 'LineWidth', 1.5, ...
    'BackgroundColor', [0.95 1.00 0.96], 'FontName', 'Consolas', ...
    'FontSize', 10, 'VerticalAlignment', 'top');

annotation('textbox', [0.05 0.02 0.9 0.05], ...
    'String', sprintf('原文长度=%d, 译码长度=%d, 长度差=%d', len_ref, len_dec, abs(len_ref - len_dec)), ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'center', 'FontSize', 10);

out_file = sprintf('text_comparison_%s_%s.png', lower(encode_method), lower(decode_label));
exportgraphics(fig, out_file, 'Resolution', 150);
fprintf('文本对比图已保存: %s\n', out_file);
close(fig);
end
