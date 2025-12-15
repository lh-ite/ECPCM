function dCFOH = CFOGmatlab1(im, orbin, sigma, clip)
% CFOG特征提取函数
% 输入参数:
%   im: 输入图像
%   orbin: 方向bin数，默认9
%   sigma: 高斯滤波标准差，默认0.8
%   clip: 裁剪参数，默认0.2
% 输出参数:
%   dCFOH: CFOG特征描述符

if nargin < 4
    orbin = 9;
    sigma = 0.8;
    clip = 0.2;
end

[h, w, o] = size(im);
if o == 3
    im = rgb2gray(im);
end
% 初始化方向直方图
orhist = zeros(h, w, orbin);
orhistbig = zeros(h, w, orbin + 2);

% 计算图像梯度
[g, or, or1] = imgrad22(im, 0);
or1(or1 < 0) = or1(or1 < 0) + pi;
theta = pi / orbin;
ortemp = (or1 + theta/2) / theta + 1;
orInt = floor(ortemp);
orInt1 = orInt + 1;
orFrac = ortemp - orInt;
orInt_val = g .* (1 - orFrac);
orInt1_val = g .* orFrac;

% 构建方向直方图
for i = 1:h
    for j = 1:w
        orhistbig(i, j, orInt(i, j)) = orInt_val(i, j);
        orhistbig(i, j, orInt1(i, j)) = orInt1_val(i, j);
    end
end

% 高斯平滑
f = fspecial('gaussian', max(1, fix(6*sigma+1)), sigma);
f = cat(3, 1*f, 3*f, 1*f);
dCFOH1 = convn(orhistbig, f, 'same');
dCFOH = dCFOH1(:, :, 2:end-1);
sum1 = sum(dCFOH, 3);
dCFOH = dCFOH ./ (sum1 + 0.000000001);
    
function [g, or, or1] = imgrad22(im, sigma)
% 计算图像梯度
if sigma ~= 0
    im_s = gaussfilt(im, sigma);
else
    im_s = im;
end
[gx, gy] = gradient(double(im_s));
g = sqrt(gx.*gx + gy.*gy);
or = atan2(-gy, gx);
or1 = atan(gy ./ (gx + 0.00000001));



