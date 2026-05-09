function [rx_bits, erasure_mask, n_erasures] = bec_channel(tx_bits, p_erasure, verbose)
% BEC_CHANNEL  二元删除信道（Binary Erasure Channel）
%   tx_bits      : 1×M double (0/1)，发送比特
%   p_erasure    : 删除概率 (0~1)
%   verbose      : 是否打印（默认 true）
%   rx_bits      : 1×M double (0/1)，接收比特（删除位置用 0 占位）
%   erasure_mask : 1×M logical，true 表示对应位置被删除
%   n_erasures   : 删除的比特数
%
%  BEC 信道模型：
%    每个比特以概率 (1-p) 正确接收，以概率 p 被删除（接收端知晓删除位置）
%    删除的位置在 erasure_mask 中标记为 true，rx_bits 中对应位置用 0 占位

if nargin < 3; verbose = true; end

M = numel(tx_bits);
erasure_mask = rand(1, M) < p_erasure;

rx_bits = tx_bits;              % BEC：未删除的比特正确接收
rx_bits(erasure_mask) = 0;     % 删除位置用 0 占位（实际值由 erasure_mask 标记）
n_erasures = sum(erasure_mask);

if verbose
    fprintf('--- BEC 信道 ---\n');
    fprintf('发送比特数: %d  |  删除位数: %d  |  实际删除率: %.4f\n', ...
            M, n_erasures, n_erasures / M);
end
end
