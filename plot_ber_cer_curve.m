function plot_ber_cer_curve(symbols, probs, codec, encode_method, ref_text)
% PLOT_BER_CER_CURVE  扫描不同误码率，绘制 ML vs MAP 的 CER 曲线（蒙特卡洛平均）

N_TRIALS  = 20;
ber_range = [0, 0.01, 0.02, 0.05, 0.08, 0.10, 0.15, 0.20, 0.25, 0.30];
n_ber     = numel(ber_range);

cer_ml  = zeros(1, n_ber);
cer_map = zeros(1, n_ber);

% 把先验概率写入 codec
codec_map       = codec;
codec_map.probs = lookup_probs(codec.enc_sym, symbols, probs);

% 生成原始比特流（只需一次）
bit_parts = cell(1, numel(ref_text));
for k = 1:numel(ref_text)
    c     = ref_text(k);
    found = false;
    for i = 1:numel(codec.enc_sym)
        if codec.enc_sym{i} == c
            bit_parts{k} = codec.enc_code{i};
            found = true;
            break;
        end
    end
    if ~found; bit_parts{k} = ''; end
end
all_bits_str = strjoin(bit_parts, '');
tx_bits_ref  = double(all_bits_str == '1');

n_ref = numel(ref_text);

fprintf('\n--- 扫描 BER 范围，计算 ML/MAP 性能曲线（每点 %d 次平均）---\n', N_TRIALS);
for k = 1:n_ber
    pe      = ber_range(k);
    acc_ml  = 0;
    acc_map = 0;
    for t = 1:N_TRIALS
        [rx_bits, ~] = bsc_channel(tx_bits_ref, pe, false);

        d_ml  = ml_decode(rx_bits, codec, false);
        d_map = map_decode(rx_bits, codec_map, pe, false);

        n_ml  = min(n_ref, numel(d_ml));
        n_map = min(n_ref, numel(d_map));

        acc_ml  = acc_ml  + sum(ref_text(1:n_ml)  ~= d_ml(1:n_ml))  / n_ref;
        acc_map = acc_map + sum(ref_text(1:n_map) ~= d_map(1:n_map)) / n_ref;
    end
    cer_ml(k)  = acc_ml  / N_TRIALS;
    cer_map(k) = acc_map / N_TRIALS;
end

% --- 绘图 ---
figure('Name', 'BER-CER 曲线', 'NumberTitle', 'off', 'Position', [200 200 700 450], ...
       'Visible', 'off');
plot(ber_range, cer_ml,  'b-o', 'LineWidth', 2, 'MarkerSize', 7, 'DisplayName', 'ML 译码');
hold on;
plot(ber_range, cer_map, 'r-s', 'LineWidth', 2, 'MarkerSize', 7, 'DisplayName', 'MAP 译码');
plot(ber_range, ber_range, 'k--', 'LineWidth', 1, 'DisplayName', 'BER参考线');
hold off;

xlabel('信道误码率 BER');
ylabel('字符错误率 CER');
title(sprintf('ML vs MAP 译码性能对比（%s编码，%d次平均）', encode_method, N_TRIALS));
legend('Location', 'northwest');
grid on;
xlim([0, 0.32]);
ylim([0, 1]);

% --- 保存图片 ---
out_file = 'ber_cer_curve.png';
exportgraphics(gcf, out_file, 'Resolution', 150);
fprintf('BER-CER 曲线图已保存: %s\n', fullfile(pwd, out_file));
close(gcf);