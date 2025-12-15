function enhanced = LLCE(img, r)
% LLCE - Local Contrast Enhancement
% 局部对比度增强函数
% 输入参数:
%   img: 输入图像
%   r: 局部窗口半径
% 输出参数:
%   enhanced: 增强后的图像

if nargin < 2
    r = 3;  % 默认窗口半径
end

% 转换为double类型
img = double(img);

% 获取图像尺寸
[h, w] = size(img);

% 初始化输出图像
enhanced = zeros(h, w);

% 对每个像素应用局部对比度增强
for i = 1:h
    for j = 1:w
        % 定义局部窗口
        i_min = max(1, i - r);
        i_max = min(h, i + r);
        j_min = max(1, j - r);
        j_max = min(w, j + r);

        % 提取局部区域
        local_region = img(i_min:i_max, j_min:j_max);

        % 计算局部均值和标准差
        local_mean = mean(local_region(:));
        local_std = std(local_region(:));

        % 应用局部对比度增强
        if local_std > 0
            enhanced(i, j) = (img(i, j) - local_mean) / local_std;
        else
            enhanced(i, j) = img(i, j) - local_mean;
        end
    end
end

% 归一化到0-1范围
enhanced = (enhanced - min(enhanced(:))) / (max(enhanced(:)) - min(enhanced(:)));
end
