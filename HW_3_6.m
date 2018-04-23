clear all;
clc;

RGBImage = imread('testHE_n1.jpg');
GrayImage = ToGray(RGBImage);
[rows,cols] = size(GrayImage);
oldHist = get_hist(GrayImage);
pixelMap = pixel_map(oldHist,size(GrayImage));
newGrayImage = uint8(zeros(rows,cols));
for i=1:rows
    for j=1:cols
        newGrayImage(i,j) = pixelMap(GrayImage(i,j)+1);
    end
end
newHist = get_hist(newGrayImage);
figure(11);
subplot(1,2,1);
imshow(GrayImage);
title('原灰度图');
subplot(1,2,2);
imshow(newGrayImage);
title('直方图均衡化灰度图');
figure(12);
subplot(1,2,1);
bar(0:255,oldHist);
axis([0 255 0 max(oldHist)]);
title('原灰度图hist');
subplot(1,2,2);
bar(0:255,newHist);
axis([0 255 0 max(newHist)]);
title('直方图均衡化灰度图hist');


% CLHE
clip = 0.0001;
clipHist = CLHE(clip,newGrayImage);
CLHEPixelMap = pixel_map(clipHist,size(newGrayImage));
CLHEGrayImage = uint8(zeros(rows,cols));
for i=1:rows
    for j=1:cols
        CLHEGrayImage(i,j) = CLHEPixelMap(newGrayImage(i,j)+1);
    end
end
figure(21);
subplot(1,2,1);
imshow(newGrayImage);
title('原灰度图');
subplot(1,2,2);
imshow(CLHEGrayImage);
title('对比度限制直方图均衡化灰度图');
figure(22);
subplot(1,2,1);
bar(0:255,newHist);
axis([0 255 0 max(max(newHist),clip*cols*rows+100)]);
hold on
plot([0,255],[clip*cols*rows clip*cols*rows],'r')
title('原灰度图hist');
subplot(1,2,2);
bar(0:255,clipHist);
axis([0 255 0 max(max(clipHist),clip*cols*rows+100)]);
hold on
plot([0,255],[clip*cols*rows clip*cols*rows],'r')
title('对比度限制直方图均衡化灰度图hist');
