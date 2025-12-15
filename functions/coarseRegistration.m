function [imRes, points, HInit] = coarseRegistration(im1, im2, pointNum)
% 粗配准：基于相位一致性特征和Harris角点检测
% 输入:
%   im1 - 可见光图像
%   im2 - 红外图像
%   pointNum - 每个网格块提取的特征点数量
% 输出:
%   imRes - 配准后的红外图像
%   points - 配准后的特征点坐标
%   HInit - 初始单应性矩阵
    tic;
    im1In = im1;
    im2In = im2;
    [xIm1, yIm1, band] = size(im1);
    [xIm2In, yIm2In, band2] = size(im2In);
    i = 1;
    step = 0.01;
    
    % 转换为灰度图
    if band == 3
        im1Gray = im2gray(im1);
    else
        im1Gray = im1;
        im2Gray = im2;
    end
    
    % 初始化单应性矩阵
    HInit = [1.000, 0, yIm1/2;
             0, 1.000, xIm1/2;
             0, 0, 1.000];
    tformTranslate = maketform('affine', (HInit)');
    T = affine2d(tformTranslate.tdata.T);
    pointsIR = [];
    
    % 如果图像尺寸不同，进行尺度搜索
    if xIm1 ~= xIm2In && yIm1 ~= yIm2In
        for S = 1:step:1.5
            centX = round((xIm1/2) - ((xIm2In*S)/2));
            centY = round((yIm1/2) - ((yIm2In*S)/2));
            HInit = [S, 0, centY;
                     0, S, centX;
                     0, 0, 1.000];
            tformTranslate = maketform('affine', (HInit)');
            T = affine2d(tformTranslate.tdata.T);
            
            im2 = imwarp(im2In, T, 'OutputView', imref2d(size(im1)));
            
            if band2 == 3
                im2Gray = im2gray(im2);
            else
                im2Gray = im2;
            end
            
            % 裁剪图像块进行匹配
            cutIm1 = im1Gray(centX:centX+round(xIm2In*S), centY:centY+round(yIm2In*S));
            cutIm2 = im2Gray(centX:centX+round(xIm2In*S), centY:centY+round(yIm2In*S));
            
            cutIm1 = imresize(cutIm1, [xIm2In/4, yIm2In/4]);
            cutIm2 = imresize(cutIm2, [xIm2In/4, yIm2In/4]);
            
            % 计算相位一致性
            [mC1, ~, ~, ~, ~, ~, ~] = phasecong3(cutIm1);
            [mC2, ~, ~, ~, ~, ~, ~] = phasecong3(cutIm2);
            
            % LACE增强
            mC1 = LACE_gray(mC1);
            mC2 = LACE_gray(mC2);
            
            % 计算互信息和RMSE
            mi = mutinf(mC1, mC2);
            mm1(i) = mi;
            diff = mC1 - mC2;
            mse = mean(diff(:).^2);
            rmseVal = sqrt(mse);
            rr1(i) = rmseVal;
            i = i + 1;
        end
        
        % 计算综合得分
        alpha = 0.4; % 权重
        maxRr = max(rr1);
        rmseNorm = 1 - (rr1 / maxRr);
        maxMm = max(mm1);
        miNorm = mm1 / maxMm;
        compositeScores = alpha * miNorm + (1 - alpha) * rmseNorm;
        [~, p] = max(compositeScores);
        finalS = 1 + step * (p - 1);
        
        % 使用最优尺度
        centX = (xIm1/2) - ((xIm2In*finalS)/2);
        centY = (yIm1/2) - ((yIm2In*finalS)/2);
        HInit = [finalS, 0, centY;
                 0, finalS, centX;
                 0, 0, 1.000];
        tformTranslate = maketform('affine', (HInit)');
        T = affine2d(tformTranslate.tdata.T);
    end
    
    % 提取特征点
    [m1, ~, ~, ~, ~, ~, ~] = phasecong3(im2In);
    
    numCut = 6;
    stepX = xIm2In / numCut;
    stepY = yIm2In / numCut;
    
    % 在网格块中提取Harris角点
    for cX = 1:numCut
        for cY = 1:numCut
            if cX == 1
                pointLUX = 1;
            else
                pointLUX = (cX - 1) * stepX;
            end
            
            if cY == 1
                pointLUY = 1;
            else
                pointLUY = (cY - 1) * stepY;
            end
            
            m1Cut = m1(pointLUX:pointLUX+stepX-1, pointLUY:pointLUY+stepY-1);
            m1Cut = LACE_gray(m1Cut);
            m1Points = detectHarrisFeatures(m1Cut, "MinQuality", 0.09);
            m1Points = m1Points.selectStrongest(pointNum);
            m1Points(find(m1Points.Metric < 0.001)) = [];
            
            P = [m1Points.Location(:,1)+pointLUY-1, m1Points.Location(:,2)+pointLUX-1, ones(m1Points.Count, 1)];
            pointsIR = [pointsIR; P(:,1:2)];
            PP = (HInit) * P';
            PPP = PP';
            if cX == 1 && cY == 1
                points = PPP;
            else
                points = [points; PPP];
            end
        end
    end
    
    imRes = imwarp(im2In, T, 'OutputView', imref2d(size(im1)));
    
    % 可视化特征点
    figure('Name', '特征点可视化');
    imshow(im1In);
    hold on;
    scatter(points(:,1), points(:,2), 5, 'r', 'filled', 'MarkerEdgeAlpha', 0.7, 'MarkerFaceAlpha', 0.7);
    
    figure('Name', '红外图像上的特征点可视化');
    imshow(im2In);
    hold on;
    scatter(pointsIR(:,1), pointsIR(:,2), 5, 'r', 'filled', 'MarkerEdgeAlpha', 0.7, 'MarkerFaceAlpha', 0.7);
    
    disp(finalS);
    toc;
end

