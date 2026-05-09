function codebook = huffman_encode(symbols, probs)
% HUFFMAN_ENCODE  哈夫曼编码
%   symbols : 1×N cell，字符符号列表
%   probs   : 1×N double，对应概率
%   codebook: N×2 cell，{symbol, codeword_string}

N = numel(symbols);

% --- 初始化：用三个并行数组代替结构体树 ---
% node_sym{i}   : 叶节点符号（内部节点为空 {}）
% node_prob(i)  : 节点概率
% node_left(i)  : 左子节点索引（0 = 无）
% node_right(i) : 右子节点索引（0 = 无）
node_sym   = cell(1, 2*N);
node_prob  = zeros(1, 2*N);
node_left  = zeros(1, 2*N);
node_right = zeros(1, 2*N);

% 初始化叶节点
for i = 1:N
    node_sym{i}  = symbols{i};
    node_prob(i) = probs(i);
end
total_nodes = N;

% active(i) = true 表示该节点还在队列里（未被合并为子节点）
active = [true(1, N), false(1, N)];

% --- 哈夫曼合并过程 ---
for iter = 1:(N-1)
    % 找概率最小的两个活跃节点
    active_idx = find(active(1:total_nodes));
    active_probs = node_prob(active_idx);
    [sorted_p, sort_ord] = sort(active_probs, 'ascend');
    idx1 = active_idx(sort_ord(1));
    idx2 = active_idx(sort_ord(2));

    % 新建内部节点
    total_nodes = total_nodes + 1;
    node_sym{total_nodes}   = {};           % 内部节点无符号
    node_prob(total_nodes)  = sorted_p(1) + sorted_p(2);
    node_left(total_nodes)  = idx1;         % 左子 → 概率小
    node_right(total_nodes) = idx2;         % 右子 → 概率大
    active(total_nodes) = true;

    % 将两个子节点移出队列
    active(idx1) = false;
    active(idx2) = false;
end

root = total_nodes; % 最后建立的节点就是根

% --- 遍历树，分配编码 ---
codebook = cell(N, 2);
code_assigned = 0;

% 用显式栈代替递归，彻底避免结构体索引问题
% 栈元素：[node_index, prefix_string]
stack_nodes  = zeros(1, 2*N);
stack_prefix = cell(1, 2*N);
stack_top = 1;
stack_nodes(1)  = root;
stack_prefix{1} = '';

while stack_top > 0
    cur_node   = stack_nodes(stack_top);
    cur_prefix = stack_prefix{stack_top};
    stack_top  = stack_top - 1;

    l = node_left(cur_node);
    r = node_right(cur_node);

    if l == 0 && r == 0
        % 叶节点
        code_assigned = code_assigned + 1;
        codebook{code_assigned, 1} = node_sym{cur_node};
        codebook{code_assigned, 2} = cur_prefix;
    else
        % 内部节点：压入左右子节点
        if l ~= 0
            stack_top = stack_top + 1;
            stack_nodes(stack_top)  = l;
            stack_prefix{stack_top} = [cur_prefix '0'];
        end
        if r ~= 0
            stack_top = stack_top + 1;
            stack_nodes(stack_top)  = r;
            stack_prefix{stack_top} = [cur_prefix '1'];
        end
    end
end

% 特殊情况：只有一个符号
if N == 1
    codebook{1,1} = symbols{1};
    codebook{1,2} = '0';
end

end
