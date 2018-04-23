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
    
    %%�ü�ԭ��
    %frequency����clipLimit��ֱ����ΪclipLimit
    %frequency����clipLimit��upperLimit֮�䣬���clipLimit
    %frequency����upperLimit,����averageIncrease��С
    %ʣ���frequency�ָ�ֵ��ȻС��clipLimit������
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
            
    

    