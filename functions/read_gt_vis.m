function VIS_=read_gt_vis(im_num)
    load c_points.mat;
    temp = [];
    eval(['temp = round(VIS_',num2str(im_num),')']);
    VIS_ = temp;
end