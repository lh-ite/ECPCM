function enhanced = LACE_gray(img)
    % 确保输入是灰度图
    if size(img,3) > 1
        img = rgb2gray(img);
    end
    
    % 直接应用LLCE增强
    enhanced = LLCE(double(img), 5);
    
    % 归一化输出
    % result = uint8(enhanced);
end