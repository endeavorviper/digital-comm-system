function plot_cer_vs_erasure_prob(ref_text, symbols, probs, cb_huffman, cb_shannon, cb_fano)
% PLOT_CER_VS_ERASURE_PROB
%   BEC 信道下，CER 随删除概率 p 的变化曲线（三种编码，ML+MAP）
%
%   对每种编码，分别用 BEC+ML 和 BEC+MAP 译码，绘制 CER 曲线

N_TRIALS = 20;
p_range   = linspace(0, 1, 21);
n_p       = numel(p_range);

enc_names   = {'Huffman', 'Shannon', 'Fano'};
codebooks   = {cb_huffman, cb_shannon, cb_fano};

% 预分配
cer_ml  = zeros(3, n_p);
cer_map = zeros(3, n_p);

fprintf('\n--- BEC：扫描删除概率 p in [0,1]，绘制 CER 曲线（每点 %d 次平均）---\n', N_TRIALS);

for m = 1:3
    [codec, tx_bits] = build_codec(codebooks{m}, ref_text);
    codec.probs = lookup_probs(codec.enc_sym, symbols, probs);
    n_ref = numel(ref_text);

    for k = 1:n_p
        pe  = p_range(k);
        acc_ml  = 0;
        acc_map = 0;

        for t = 1:N_TRIALS
            [rx_bits, erasure_mask, ~] = bec_channel(tx_bits, pe, false);

            d_ml  = decode_bec(rx_bits, erasure_mask, codec, pe, 'ml', false);
            d_map = decode_bec(rx_bits, erasure_mask, codec, pe, 'map', false);

            acc_ml  = acc_ml  + char_error_rate(ref_text, d_ml);
            acc_map = acc_map + char_error_rate(ref_text, d_map);
        end

        cer_ml(m,k)  = acc_ml  / N_TRIALS;
        cer_map(m,k) = acc_map / N_TRIALS;
    end

    fprintf('  %s 编码完成\n', enc_names{m});
end

%% ===== 绘图 =====
figure('Name', 'BEC：CER vs 删除概率', 'NumberTitle', 'off', ...
       'Position', [200 200 900 400], ...
       'Visible', 'off');

colors = ['b', 'r', 'g'];
markers = ['o', 's', '^'];
linestyles = {'--', '-.', '-'};

% ML 曲线
subplot(1,2,1); hold on;
for m = 1:3
    plot(p_range, cer_ml(m,:), ...
         'Color', colors(m), 'LineStyle', linestyles{m}, 'Marker', markers(m), ...
         'LineWidth', 1.8, 'MarkerSize', 5, ...
         'DisplayName', sprintf('%s-ML', enc_names{m}));
end
hold off;
xlabel('删除概率 p（BEC）');
ylabel('字符错误率 CER');
title('BEC 信道 + ML 译码', 'FontSize', 11);
legend('Location', 'northwest');
grid on; xlim([0,1]); ylim([0,1]);

% MAP 曲线
subplot(1,2,2); hold on;
for m = 1:3
    plot(p_range, cer_map(m,:), ...
         'Color', colors(m), 'LineStyle', linestyles{m}, 'Marker', markers(m), ...
         'LineWidth', 1.8, 'MarkerSize', 5, ...
         'DisplayName', sprintf('%s-MAP', enc_names{m}));
end
hold off;
xlabel('删除概率 p（BEC）');
ylabel('字符错误率 CER');
title('BEC 信道 + MAP 译码', 'FontSize', 11);
legend('Location', 'northwest');
grid on; xlim([0,1]); ylim([0,1]);

sgtitle('BEC 信道下三种编码的 CER 对比（ML vs MAP，20次平均）', ...
        'FontSize', 13, 'FontWeight', 'bold');

out_file = 'cer_vs_erasure_prob_three_encodings.png';
exportgraphics(gcf, out_file, 'Resolution', 150);
fprintf('BEC CER 曲线图已保存: %s\n', out_file);
end
