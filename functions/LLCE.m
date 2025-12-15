function enhanceGray = LLCE(I, r)
% 局部对比度增强 (Local Linear Contrast Enhancement)
% 输入:
%   I - 输入灰度图像
%   r - 局部窗口半径
% 输出:
%   enhanceGray - 增强后的图像
    I = double(I);
    [hei, wid] = size(I);
    N = boxfilter(ones(hei, wid), r);
    Mean = boxfilter(I, r) ./ N;
    p = (Mean + 2 * (I - Mean));

    eps = 0.0001;
    mean_I = boxfilter(I, r) ./ N;
    mean_p = boxfilter(p, r) ./ N;
    mean_Ip = boxfilter(I .* p, r) ./ N;
    cov_Ip = mean_Ip - mean_I .* mean_p;
    mean_II = boxfilter(I .* I, r) ./ N;
    var_I = mean_II - mean_I .* mean_I;
    a = cov_Ip ./ (var_I + eps);
    b = mean_p - a .* mean_I;
    mean_a = boxfilter(a, r) ./ N;
    mean_b = boxfilter(b, r) ./ N;
    enhanceGray = (mean_a .* I + mean_b);

    enhanceGray = (enhanceGray + p) / 2;
    enhanceGray = enhanceGray - min(enhanceGray(:));
    enhanceGray = enhanceGray / max(enhanceGray(:));
end
