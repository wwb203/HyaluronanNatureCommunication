I = imread('SEM_slide.tif');
height = 1455;
width = 2048;
Icrop = imcrop(I,[0,0,width,height]);
img = im2double(Icrop);
img60 = imgaussfilt(img,40);
img5 = imgaussfilt(img,5);
img = img5./img60;
imgstd = stdfilt(img,ones(9,9));
[~, threshold] = edge(img, 'sobel');
fudgeFactor = .5;
BWs = edge(img,'sobel', threshold * fudgeFactor);
figure;imshow(BWs)
se90 = strel('line', 5, 90);
se0 = strel('line', 5, 0);
BWs = imdilate(BWs, [se90 se0]);
%figure;imshow(BWs);
Icrop = wiener2(Icrop,[3 3]);
T = adaptthresh(Icrop, 0.59);
bw =  imbinarize(Icrop,T);
bw = bwareaopen(bw, 10);
bw = imreconstruct(BWs, bw);

bw = imclose(bw, strel('disk',3));
bw = imfill(bw,'holes');
bwarea(bw)/width/height
figure;imshow(bw);
bw = bwperim(bw);
bw = imdilate(bw,strel('square',2));
bw2 = zeros(size(I));
bw2(1:height,1:1024) = bw(:,1:1024);
Ioverlap = imoverlay(I,bw2,[1,0,0]);
figure;imshow(Ioverlap);