function m1_points = extractSIFTFeatures(input_img)
    % Function: Extract SIFT features and descriptors
    if size(input_img, 3) == 3
        input_img = rgb2gray(input_img);
    end
    input_img = im2double(input_img);

    % Build DoG Pyramid
    global gauss_pyr;
    global dog_pyr;
    global init_sigma;
    global octvs;
    global intvls;
    global ddata_array;

    init_sigma = 1.6;
    intvls = 3;
    s = intvls;
    k = 2^(1/s);
    sigma = ones(1, s + 3);
    sigma(1) = init_sigma;
    sigma(2) = init_sigma * sqrt(k*k - 1);
    for i = 3:s + 3
        sigma(i) = sigma(i - 1) * k;
    end

    input_img = imresize(input_img, 2);
    input_img = gaussian(input_img, sqrt(init_sigma^2 - 0.5^2 * 4));
    octvs = floor(log(min(size(input_img))) / log(2) - 2);

    [img_height, img_width] = size(input_img);
    gauss_pyr = cell(octvs, 1);
    gimg_size = zeros(octvs, 2);
    gimg_size(1, :) = [img_height, img_width];

    for i = 1:octvs
        if i ~= 1
            gimg_size(i, :) = [round(size(gauss_pyr{i - 1}, 1) / 2), round(size(gauss_pyr{i - 1}, 2) / 2)];
        end
        gauss_pyr{i} = zeros(gimg_size(i, 1), gimg_size(i, 2), s + 3);
    end

    for i = 1:octvs
        for j = 1:s + 3
            if i == 1 && j == 1
                gauss_pyr{i}(:, :, j) = input_img;
            elseif j == 1
                gauss_pyr{i}(:, :, j) = imresize(gauss_pyr{i - 1}(:, :, s + 1), 0.5);
            else
                gauss_pyr{i}(:, :, j) = gaussian(gauss_pyr{i}(:, :, j - 1), sigma(j));
            end
        end
    end

    % Build DoG pyramid
    dog_pyr = cell(octvs, 1);
    for i = 1:octvs
        dog_pyr{i} = zeros(gimg_size(i, 1), gimg_size(i, 2), s + 2);
        for j = 1:s + 2
            dog_pyr{i}(:, :, j) = gauss_pyr{i}(:, :, j + 1) - gauss_pyr{i}(:, :, j);
        end
    end

    % Keypoint localization and orientation assignment
    img_border = 5;
    max_interp_steps = 5;
    contr_thr = 0.04;
    curv_thr = 10;
    prelim_contr_thr = 0.5 * contr_thr / intvls;
    ddata_array = struct('x', 0, 'y', 0, 'octv', 0, 'intvl', 0, 'x_hat', [0, 0, 0], 'scl_octv', 0);
    ddata_index = 1;

    for i = 1:octvs
        [height, width] = size(dog_pyr{i}(:, :, 1));
        for j = 2:s + 1
            dog_imgs = dog_pyr{i};
            dog_img = dog_imgs(:, :, j);
            for x = img_border + 1:height - img_border
                for y = img_border + 1:width - img_border
                    if abs(dog_img(x, y)) > prelim_contr_thr
                        if isExtremum(j, x, y, dog_imgs)
                            ddata = interpLocation(dog_imgs, height, width, i, j, x, y, img_border, contr_thr, max_interp_steps);
                            if ~isempty(ddata)
                                if ~isEdgeLike(dog_img, ddata.x, ddata.y, curv_thr)
                                    ddata_array(ddata_index) = ddata;
                                    ddata_index = ddata_index + 1;
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    % Orientation assignment and descriptor generation
    % Your existing orientation assignment and descriptor generation code

    % Final output preparation
    n = size(ddata_array, 2);
    locs = zeros(n, 2);
    descrs = zeros(n, 128); % Assuming descriptor length is 128

    for i = 1:n
        locs(i, 1) = ddata_array(i).x;
        locs(i, 2) = ddata_array(i).y;
        % Fill descrs(i, :) with the computed descriptor for this feature
        % descrs(i, :) = ...; % Your descriptor generation code here
    end
    m1_points = struct('Location', num2cell(locs, 2), 'Descriptor', num2cell(descrs, 2));
end

function [flag] = isExtremum(intvl, x, y, dog_imgs)
    % Function: Find Extrema in 26 neighboring pixels
    value = dog_imgs(x, y, intvl);
    block = dog_imgs(x-1:x+1, y-1:y+1, intvl-1:intvl+1);
    if value > 0 && value == max(block(:))
        flag = 1;
    elseif value == min(block(:))
        flag = 1;
    else
        flag = 0;
    end
end
