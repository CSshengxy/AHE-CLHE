function hist = get_hist(GrayImage)
    [rows,cols] = size(GrayImage);
    hist = zeros(1,256);
    for i = 1:rows
        for j = 1:cols
            hist(GrayImage(i,j)+1) = hist(GrayImage(i,j)+1) + 1;
        end
    end