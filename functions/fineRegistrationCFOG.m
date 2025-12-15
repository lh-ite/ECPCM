function [matchedPoints1, matchedPoints2] = fineRegistrationCFOG(im1Gray, im2Gray, batchSize, pointRefine)
% 精配准函数 - 基于CFOG特征的精细图像配准
% 输入参数:
%   im1Gray: 参考图像灰度图
%   im2Gray: 待配准图像灰度图
%   batchSize: 批处理窗口大小
%   pointRefine: 粗配准后的特征点坐标
% 输出参数:
%   matchedPoints1: 参考图像匹配点
%   matchedPoints2: 待配准图像匹配点

% 提取CFOG特征
featureRef = CFOGmatlab1(single(im1Gray));
featureSen = CFOGmatlab1(single(im2Gray));

% 获取特征点数量
[pNum, ~] = size(pointRefine);
kpoint2 = pointRefine;
kpoint1 = pointRefine;

% 对每个特征点进行精细匹配
for i = 1:pNum
    % 定义批处理窗口
    xStart = round(pointRefine(i,1) - batchSize/2);
    xEnd = round(pointRefine(i,1) + batchSize/2);
    yStart = round(pointRefine(i,2) - batchSize/2);
    yEnd = round(pointRefine(i,2) + batchSize/2);

    % 边界检查
    xStart = max(xStart, 1);
    xEnd = min(xEnd, size(featureRef, 1));
    yStart = max(yStart, 1);
    yEnd = min(yEnd, size(featureRef, 2));

    % 提取局部特征块
    im1Batch = featureRef(xStart:xEnd, yStart:yEnd, :);
    im2Batch = featureSen(xStart:xEnd, yStart:yEnd, :);

    % FFT相关匹配
    [mm, nm, ~] = fftMatch(im2Batch, im1Batch, 1);
    maxI = mm(1);
    maxJ = nm(1);

    % 更新匹配点坐标
    kpoint1(i,:) = [pointRefine(i,1) + maxI, pointRefine(i,2) + maxJ];
end

% 格式化输出结果
matchedPoints1 = [kpoint1(:,2), kpoint1(:,1)];
matchedPoints2 = [kpoint2(:,2), kpoint2(:,1)];