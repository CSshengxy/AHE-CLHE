function GrayImage=ToGray(RGBImage)
    [rows,cols,channels] = size(RGBImage);
    if channels == 1
        GrayImage = RGBImage;
        return;
    end
    RGBImage = double(RGBImage);
    GrayImage = uint8(zeros(rows,cols));
    for i = 1:rows
        for j = 1:cols
            GrayImage(i,j)=round(RGBImage(i,j,1)*0.2989+RGBImage(i,j,2)*0.5870+RGBImage(i,j,3)*0.1140);
        end
    end
    GrayImage = uint8(GrayImage);