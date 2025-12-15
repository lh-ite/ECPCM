function [m, n, k] = fftmatch(ref, sen, flag)
% 基于FFT的图像匹配
% 输入:
%   ref - 参考图像块
%   sen - 搜索图像块
%   flag - 匹配标志（未使用）
% 输出:
%   m - 行偏移量
%   n - 列偏移量
%   k - 匹配索引

    % 确保输入是double类型
    ref = double(ref);
    sen = double(sen);

    % 计算FFT
    FTsmall = fftn(ref);
    FTbig = fftn(sen);

    % 计算互相关
    FTsmall_C = conj(FTsmall);
    FTR = FTbig .* FTsmall_C;

    % 逆FFT得到相关系数
    peak_correlation = abs(ifftn(FTR));

    % 找到最大值位置
    max_n = max(peak_correlation(:));
    s = size(peak_correlation);
    Lax = find(peak_correlation == max_n);

    % 获取最大值位置的坐标
    [m, n, k] = ind2sub(s, Lax(1));  % 只取第一个最大值

    % 调整坐标以处理FFT的循环移位
    if m > size(ref, 1) / 2
        m = m - size(ref, 1);
    end
    if n > size(sen, 2) / 2
        n = n - size(sen, 2);
    end

    % MATLAB的FFT是从0开始索引，所以需要减1
    m = m - 1;
    n = n - 1;
end
