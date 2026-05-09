function visualize_parallel_encodings(ref_text, symbols, probs, cb_huffman, cb_shannon, cb_fano, ...
                                   p_error, selected_method, tx_bits_main, rx_bits_main, channel_type)
% VISUALIZE_PARALLEL_ENCODINGS  并列展示三种编码方式的最终译码文本
%
% 支持 channel_type: 'bsc'（BSC 信道 + ml_decode/map_decode）
%                   'bec'（BEC 信道 + decode_bec）

% 参数默认值处理（兼容 R2019b 之前版本）
if nargin <  7 || isempty(p_error);         p_error         = 0.05;        end
if nargin <  8 || isempty(selected_method); selected_method = '';   end
if nargin <  9;                             tx_bits_main    = [];   end
if nargin < 10;                             rx_bits_main    = [];   end
if nargin < 11 || isempty(channel_type);    channel_type   = 'bsc'; end

enc_names  = {'Huffman', 'Shannon', 'Fano'};
codebooks  = {cb_huffman, cb_shannon, cb_fano};
enc_keys   = {'huffman', 'shannon', 'fano'};

texts_ml  = cell(1, 3);
texts_map = cell(1, 3);
cers_ml   = zeros(1, 3);
cers_map  = zeros(1, 3);

for m = 1:3
    [codec, tx_bits] = build_codec(codebooks{m}, ref_text);
    codec.probs = lookup_probs(codec.enc_sym, symbols, probs);

    % 判断是否复用主函数已生成的 rx_bits
    use_main_rx = strcmpi(strtrim(char(selected_method)), enc_keys{m}) && ...
                  ~isempty(tx_bits_main) && ~isempty(rx_bits_main) && ...
                  numel(tx_bits_main) == numel(tx_bits) && ...
                  numel(rx_bits_main) == numel(tx_bits);

    % ===== 通过信道 =====
    if use_main_rx
        rx_bits = rx_bits_main;
        erasure_mask = false(1, numel(rx_bits));
    else
        switch lower(string(channel_type))
            case 'bec'
                [rx_bits, erasure_mask, ~] = bec_channel(tx_bits, p_error, false);
            otherwise  % bsc
                [rx_bits, ~]  = bsc_channel(tx_bits, p_error, false);
                erasure_mask   = false(1, numel(rx_bits));
        end
    end

    % ===== 译码 =====
    switch lower(string(channel_type))
        case 'bec'
            d_ml  = decode_bec(rx_bits, erasure_mask, codec, p_error, 'ml',  false);
            d_map = decode_bec(rx_bits, erasure_mask, codec, p_error, 'map', false);
        otherwise  % bsc
            d_ml  = ml_decode(rx_bits, codec, false);
            d_map = map_decode(rx_bits, codec, p_error, false);
    end

    texts_ml{m}  = d_ml;
    texts_map{m} = d_map;
    cers_ml(m)   = char_error_rate(ref_text, d_ml);
    cers_map(m)  = char_error_rate(ref_text, d_map);
end

% ===== 绘图 =====
fig = figure('Name', '三种编码方式并列结果', ...
             'NumberTitle', 'off', 'Color', 'w', 'Position', [80 80 1450 760], ...
             'Visible', 'off');

% 标题
if strcmpi(channel_type, 'bec')
    title_str = sprintf('三种编码并列对比  |  BEC 删除率 = %.3f', p_error);
else
    title_str = sprintf('三种编码并列对比  |  BSC 误码率 BER = %.3f', p_error);
end

annotation('textbox', [0.04 0.94 0.92 0.05], ...
    'String', title_str, ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
    'FontWeight', 'bold', 'FontSize', 14);

ref_show = strjoin(wrap_text(char(ref_text), 160), newline);
annotation('textbox', [0.04 0.73 0.92 0.19], ...
    'String', ['原始信源文本' newline newline ref_show], ...
    'Interpreter', 'none', 'EdgeColor', [0.15 0.45 0.85], 'LineWidth', 1.4, ...
    'BackgroundColor', [0.95 0.98 1.00], 'FontName', 'Consolas', ...
    'FontSize', 10, 'VerticalAlignment', 'top');

lefts = [0.04, 0.355, 0.67];
for m = 1:3
    ml_show  = strjoin(wrap_text(char(texts_ml{m}),  48), newline);
    map_show = strjoin(wrap_text(char(texts_map{m}), 48), newline);

    annotation('textbox', [lefts(m) 0.66 0.29 0.05], ...
        'String', sprintf('%s 编码', enc_names{m}), ...
        'Interpreter', 'none', 'EdgeColor', [0.35 0.35 0.35], 'LineWidth', 1.2, ...
        'BackgroundColor', [0.98 0.98 0.98], 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', 'FontSize', 11);

    annotation('textbox', [lefts(m) 0.37 0.29 0.28], ...
        'String', [sprintf('ML  译码  |  CER=%.4f', cers_ml(m)) newline newline ml_show], ...
        'Interpreter', 'none', 'EdgeColor', [0.15 0.45 0.85], 'LineWidth', 1.4, ...
        'BackgroundColor', [0.95 0.98 1.00], 'FontName', 'Consolas', ...
        'FontSize', 9, 'VerticalAlignment', 'top');

    annotation('textbox', [lefts(m) 0.08 0.29 0.28], ...
        'String', [sprintf('MAP 译码  |  CER=%.4f', cers_map(m)) newline newline map_show], ...
        'Interpreter', 'none', 'EdgeColor', [0.20 0.65 0.35], 'LineWidth', 1.4, ...
        'BackgroundColor', [0.95 1.00 0.96], 'FontName', 'Consolas', ...
        'FontSize', 9, 'VerticalAlignment', 'top');
end

out_file = sprintf('encoding_parallel_results_%s.png', lower(channel_type));
exportgraphics(fig, out_file, 'Resolution', 150);
fprintf('三种编码并列结果图已保存: %s\n', out_file);
close(fig);
end
