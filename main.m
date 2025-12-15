% 光学-红外图像配准主程序
% 基于OLE (Optical-Infrared) 配准算法实现图像自动配准

clc;
clear all;
close all;
tic;

% 添加函数路径
addpath('./functions/');
addpath('./data/');

% 参数设置
pointNum = 100;  % 特征点数量
batchSize = 80;  % 批处理窗口大小
imNum = 4;       % 测试图像对编号

% 读取测试图像
im1 = imread(['./data/vis', num2str(imNum), '_v2.jpg']);  % 可见光图像
im2 = imread(['./data/ir', num2str(imNum), '.jpg']);      % 红外图像

% 备份原始图像
im1In = im1;
im2In = im2;
im1Gray = im2gray(im1);
% 粗配准阶段
fprintf('开始粗配准...\n');
[im2, PPP, H_init] = coarseRegistrationSSIMRMSE(im1, im2, pointNum);
im2Gray = im2gray(im2);

% 可视化粗配准结果
figure('Name', '粗配准结果');
imshow(im2);
hold on;
plot(PPP(:,1), PPP(:,2), '.r', 'MarkerSize', 10);
title('红外图像上的特征点');

% 准备精配准的特征点
pointRefine = [PPP(:,2), PPP(:,1)];
% 精配准阶段
fprintf('开始精配准...\n');
[cleanedPoints1, cleanedPoints2] = fineRegistrationCFOG(im1Gray, im2Gray, batchSize, pointRefine);
%% Image transformation
% tic,[I1_r,I2_r,I1_rs,I2_rs,I3,I4,t_form,~] = Transformation(im1,im2,...
%     cleanedPoints1,cleanedPoints2,trans_form,out_form,1,Is_flag,I3_flag,I4_flag);
%     t(6)=toc; fprintf(['已完成图像变换，用时 ',num2str(t(6)),'s\n']);
%               fprintf([' Done image transformation，time: ',num2str(t(6)),'s\n\n']);
%     figure,imshow(I3),title('Overlap Form'); drawnow
%     figure,imshow(I4),title('Mosaic Form'); drawnow

% TPS变换和图像融合
fprintf('开始TPS变换和图像融合...\n');

% 准备匹配点数据
im1 = im1In;
im2 = im2In;
X1 = cleanedPoints1';
X2 = cleanedPoints2';
X1 = [X1; ones(1, size(X1, 2))];
X2 = [X2; ones(1, size(X2, 2))];

% 可视化匹配结果
figure('Name', '特征点匹配结果');
showMatchedFeatures(im1, im2, (X1(1:2,:))', (X2(1:2,:))', 'montage');
title('特征点匹配结果');

% 应用粗配准变换
X2 = (inv(H_init)) * X2;

% 执行TPS变换
[mosaicImg, regImg, u_, v_] = TPStransformation(im1, im2, X1, X2);

% 显示结果
figure('Name', '配准结果');
imshow(mosaicImg);
title('最终配准结果');

% 输出运行时间
time = toc;
fprintf('总运行时间: %.2f 秒\n', time);


fprintf('配准完成！\n');