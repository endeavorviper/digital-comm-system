%% main.m  ——  完整数字通信系统仿真
%  ================================================
%  信源编码：哈夫曼 / 香农 / 费诺（可切换）
%  信    道：BSC 二进制对称信道 / BEC 二元删除信道
%  译    码：极大似然（ML）+ 最大后验概率（MAP）
%  ================================================
clc; clear; close all;

%% ===== 输出目录设置 =====
% 所有图片将统一保存到 output/ 子目录，并打印完整路径
[current_dir, ~, ~] = fileparts(mfilename('fullpath'));
output_dir = fullfile(current_dir, 'output');
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
    fprintf('已创建输出目录: %s\n', output_dir);
end
cd(output_dir);
fprintf('\n📁 所有图片将保存到：%s\n', output_dir);

%% ===== 用户参数（按需修改）=====
INPUT_TEXT    = ['关山难越，谁悲失路之人 '...
                 'The theory of information & coding '...
                 '4396'];
P_CHANNEL     = 0.01;        % BSC 误码率 或 BEC 删除率 [0, 1]
ENCODE_METHOD = 'huffman';   % 'huffman' | 'shannon' | 'fano'
CHANNEL_TYPE  = 'bsc';       % 'bsc' | 'bec'
%% ==============================

fprintf('========================================\n');
fprintf('       数字通信系统仿真（MATLAB）\n');
fprintf('========================================\n');
fprintf('输入文本（前60字符）: %s...\n', INPUT_TEXT(1:min(60,end)));
fprintf('编码方式: %s  |  信道类型: %s  |  信道参数: %.3f\n\n', ...
        ENCODE_METHOD, upper(CHANNEL_TYPE), P_CHANNEL);

%% Step 1：信源统计
[symbols, probs, H, text_filt] = source_statistics(INPUT_TEXT);

%% Step 2：三种信源编码
cb_huffman = huffman_encode(symbols, probs);
cb_shannon = shannon_encode(symbols, probs);
cb_fano    = fano_encode(symbols, probs);

%% Step 3：选择编码方式
switch lower(ENCODE_METHOD)
    case 'huffman'; cb_use = cb_huffman;
    case 'shannon'; cb_use = cb_shannon;
    case 'fano';    cb_use = cb_fano;
    otherwise;      error('未知编码方式：%s', ENCODE_METHOD);
end

%% Step 4：构建编解码器 + 生成比特流
[codec, tx_bits] = build_codec(cb_use, text_filt);

% 将先验概率写入 codec（供 MAP 译码使用）
N = numel(codec.enc_sym);
codec.probs = zeros(1, N);
for i = 1:N
    for j = 1:numel(symbols)
        if codec.enc_sym{i} == symbols{j}
            codec.probs(i) = probs(j);
            break;
        end
    end
end

%% Step 5：通过信道（BSC 或 BEC）
fprintf('\n--- 信道传输 ---\n');
switch lower(CHANNEL_TYPE)
    case 'bsc'
        [rx_bits, n_err] = bsc_channel(tx_bits, P_CHANNEL);
        erasure_mask      = false(1, numel(rx_bits));  % BSC 无删除
    case 'bec'
        [rx_bits, erasure_mask, n_err] = bec_channel(tx_bits, P_CHANNEL);
    otherwise
        error('未知信道类型：%s', CHANNEL_TYPE);
end

%% Step 6：译码
fprintf('\n--- 译码 ---\n');
switch lower(CHANNEL_TYPE)
    case 'bsc'
        decoded_ml  = ml_decode(rx_bits, codec);
        decoded_map = map_decode(rx_bits, codec, P_CHANNEL);
    case 'bec'
        decoded_ml  = decode_bec(rx_bits, erasure_mask, codec, P_CHANNEL, 'ml');
        decoded_map = decode_bec(rx_bits, erasure_mask, codec, P_CHANNEL, 'map');
end

%% Step 7：计算性能
n_ref = numel(text_filt);
n_ml  = min(n_ref, numel(decoded_ml));
n_map = min(n_ref, numel(decoded_map));

cer_ml  = sum(text_filt(1:n_ml)  ~= decoded_ml(1:n_ml))  / n_ref;
cer_map = sum(text_filt(1:n_map) ~= decoded_map(1:n_map)) / n_ref;

fprintf('\n========================================\n');
fprintf(' 译码性能汇总\n');
fprintf('========================================\n');
fprintf('信道类型: %s  |  信道参数: %.3f\n', upper(CHANNEL_TYPE), P_CHANNEL);
fprintf('原始文本（前50字符）: %s\n',       text_filt(1:min(50,end)));
fprintf('ML  译码（前50字符）: %s\n',       decoded_ml(1:min(50,n_ml)));
fprintf('MAP 译码（前50字符）: %s\n',       decoded_map(1:min(50,n_map)));
fprintf('ML  字符错误率 CER : %.4f (%.2f%%)\n', cer_ml,  cer_ml*100);
fprintf('MAP 字符错误率 CER : %.4f (%.2f%%)\n', cer_map, cer_map*100);
fprintf('========================================\n\n');

%% Step 7.5：文本传输结果可视化（原文 vs 最终译码）
final_decoded = decoded_map;
final_label = 'MAP';
if cer_ml < cer_map
    final_decoded = decoded_ml;
    final_label = 'ML';
end
visualize_text_comparison(text_filt, final_decoded, final_label, ...
    ENCODE_METHOD, P_CHANNEL, CHANNEL_TYPE);

%% Step 7.6：三种编码方式并列结果展示
visualize_parallel_encodings(text_filt, symbols, probs, cb_huffman, cb_shannon, cb_fano, ...
    P_CHANNEL, ENCODE_METHOD, tx_bits, rx_bits, CHANNEL_TYPE);

%% Step 8：对比三种编码性能（含压缩效率、传输效率）
compare_encodings(symbols, probs, cb_huffman, cb_shannon, cb_fano, text_filt);

%% Step 9：BER/CER vs 信道参数曲线（ML vs MAP）
if strcmpi(CHANNEL_TYPE, 'bsc')
    plot_ber_cer_curve(symbols, probs, codec, ENCODE_METHOD, text_filt);
end

%% Step 10：信道参数 0~1 下三种编码 CER 曲线
plot_cer_vs_channel_prob_three_encodings(text_filt, symbols, probs, ...
    cb_huffman, cb_shannon, cb_fano, 'map', CHANNEL_TYPE);

%% Step 11：BEC 专项：CER vs 删除概率曲线（三种编码）
if strcmpi(CHANNEL_TYPE, 'bec')
    plot_cer_vs_erasure_prob(text_filt, symbols, probs, ...
        cb_huffman, cb_shannon, cb_fano);
end

fprintf('\n仿真完成！\n');
fprintf('📁 所有图片已保存到：\n  %s\n\n', output_dir);
cd(current_dir);  % 回到原工作目录
