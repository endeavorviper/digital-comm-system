function plot_cer_vs_channel_prob_three_encodings(ref_text, symbols, probs, ...
                                          cb_huffman, cb_shannon, cb_fano, ...
                                          decode_mode, channel_type)
% PLOT_CER_VS_CHANNEL_PROB_THREE_ENCODINGS
% 横轴为信道错误概率 p (0~1)，纵轴为 CER，三条曲线分别对应 Huffman/Shannon/Fano。
% decode_mode : 'ml' | 'map' | 'best'（默认 'map'）
% channel_type : 'bsc' | 'bec'（默认 'bsc'）

% 参数默认值处理
if nargin < 7 || isempty(decode_mode);  decode_mode = 'map';        end
if nargin < 8 || isempty(channel_type); channel_type = 'bsc'; end

decode_mode = lower(string(decode_mode));
channel_type = lower(string(channel_type));
enc_names   = {'Huffman', 'Shannon', 'Fano'};
codebooks   = {cb_huffman, cb_shannon, cb_fano};

N_TRIALS   = 20;
p_range    = linspace(0, 1, 21);
n_p        = numel(p_range);
cer_curves = zeros(3, n_p);

fprintf('\n--- 扫描 p in [0,1]，绘制三种编码 CER 曲线（%s，每点 %d 次平均）---\n', ...
        upper(char(decode_mode)), N_TRIALS);

for m = 1:3
    [codec, tx_bits] = build_codec(codebooks{m}, ref_text);
    codec.probs = lookup_probs(codec.enc_sym, symbols, probs);
    n_ref = numel(ref_text);

    for k = 1:n_p
        pe  = p_range(k);
        acc = 0;

        for t = 1:N_TRIALS
            % 根据信道类型选择
            switch char(channel_type)
                case 'bec'
                    [rx_bits, erasure_mask, ~] = bec_channel(tx_bits, pe, false);
                otherwise % bsc
                    [rx_bits, ~] = bsc_channel(tx_bits, pe, false);
                    erasure_mask   = false(1, numel(rx_bits));
            end

            % 根据译码模式选择
            switch char(decode_mode)
                case "ml"
                    switch char(channel_type)
                        case 'bec'
                            d_hat = decode_bec(rx_bits, erasure_mask, codec, pe, 'ml', false);
                        otherwise
                            d_hat = ml_decode(rx_bits, codec, false);
                    end
                    acc = acc + char_error_rate(ref_text, d_hat);
                case "map"
                    switch char(channel_type)
                        case 'bec'
                            d_hat = decode_bec(rx_bits, erasure_mask, codec, pe, 'map', false);
                        otherwise
                            d_hat = map_decode(rx_bits, codec, pe, false);
                    end
                    acc = acc + char_error_rate(ref_text, d_hat);
                otherwise % best
                    switch char(channel_type)
                        case 'bec'
                            d_ml  = decode_bec(rx_bits, erasure_mask, codec, pe, 'ml',  false);
                            d_map = decode_bec(rx_bits, erasure_mask, codec, pe, 'map', false);
                        otherwise
                            d_ml  = ml_decode(rx_bits, codec, false);
                            d_map = map_decode(rx_bits, codec, pe, false);
                    end
                    acc = acc + min(char_error_rate(ref_text, d_ml), ...
                                     char_error_rate(ref_text, d_map));
            end
        end
        cer_curves(m, k) = acc / N_TRIALS;
    end

    fprintf('  %s 编码完成\n', enc_names{m});
end

%% ===== 绘图 =====
fig = figure('Name', '信道参数 vs CER（三编码）', ...
       'NumberTitle', 'off', 'Position', [220 180 820 500], ...
       'Visible', 'off');

colors = ['b', 'r', 'g'];
markers = ['o', 's', '^'];

hold on;
for m = 1:3
    plot(p_range, cer_curves(m, :), ...
         'Color', colors(m), 'Marker', markers(m), ...
         'LineWidth', 2, 'MarkerSize', 5, ...
         'DisplayName', enc_names{m});
end
hold off;

grid on;
xlim([0, 1]); ylim([0, 1]);
xlabel('信道参数 p（BSC=误码率，BEC=删除率）');
ylabel('字符错误率 CER');

title_str = sprintf('CER 随信道参数变化（%s，%s，%d次平均）', ...
                  upper(char(channel_type)), upper(char(decode_mode)), N_TRIALS);
title(title_str, 'FontSize', 11);
legend('Location', 'northwest');

out_file = sprintf('cer_vs_channel_prob_three_encodings_%s_%s.png', ...
                  lower(char(channel_type)), lower(char(decode_mode)));
exportgraphics(gcf, out_file, 'Resolution', 150);
fprintf('三编码 CER 曲线图已保存: %s\n', out_file);
close(fig);
end
