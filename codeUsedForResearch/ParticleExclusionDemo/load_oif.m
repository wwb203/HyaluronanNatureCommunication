%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%load image
filename = 'Image0031.oif';
data = bfopen(filename);
Ig = data{1,1}{1,1};
Ig = im2double(Ig);
Ir = data{1,1}{2,1};
Ir = im2double(Ir);
omeMeta = data{1,4};
pxlSize = omeMeta.getPixelsPhysicalSizeX(0).getValue();%um
imgSize = omeMeta.getPixelsSizeX(0).getValue();%pixel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%process BSA channel
levelG = graythresh(Ig);
GBW = im2bw(Ig,levelG);
GBW = 1 - GBW;
GBW = imfill(GBW,'holes');
GBW = bwareaopen(GBW,20);
props = regionprops(GBW,'Centroid');
centroid = props.Centroid;
radius = sqrt(bwarea(GBW)/pi);
overlay1 = imoverlay(imadjust(Ig),GBW,[.3 1 .3]);
figure(1)
hold on
imagesc(Ig)
viscircles(centroid,radius);
axis equal
hold off
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%process particles channel
%estimate exclusion radius
levelR = graythresh(Ir);
RBW = im2bw(Ir,levelR);
RBWC =1 - imclose(RBW,strel('disk',20));
figure(3)
overlay2 = imoverlay(imadjust(Ir),bwperim(RBWC),[.3 1 .3]);
imshow(overlay2)
rEstimate = sqrt(bwarea(RBWC)/pi)+80;
rEstimate = min([rEstimate,abs(centroid(1)-imgSize),...
                 abs(centroid(2)-imgSize),centroid(1),centroid(2)]);
rEstimate = floor(rEstimate);
% Create the meshgrid to be used in resampling
[X,Y] = meshgrid(1:imgSize,1:imgSize);
R_r = 10:rEstimate;
radial_average_G = zeros(length(R_r),1);
radial_average_R = zeros(length(R_r),1);
parfor i=1:length(R_r)
    R = R_r(i);
    num_pxls = 2*pi*R;
    theta = 0:1/num_pxls:2*pi;
    x = centroid(1) + R*cos(theta);
    y = centroid(2) + R*sin(theta);
    sampleG = interp2(X,Y,Ig,x,y);
    radial_average_G(i) = mean(sampleG);
    sampleR = interp2(X,Y,Ir,x,y);
    radial_average_R(i) = mean(sampleR);
end
radial_average_G = radial_average_G-radial_average_G(1);
radial_average_R = radial_average_R-radial_average_R(1);
radial_average_G = radial_average_G/mean(radial_average_G(end-5:end));
radial_average_R = radial_average_R/mean(radial_average_R(end-5:end));
figure(6)
plot(R_r,radial_average_G,'g-',R_r,radial_average_R,'r*')
return
figure(2)
imagesc(Ir)
axis equal
return
GBW = bwareaopen(GBW,30);
GBW = imclose(GBW,strel('disk',5));
GBW = imfill(GBW,'holes');
props = regionprops(GBW,'Centroid','Perimeter');
centroid = round(props.Centroid);
GBWB = bwperim(GBW);
overlay1 = imoverlay(imadjust(G0),GBWB,[.3 1 .3]);
figure(1)
imshow(overlay1)
hold on;
plot(contour(:,2),contour(:,1),'g','LineWidth',2);
axis equal

