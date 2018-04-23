function newPixelVal = pixel_map(hist,dimImage)
    frequency = hist/(dimImage(1)*dimImage(2));
    accumulation = zeros(1,256);
    accumulation(1,1)=frequency(1,1);
    for i = 2:256
        accumulation(1,i) = accumulation(1,i-1) + frequency(1,i);
    end
    
    newPixelVal = floor(accumulation * 255);
    
    