function compare_encodings(symbols, probs, cb_huffman, cb_shannon, cb_fano, ref_text)
% COMPARE_ENCODINGS  对比三种编码的性能指标并绘图
%   新增：压缩比、传输效率指标
%   ref_text: 原始文本（用于计算传输效率）

N = numel(symbols);
H = -sum(probs(probs>0) .* log2(probs(probs>0)));

% 计算各编码方式的加权平均码长
function avg = calc_avg(cb, syms, p)
    avg = 0;
    for k = 1:numel(syms)
        for j = 1:size(cb,1)
            if cb{j,1} == syms{k}
                avg = avg + p(k) * numel(cb{j,2});
                break;
            end
        end
    end
end

avg_h = calc_avg(cb_huffman, symbols, probs);
avg_s = calc_avg(cb_shannon, symbols, probs);
avg_f = calc_avg(cb_fano,    symbols, probs);

% 编码效率（%）
eff_h = H / avg_h * 100;
eff_s = H / avg_s * 100;
eff_f = H / avg_f * 100;

% 压缩比：原始每字符比特数 / 平均码长
% 假设原始文本每个字符用 8 bits（ASCII 扩展）或 16 bits（Unicode）
% 这里以 8 bits/char 为基准
bits_per_char_raw = 8;
compression_ratio_h = bits_per_char_raw / avg_h;
compression_ratio_s = bits_per_char_raw / avg_s;
compression_ratio_f = bits_per_char_raw / avg_f;

% 传输效率：信源熵 / 平均码长（理论最大效率为 1）
transmission_efficiency_h = H / avg_h;
transmission_efficiency_s = H / avg_s;
transmission_efficiency_f = H / avg_f;

fprintf('\n========================================\n');
fprintf('       三种编码性能对比\n');
fprintf('========================================\n');
fprintf('信源熵 H = %.4f bits/符号\n', H);
fprintf('原始每字符基准: %d bits（8-bit ASCII）\n\n', bits_per_char_raw);

fprintf('%-12s %-12s %-14s %-12s %-12s\n', ...
    '编码方式', '平均码长', '编码效率(%)', '压缩比', '传输效率');
fprintf('%-12s %-12.4f %-14.2f %-12.2f %-12.4f\n', ...
    'Huffman', avg_h, eff_h, compression_ratio_h, transmission_efficiency_h);
fprintf('%-12s %-12.4f %-14.2f %-12.2f %-12.4f\n', ...
    'Shannon', avg_s, eff_s, compression_ratio_s, transmission_efficiency_s);
fprintf('%-12s %-12.4f %-14.2f %-12.2f %-12.4f\n', ...
    'Fano',    avg_f, eff_f, compression_ratio_f, transmission_efficiency_f);
fprintf('========================================\n');

% --- 打印码表（前8个符号）---
fprintf('\n码表对比（前8个符号）：\n');
fprintf('%-6s %-8s %-12s %-12s %-12s\n', '符号', '概率', '哈夫曼', '香农', '费诺');
for i = 1:min(8, N)
    sym = symbols{i};
    if sym == ' '; sym_d = 'SP'; else; sym_d = sym; end
    c_h = ''; c_s = ''; c_f = '';
    for j = 1:size(cb_huffman,1)
        if cb_huffman{j,1} == symbols{i}; c_h = cb_huffman{j,2}; break; end
    end
    for j = 1:size(cb_shannon,1)
        if cb_shannon{j,1} == symbols{i}; c_s = cb_shannon{j,2}; break; end
    end
    for j = 1:size(cb_fano,1)
        if cb_fano{j,1}    == symbols{i}; c_f = cb_fano{j,2};    break; end
    end
    fprintf('%-6s %-8.4f %-12s %-12s %-12s\n', sym_d, probs(i), c_h, c_s, c_f);
end

%% ===== 绘图：四指标对比 =====
figure('Name', '编码性能对比（四指标）', 'NumberTitle', 'off', ...
       'Position', [100 100 1000 600], ...
       'Visible', 'off');

% 子图1：平均码长 vs 熵下界
subplot(2,2,1);
bar_data = [avg_h, avg_s, avg_f, H];
bar(bar_data, 'FaceColor', 'flat');
set(gca, 'XTickLabel', {'Huffman','Shannon','Fano','熵下界'});
title('平均码长对比', 'FontSize', 11);
ylabel('平均码长 (bits/符号)');
ylim([0, max(bar_data)*1.3]);
for k = 1:4
    text(k, bar_data(k)+0.02, sprintf('%.3f', bar_data(k)), ...
         'HorizontalAlignment','center', 'FontSize', 9);
end
grid on;

% 子图2：编码效率（%）
subplot(2,2,2);
bar_eff = [eff_h, eff_s, eff_f];
b = bar(bar_eff, 'FaceColor', 'flat');
b.CData = [0.2 0.6 0.8; 0.9 0.5 0.2; 0.4 0.8 0.4];
set(gca, 'XTickLabel', {'Huffman','Shannon','Fano'});
title('编码效率（理论上限100%）', 'FontSize', 11);
ylabel('效率 (%)');
ylim([0, 110]);
yline(100, 'r--', '理论上限', 'LineWidth', 1.2);
for k = 1:3
    text(k, bar_eff(k)+1, sprintf('%.2f%%', bar_eff(k)), ...
         'HorizontalAlignment','center', 'FontSize', 9);
end
grid on;

% 子图3：压缩比（原始8 bits/char ÷ 平均码长）
subplot(2,2,3);
bar_cr = [compression_ratio_h, compression_ratio_s, compression_ratio_f];
b3 = bar(bar_cr, 'FaceColor', 'flat');
b3.CData = [0.3 0.3 0.8; 0.8 0.4 0.2; 0.2 0.7 0.3];
set(gca, 'XTickLabel', {'Huffman','Shannon','Fano'});
title('压缩比（8 bits/char ÷ 平均码长）', 'FontSize', 11);
ylabel('压缩比（越高越好）');
ylim([0, max(bar_cr)*1.3]);
for k = 1:3
    text(k, bar_cr(k)+0.02, sprintf('%.2f', bar_cr(k)), ...
         'HorizontalAlignment','center', 'FontSize', 9);
end
grid on;

% 子图4：传输效率（H / 平均码长）
subplot(2,2,4);
bar_te = [transmission_efficiency_h, transmission_efficiency_s, transmission_efficiency_f];
b4 = bar(bar_te, 'FaceColor', 'flat');
b4.CData = [0.5 0.2 0.8; 0.8 0.6 0.2; 0.2 0.8 0.6];
set(gca, 'XTickLabel', {'Huffman','Shannon','Fano'});
title('传输效率（H / 平均码长）', 'FontSize', 11);
ylabel('传输效率（≤1，越高越好）');
ylim([0, 1.1]);
yline(1, 'r--', '理论极限', 'LineWidth', 1.2);
for k = 1:3
    text(k, bar_te(k)+0.01, sprintf('%.4f', bar_te(k)), ...
         'HorizontalAlignment','center', 'FontSize', 9);
end
grid on;

sgtitle('三种信源编码方案性能对比（含压缩/传输效率）', 'FontSize', 13, 'FontWeight', 'bold');

% 保存图片
exportgraphics(gcf, 'encoding_performance_4metrics.png', 'Resolution', 150);
fprintf('\n性能对比图已保存: encoding_performance_4metrics.png\n');
end
