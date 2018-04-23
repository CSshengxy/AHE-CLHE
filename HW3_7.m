clear all;
clc;

RGBImage = imread('testHE_n1.jpg');
GrayImage = ToGray(RGBImage);
oldHist = get_hist(GrayImage);
newGrayImage = AHE([4,4],GrayImage);
newHist = get_hist(newGrayImage);

figure(11);
subplot(1,2,1);
imshow(GrayImage);
title('原灰度图');
subplot(1,2,2);
imshow(newGrayImage);
title('自适应直方图均衡化灰度图');
figure(12);
subplot(1,2,1);
bar(0:255,oldHist);
axis([0 255 0 max(oldHist)]);
title('原灰度图hist');
subplot(1,2,2);
bar(0:255,newHist);
axis([0 255 0 max(newHist)]);
title('自适应直方图均衡化灰度图hist');
