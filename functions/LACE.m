function result=LACE(img)

    img1=(img);
    cform=makecform('srgb2lab');
    lab1=applycform(img1,cform);


    lab2=lab1;
    lab2(:,:,1)=LLCE(lab2(:,:,1),25);
    Mean2=mean(mean(lab2(:,:,2)));
    Mean3=mean(mean(lab2(:,:,3)));

    if Mean2>Mean3
        lab2(:,:,3)=lab2(:,:,3)+(Mean2-Mean3)/((Mean2+Mean3))*lab2(:,:,2);
    else
        lab2(:,:,2)=lab2(:,:,2)+(Mean3-Mean2)/((Mean2+Mean3))*lab2(:,:,3);
    end

    cform=makecform('lab2srgb');
    img2=applycform(lab2,cform);
    result=img2;
end



