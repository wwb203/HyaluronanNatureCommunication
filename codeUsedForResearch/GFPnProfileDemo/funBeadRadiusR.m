function [radiusR,centroid,radial_average_R,p]=funBeadRadiusR(Ic,centroid,imgSize,pxlSize,idSlice,baseline,debug)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%filename = './active/Image0115.oif';
%filename = './overnight/Image0028.oif';
%debug = true;
%data = bfopen(filename);
% Ig = data{1,1}{idSlice*2-1,1};
% Ig = im2double(Ig);
% Ir = data{1,1}{idSlice*2,1};
% Ir = im2double(Ir);
%omeMeta = data{1,4};
% = omeMeta.getPixelsPhysicalSizeX(0).getValue();%um
%imgSize = omeMeta.getPixelsSizeX(0).getValue();%pixel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%process BSA channel
% BMask = ones(imgSize,imgSize);
% Bwidth = floor(0.1*imgSize);
% BMask(Bwidth:(imgSize-Bwidth),Bwidth:(imgSize-Bwidth))=0;
% BWlevel = mean(Ig(BMask==1))*3;
% H = fspecial('gaussian', 10, 10);
% Igb = imfilter(Ig,H,'replicate');
% GBW = im2bw(Igb,BWlevel);
% GBW = imclose(GBW,strel('disk',10));
% GBW = bwareaopen(GBW,20);%remove noise
% GBW = imfill(GBW,'holes');
% GBW = imclearborder(GBW);
% GBW = bwareaopen(GBW,floor(bwarea(GBW)/2));
% props = regionprops(GBW,'Centroid','area');%get centroid
% if length(props)>1
%     area = zeros(length(props),1);
%     for i=1:length(props)
%         area(i) = props(i).Area;
%     end
%     centroid = props(find(area==max(area))).Centroid;
% else
%     centroid = props.Centroid;
% end
% 
% radius = sqrt(bwarea(GBW)/pi);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%process particles channel
levelR = graythresh(Ic);
%BMask = ones(imgSize,imgSize);
%Bwidth = floor(0.1*imgSize);
%BMask(Bwidth:(imgSize-Bwidth),Bwidth:(imgSize-Bwidth))=0;
%BWlevel = mean(Ir(BMask==1));
RBW = im2bw(Ic,levelR);
RBWC =1 - imclose(RBW,strel('disk',20));
BWforeground = RBWC;
RBWC = imclearborder(RBWC);
if centroid(1)<1
props = regionprops(RBWC,'Centroid','area');%get centroid
centroid = props.Centroid;
end
BG = 1 - imdilate(BWforeground,strel('disk',30));
BGlevel = Ic(BG==1);
BGlevel = trimmean(BGlevel(:),15);
%radiusRBW = sqrt(bwarea(RBWC)/pi);
if debug
    overlay1 = imoverlay(imadjust(Ic),bwperim(RBWC),[.3 1 .3]);
    figure(1000+idSlice*2)
    hold on
    imshow(overlay1)
    viscircles(centroid,3);
    axis equal
    hold off
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%estimate exclusion radius
rEstimate = sqrt(bwarea(RBWC)/pi)+60;
rEstimate = min([rEstimate,abs(centroid(1)-imgSize),...
    abs(centroid(2)-imgSize),centroid(1),centroid(2)]);
rEstimate = floor(rEstimate)-5;
% Create the meshgrid to be used in resampling
[X,Y] = meshgrid(1:imgSize,1:imgSize);
R_r = 10:rEstimate;
radial_average_R = zeros(length(R_r),1);
%resample radially
parfor i=1:length(R_r)
    R = R_r(i);
    num_pxls = 2*pi*R;
    theta = 0:1/num_pxls:2*pi;
    x = centroid(1) + R*cos(theta);
    y = centroid(2) + R*sin(theta);
   sampleR = interp2(X,Y,Ic,x,y);
   radial_average_R(i) = mean(sampleR);
end
%normalize
%radial_average_R = radial_average_R/BGlevel;
radial_average_R = radial_average_R-radial_average_R(1);
radial_average_R = radial_average_R/BGlevel;
%find midpoint
%baseline = 0.35;
array = abs(radial_average_R-baseline);
id = find(array==min(array));
if id<5||(id+4)>length(array)
    radiusR = NaN;
    centroid = NaN;
    radial_average_R = NaN;
    p = NaN;
    figure(6+idSlice*2)
    plot(R_r,radial_average_R,'r-');
    return
end
x = R_r(id-4:id+4)';
y = radial_average_R(id-4:id+4)-baseline;
p = polyfit(x,y,1);
radiusR = -p(2)/p(1);
radiusR = radiusR*pxlSize;


if debug
    figure(6+idSlice*2)
    plot(R_r,radial_average_R,'r-');
end