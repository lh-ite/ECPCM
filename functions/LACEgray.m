function enhanced = LACEgray(img)
% LACE灰度图像增强函数
% 输入参数:
%   img: 输入图像
% 输出参数:
%   enhanced: 增强后的图像

% 确保输入是灰度图
if size(img, 3) > 1
    img = rgb2gray(img);
end

% 直接应用LLCE增强
enhanced = LLCE(double(img), 5);
end