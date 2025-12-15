% OLE图像配准主程序
% 功能：实现可见光与红外图像的配准
% 作者：根据OLE_registration.pdf整理
% 日期：2024

clc;
clear all;
close all;
tic;
warning off
% 添加函数路径
addpath('./Functions/');   % 核心函数库
addpath('./data/'); 
addpath('./functions/');   % phasecong3.m和lowpassfilter.m在functions文件夹中

% ========== 参数设置 ==========
pointNum = 100;          % 每个网格块提取的特征点数量
batchSize = 80;          % 精配准匹配窗口大小
imNum = 1;              % 图像编号

% ========== 图像读取 ==========
im1 = imread(['./data/vis', num2str(imNum), '_v2.jpg']);  % 可见光图像
im2 = imread(['./data/ir', num2str(imNum), '.jpg']);      % 红外图像

im1In = im1;
im2In = im2;
im1Gray = im2gray(im1);

% ========== 粗配准 ==========
fprintf('开始粗配准...\n');
figure(1);
imshow(im2);
title('红外图像');
[im2, points, HInit] = coarseRegistration(im1, im2, pointNum);
im2Gray = im2gray(im2);

hold on;
plot(points(:,1), points(:,2), '.r');
pointRefine = [points(:,2), points(:,1)];

% ========== 精配准 ==========
fprintf('开始精配准...\n');
[cleanedPoints1, cleanedPoints2] = fineRegistration(im1Gray, im2Gray, batchSize, pointRefine);

% ========== 图像变换 ==========
fprintf('开始TPS变换...\n');
im2Re = im2;
im1 = im1In;
im2 = im2In;
X1 = cleanedPoints1';
X2 = cleanedPoints2';
X1 = [X1; ones(1, size(X1, 2))];
X2 = [X2; ones(1, size(X2, 2))];

figure;
showMatchedFeatures(im1In, im2Re, (X1(1:2,:))', (X2(1:2,:))', 'montage');
title('匹配点可视化');

X2 = (inv(HInit)) * X2;
figure;
showMatchedFeatures(im1In, im2, (X1(1:2,:))', (X2(1:2,:))', 'montage');
title('逆变换后的匹配点');

[mosaicImg, regImg, u_, v_] = TPS_trans(im1, im2, X1, X2);
figure;
imshow(mosaicImg);
title('拼接结果');

time = toc;
fprintf('总耗时: %.2f 秒\n', time);

% ========== 客观评价 ==========
if exist('c_points.mat', 'file')
    load c_points.mat;
    eval(['IR_ = round(IR_', num2str(imNum), ');']);
    eval(['VIS_ = round(VIS_', num2str(imNum), ');']);
    kIn5 = 0;
    kIn10 = 0;
    for i = 1:50
        preX = u_(VIS_(i,2), VIS_(i,1));
        preY = v_(VIS_(i,2), VIS_(i,1));
        distance(i) = sqrt((IR_(i,1) - preX)^2 + (IR_(i,2) - preY)^2);
        disSum(i) = (IR_(i,1) - preX)^2 + (IR_(i,2) - preY)^2;
        if distance(i) < 10
            kIn10 = kIn10 + 1;
            if distance(i) < 5
                kIn5 = kIn5 + 1;
            end
        end
    end
    meanDis = mean(distance(:));
    maxDis = max(distance(:));
    rmse = sqrt(mean(disSum(:)));
    fprintf('RMSE: %.2f 像素\n', rmse);
    fprintf('平均误差: %.2f 像素\n', meanDis);
    fprintf('最大误差: %.2f 像素\n', maxDis);
    fprintf('5像素内点数: %d\n', kIn5);
    fprintf('10像素内点数: %d\n', kIn10);
end

