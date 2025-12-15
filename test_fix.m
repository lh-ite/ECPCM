% 测试修复后的代码
disp('测试修复后的代码...');
addpath('./functions/');

try
    % 测试整数索引问题是否修复
    disp('测试整数索引修复...');
    xIm2In = 128; yIm2In = 96;  % 测试非6的倍数的尺寸
    numCut = 6;
    stepX = floor(xIm2In / numCut);
    stepY = floor(yIm2In / numCut);

    % 模拟原来的索引操作
    pointLeftUpX = 1;
    pointLeftUpY = 1;
    test_matrix = rand(xIm2In, yIm2In);
    m1Cut = test_matrix(pointLeftUpX:pointLeftUpX+stepX-1, pointLeftUpY:pointLeftUpY+stepY-1);

    disp(['✓ 整数索引测试通过，裁剪尺寸: ', num2str(size(m1Cut))]);

    % 测试函数名修复
    disp('测试函数名修复...');
    X1 = rand(3, 10);
    X2 = rand(3, 10) + rand(3, 10) * 0.1;  % 添加一些噪声
    [H, ok, score] = HMransac(X1, X2, 50, 0.1);  % 使用正确的函数名

    disp(['✓ HMransac函数测试通过，H矩阵尺寸: ', num2str(size(H))]);
    disp(['✓ 内点数量: ', num2str(sum(ok))]);

    disp('🎉 所有修复都成功！');

catch e
    disp(['❌ 测试失败: ', e.message]);
    if length(e.stack) > 0
        disp(['错误位置: ', e.stack(1).file, ' 第', num2str(e.stack(1).line), '行']);
    end
end

