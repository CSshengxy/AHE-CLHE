function clipHist = CLHE(clipLimit,Image)
    % input Image should be a gray image and the clipLimit can't be too
    % small
    [rows,cols,channels] = size(Image);
    if channels~=1
        error('ERROR: the Image should be a gray image!');
    end
    clipLimit = ceil(clipLimit * rows * cols);
    % compute the frequency of the image
    hist = get_hist(Image);
    % total number of pixels overflowing clip limit in each bin 
    totalExcess = sum(max(hist - clipLimit,0)); 
    averageIncrease = floor(totalExcess / 256);
    upperLimit = clipLimit - averageIncrease;
    
    %%裁剪原则
    %frequency高于clipLimit，直接置为clipLimit
    %frequency处于clipLimit和upperLimit之间，填补至clipLimit
    %frequency低于upperLimit,增加averageIncrease大小
    %剩余的frequency分给值仍然小于clipLimit的像素
    clipHist = hist;
    for i = 1:256
        if hist(i) > clipLimit
            clipHist(i) = clipLimit;
        else
            if hist(i) > upperLimit
                clipHist(i) = clipLimit;
                totalExcess = totalExcess - (hist(i)-upperLimit);
            else
                clipHist(i) = hist(i) + averageIncrease;
                totalExcess = totalExcess - averageIncrease;
            end
        end
    end
    % redistribute the remaining pixels
    while(totalExcess ~= 0)
        startIndex = 1 + floor(255 * rand());
        for i = startIndex:256
            if clipHist(i) < clipLimit
                clipHist(i) = clipHist(i) + 1;
            end
            totalExcess = totalExcess - 1;
            if (totalExcess == 0)
                break;
            end
        end
    end
            
    

    