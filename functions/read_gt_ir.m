function IR_=read_gt_ir(im_num)
    load c_points.mat;
    temp = [];
    eval(['temp = round(IR_',num2str(im_num),')']);
    IR_ = temp;
end