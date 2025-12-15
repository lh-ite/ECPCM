function [matchedPoints1, matchedPoints2] = fineRegistration(im1Gray, im2Gray, batchSize, pointRefine)
% 精配准：基于CFOG特征描述符和FFT匹配
% 输入:
%   im1Gray - 参考图像（灰度）
%   im2Gray - 待配准图像（灰度）
%   batchSize - 匹配窗口大小
%   pointRefine - 粗配准得到的特征点坐标 [Nx2]
% 输出:
%   matchedPoints1 - 参考图像上的匹配点
%   matchedPoints2 - 待配准图像上的匹配点
    % 计算CFOG特征
    featureRef = cfog(single(im1Gray));
    featureSen = cfog(single(im2Gray));
    
    [pNum, ~] = size(pointRefine);
    kpoint2 = pointRefine;
    kpoint1 = pointRefine;
    
    % 对每个特征点进行局部匹配
    for i = 1:pNum
        xStart = round(pointRefine(i, 1) - batchSize/2);
        xEnd = round(pointRefine(i, 1) + batchSize/2);
        yStart = round(pointRefine(i, 2) - batchSize/2);
        yEnd = round(pointRefine(i, 2) + batchSize/2);
        
        % 边界检查
        xStart = max(xStart, 1);
        xEnd = min(xEnd, size(featureRef, 1));
        yStart = max(yStart, 1);
        yEnd = min(yEnd, size(featureRef, 2));
        
        im1Batch = featureRef(xStart:xEnd, yStart:yEnd, :);
        im2Batch = featureSen(xStart:xEnd, yStart:yEnd, :);
        
        % FFT匹配
        [mm, nm, kk] = fftmatch(im2Batch, im1Batch, 1);
        maxI = mm(1);
        maxJ = nm(1);
        
        kpoint1(i, :) = [pointRefine(i, 1) + maxI, pointRefine(i, 2) + maxJ];
    end
    
    matchedPoints1 = [kpoint1(:,2), kpoint1(:,1)];
    matchedPoints2 = [kpoint2(:,2), kpoint2(:,1)];
end

