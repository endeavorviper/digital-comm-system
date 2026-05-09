function [rx_bits, n_errors] = bsc_channel(tx_bits, p_error, verbose)
% BSC_CHANNEL  二进制对称信道（Binary Symmetric Channel）
%   tx_bits  : 1×M double (0/1)，发送比特
%   p_error  : 信道误码率 (0~0.5)
%   verbose  : 是否打印（默认 true）
%   rx_bits  : 1×M double (0/1)，接收比特
%   n_errors : 发生翻转的比特数

if nargin < 3; verbose = true; end

M = numel(tx_bits);
flip_mask = rand(1, M) < p_error;
rx_bits   = mod(tx_bits + double(flip_mask), 2);
n_errors  = sum(flip_mask);

if verbose
    fprintf('--- BSC 信道 ---\n');
    fprintf('发送比特数: %d  |  翻转位数: %d  |  实际 BER: %.4f\n', ...
            M, n_errors, n_errors / M);
end
end