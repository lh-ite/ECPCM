function [m, n, k] = fftMatch(ref, sen, flag)
% FFT相关匹配函数
% 输入参数:
%   ref: 参考图像块
%   sen: 待匹配图像块
%   flag: 标志位
% 输出参数:
%   m, n, k: 匹配位置偏移

FTsmall = fftn(double(ref));
FTbig = fftn(double(sen));
FTsmall_C = conj(FTsmall);
FTR = FTbig .* FTsmall_C;
peak_correlation = abs(ifftn(FTR));
max_n = max(peak_correlation(:));
s = size(peak_correlation);
Lax = find(peak_correlation == max_n);
[m, n, k] = ind2sub(s, Lax);

% 调整坐标系
if m > size(ref, 1)/2
    m = m - size(ref, 1);
end
if n > size(sen, 2)/2
    n = n - size(ref, 2);
end

m = m - 1;
n = n - 1;
end