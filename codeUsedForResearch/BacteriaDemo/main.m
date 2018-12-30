%% Code for biofilm data analysis

%%This code reads the raw data, separates channels, uses the function
%%'imbinarize' to binarize the images using a suitable threshold, and
%%compute the total volume of the bright pixels in the Alexa 488/GFP 
%%(bacteria) channel


%load image
clear; close all; clc;
filename = 'test_oib.oib';  %test.oib
data = bfopen(filename);
%% Metadata extraction
omeMeta = data{1,4};
XSize = omeMeta.getPixelsSizeX(0).getValue();%image width in pixels
YSize = omeMeta.getPixelsSizeY(0).getValue();%image height in pixels
stacksize = size(data{1,1},1);%number of Z slices
pxlSize = omeMeta.getPixelsPhysicalSizeX(0).value().doubleValue();%um
units = omeMeta.getPixelsPhysicalSizeX(0).unit().getSymbol(); 
zStep = data{1,2}.get('Global [Axis 3 Parameters Common] Interval');
zStep = str2double(zStep)/1000;%zStep size
%% Channel Segragation for 2 channels
ch1 = 1:2:stacksize;
ch1size = size(ch1,2);
ch2 = 2:2:stacksize;

ch2size = size(ch2,2);
for i = 1:ch1size
    I_ch1(:,:,i) = data{1,1}{ch1(i),1};
end
for i = 1:ch2size
    I_ch2(:,:,i) = data{1,1}{ch2(i),1};
end
%% 2D Stack display
figure; imshow3D(I_ch1);
figure; imshow3D(I_ch2);
%% Compute suitable threshold for binarizing image stack

A = I_ch1; % A is the image channel that contains the GFP bacteria
A = double(A);
[l m n] = size(A);
A_thr = zeros(n,1);
A_bn = zeros(size(A));
threshold_std = 2.2; %Insert optimal factor

for i = 1:n
    A_thr(i,1)= threshold(A(:,:,i),threshold_std);
end

f_thr = max(A_thr);

for i = 1:n
    A_bn(:,:,i)= binarize(A(:,:,i),f_thr);
end
figure; imshow3D(A_bn);


%% Finding the area and volume occupied by live bacteria

PixelVolume = 0;

for i = 1:n        
    area(i) = sum(sum(A_bn(:,:,i)))*pxlSize*pxlSize;
    PixelVolume = PixelVolume + area(i);
end

Volume = PixelVolume*pxlSize*pxlSize*zStep; %Volume in um^3
