function dCFOH = cfog(im, orbin, sigma, clip)
% CFOG特征描述符计算
% 输入:
%   im - 输入图像
%   orbin - 方向直方图bin数量（默认9）
%   sigma - 高斯核标准差（默认0.8）
%   clip - 裁剪阈值（默认0.2）
% 输出:
%   dCFOH - CFOG特征描述符
    if nargin < 4
        orbin = 9;
        sigma = 0.8;
        clip = 0.2;
    end
    [h, w, o] = size(im);
    if o == 3
        im = rgb2gray(im);
    end
    orhist = zeros(h, w, orbin);
    orhistbig = zeros(h, w, orbin + 2);
    [g, or, or1] = imageGradient(im, 0);
    or1(or1 < 0) = or1(or1 < 0) + pi;
    theta = pi / orbin;
    ortemp = (or1 + theta / 2) / theta + 1;
    orInt = floor(ortemp);
    orInt1 = orInt + 1;
    orFrac = ortemp - orInt;
    orInt_val = g .* (1 - orFrac);
    orInt1_val = g .* orFrac;

    for i = 1:h
        for j = 1:w
            orhistbig(i, j, orInt(i, j)) = orInt_val(i, j);
            orhistbig(i, j, orInt1(i, j)) = orInt1_val(i, j);
        end
    end
    f = fspecial('gaussian', max(1, fix(6 * sigma + 1)), sigma);
    f = cat(3, 1 * f, 3 * f, 1 * f);
    dCFOH1 = convn(orhistbig, f, 'same');
    dCFOH = dCFOH1(:, :, 2:end-1);
    sum1 = sum(dCFOH, 3);
    dCFOH = dCFOH ./ (sum1 + 0.000000001);
end

function [g, or, or1] = imageGradient(im, sigma)
% 计算图像梯度
% 输入:
%   im - 输入图像
%   sigma - 高斯平滑标准差
% 输出:
%   g - 梯度幅值
%   or - 梯度方向（atan2）
%   or1 - 梯度方向（atan）
    if sigma ~= 0
        im_s = gauss_filter(im, sigma);
    else
        im_s = im;
    end
    [gx, gy] = gradient(double(im_s));
    g = sqrt(gx .* gx + gy .* gy);
    or = atan2(-gy, gx);
    or1 = atan(gy ./ (gx + 0.00000001));
end

