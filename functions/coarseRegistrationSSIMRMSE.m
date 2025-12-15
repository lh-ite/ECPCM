function [imRes, points, HInit] = coarseRegistrationSSIMRMSE(im1, im2, pointNum)
% 粗配准函数 - 基于SSIM和RMSE的图像粗配准
% 输入参数:
%   im1: 可见光图像
%   im2: 红外图像
%   pointNum: 特征点数量
% 输出参数:
%   imRes: 配准后的图像
%   points: 特征点坐标
%   HInit: 初始变换矩阵

tic;
im1In = im1;
im2In = im2;
[xIm1, yIm1, band] = size(im1);
[xIm2In, yIm2In, band2] = size(im2In);
i = 1;
step = 0.01;
% 转换为灰度图像
if band == 3
    im1Gray = im2gray(im1);
else
    im1Gray = im1;
    im2Gray = im2;
end

% 初始化变换矩阵
HInit = [1.000 0 yIm1/2
    0 1.000 xIm1/2
    0 0 1.000];
tformTranslate = maketform('affine', (HInit)');
T = affine2d(tformTranslate.tdata.T);
pointsIR = [];

% 如果图像尺寸不同，进行尺度变换搜索
if xIm1 ~= xIm2In && yIm1 ~= yIm2In
    % 尺度变换搜索循环
    for S = 1:step:1.5
        centX = round((xIm1/2)-((xIm2In*S)/2));
        centY = round((yIm1/2)-((yIm2In*S)/2));
        HInit = [S  0  centY
            0  S  centX
            0  0  1.000];
        tformTranslate = maketform('affine', (HInit)');
        T = affine2d(tformTranslate.tdata.T);

        im2 = imwarp(im2In, T, 'OutputView', imref2d(size(im1)));

        if band2 == 3
            im2Gray = im2gray(im2);
        else
            im2Gray = im2;
        end
        % 显示当前尺度
        disp(['当前尺度: ', num2str(S)]);

        % 裁剪图像到相同尺寸
        cutIm1 = im1Gray(centX:centX+round(xIm2In*S), centY:centY+round(yIm2In*S));
        cutIm2 = im2Gray(centX:centX+round(xIm2In*S), centY:centY+round(yIm2In*S));

        % 缩放图像以加速计算
        cutIm1 = imresize(cutIm1, [xIm2In/4, yIm2In/4]);
        cutIm2 = imresize(cutIm2, [xIm2In/4, yIm2In/4]);

        % 提取相位一致性特征
        [mC1, ~, ~, ~, ~, eoC1, ~] = phasecong3(cutIm1);
        [mC2, ~, ~, ~, ~, eoC2, ~] = phasecong3(cutIm2);

        % 应用LACE增强
        mC1 = LACEgray(mC1);
        mC2 = LACEgray(mC2);
        % m_c1 =m_c1 - GTV(m_c1,5,0.01,0.1,4);
        % m_c2 = m_c2 - GTV(m_c2,5,0.01,0.1,4);
        
        % m_c1 =m_c1 - GTV(m_c1);
        % m_c2 = m_c2 - GTV(m_c2);
        % m_c1 =m_c1 - tsmooth(m_c1,0.001,1);
        % m_c2 = m_c2 - tsmooth(m_c2,0.001,1);
        % m_c1 = m_c1 - RollingGuidanceFilter_Guided(m_c1,2,0.05,4);
        % m_c2 = m_c2 - RollingGuidanceFilter_Guided(m_c2,2,0.05,4);
        % m_c1 = m_c1 - imgaussfilt(m_c1);
        % m_c2 = m_c2 - imgaussfilt(m_c2);
        % m_c1 = bilateralFilter(m_c1);
        % m_c2 = bilateralFilter(m_c1);

        % 计算互信息 (Mutual Information)
        mi = mutualInformation(mC1, mC2);
        mm1(i) = mi;

        % 计算RMSE
        diff = mC1 - mC2;
        mse = mean(diff(:).^2);
        rmseVal = sqrt(mse);
        rr1(i) = rmseVal;
        i = i + 1;
    end
    % 计算最优尺度
    alpha = 0.4; % 权重系数，平衡MI和RMSE
    % 归一化RMSE (越小越好，归一化后0最好)
    maxRr = max(rr1);
    rmseNorm = 1 - (rr1 / maxRr);
    % 归一化MI (越大越好)
    maxMm = max(mm1);
    miNorm = mm1 / maxMm;
    % 计算综合得分
    compositeScores = alpha * miNorm + (1 - alpha) * rmseNorm;
    % 找到最大综合得分的索引
    [~, p] = max(compositeScores);
    finalS = 1 + step * (p - 1);
    disp(['最优尺度: ', num2str(finalS)]);
    % 根据最优尺度更新变换矩阵
    centX = (xIm1/2) - ((xIm2In * finalS)/2);
    centY = (yIm1/2) - ((yIm2In * finalS)/2);
    HInit = [finalS  0  centY
        0  finalS  centX
        0  0  1.000];
    tformTranslate = maketform('affine', (HInit)');
    T = affine2d(tformTranslate.tdata.T);
end

% 提取红外图像的相位一致性特征用于特征点检测
[m1, m2, ~, ~, ~, eo1, ~] = phasecong3(im2In);

numCut = 6;  % 将图像分为6x6个区域
pNum = pointNum * numCut * numCut;
stepX = floor(xIm2In / numCut);  % 确保是整数
stepY = floor(yIm2In / numCut);  % 确保是整数

% 在最大矩图上使用Harris检测器提取边缘特征点 (局部区域)
for cX = 1:numCut
    for cY = 1:numCut
        if cX == 1
            pointLeftUpX = 1;
        else
            pointLeftUpX = (cX-1) * stepX;
        end

        if cY == 1
            pointLeftUpY = 1;
        else
            pointLeftUpY = (cY-1) * stepY;
        end

        pointLeftUp = [pointLeftUpX, pointLeftUpY];

        % 裁剪局部区域
        m1Cut = m1(pointLeftUpX:pointLeftUpX+stepX-1, pointLeftUpY:pointLeftUpY+stepY-1);

        % m1_points = detectFASTFeatures(m1_cut,'MinContrast',0.05);
        % m1_points = detectHarrisFeatures(m1_cut,'FilterSize',3);
        % Harris and SIFT is better than FAST,SURF can't find corner,ORB also can't
        % find corner
        % m1_points = detectSURFFeatures(m1_cut);
        % ContrastThreshold 越小越多，EdgeThreshold无影响，NumLayerInOCtave
        % 越小越多,sigma越小越多
        % 应用LACE增强局部图像
        m1Cut = LACEgray(m1Cut);

        % 使用Harris角点检测器检测特征点
        m1Points = detectHarrisFeatures(m1Cut, "MinQuality", 0.09);
        % 选择最强的特征点
        m1Points = m1Points.selectStrongest(pointNum);

        % 过滤低质量特征点
        m1Points(find(m1Points.Metric < 0.001)) = [];

        % 将局部坐标转换为全局坐标
        P = [m1Points.Location(:,1) + pointLeftUpY - 1, ...
             m1Points.Location(:,2) + pointLeftUpX - 1, ...
             ones(m1Points.Count, 1)];
        pointsIR = [pointsIR; P(:,1:2)];

        % 应用变换矩阵
        PP = (HInit) * P';
        PPP = PP';
        if cX == 1 && cY == 1
            points = PPP;
        else
            points = [points; PPP];
        end
    end
end

% 应用最终变换
imRes = imwarp(im2In, T, 'OutputView', imref2d(size(im1)));

% 可视化结果
figure('Name', '可见光图像特征点可视化');
imshow(im1In);
hold on;
scatter(points(:,1), points(:,2), 5, 'r', 'filled', 'MarkerEdgeAlpha', 0.7, 'MarkerFaceAlpha', 0.7);

figure('Name', '红外图像特征点可视化');
imshow(im2In);
hold on;
scatter(pointsIR(:,1), pointsIR(:,2), 5, 'r', 'filled', 'MarkerEdgeAlpha', 0.7, 'MarkerFaceAlpha', 0.7);

disp(['最优尺度: ', num2str(finalS)]);
toc;
end
