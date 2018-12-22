function [thickness,radiusG]=coatThickness(filename,debug)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%filename = './active/Image0115.oif';
%filename = './overnight/Image0028.oif';
%debug = true;
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
GBW = 1 - GBW;%flip image intensity so that bead area is bright
GBW = imfill(GBW,'holes');
GBW = bwareaopen(GBW,20);%remove noise
GBW = imclearborder(GBW);
props = regionprops(GBW,'Centroid');%get centroid
centroid = props.Centroid;
radius = sqrt(bwarea(GBW)/pi);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%show intermediate result
if debug
    overlay1 = imoverlay(imadjust(Ig),GBW,[.3 1 .3]);
    figure(1)
    hold on
    imagesc(Ig)
    viscircles(centroid,radius);
    axis equal
    hold off
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%process particles channel
levelR = graythresh(Ir);
RBW = im2bw(Ir,levelR);
RBWC =1 - imclose(RBW,strel('disk',20));
RBWC = imclearborder(RBWC);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%show intermediate result
if debug
    figure(3)
    overlay2 = imoverlay(imadjust(Ir),bwperim(RBWC),[.3 1 .3]);
    imshow(overlay2)
end
%estimate exclusion radius
rEstimate = sqrt(bwarea(RBWC)/pi)+80;
rEstimate = min([rEstimate,abs(centroid(1)-imgSize),...
    abs(centroid(2)-imgSize),centroid(1),centroid(2)]);
rEstimate = floor(rEstimate)-5;
% Create the meshgrid to be used in resampling
[X,Y] = meshgrid(1:imgSize,1:imgSize);
R_r = 10:rEstimate;
radial_average_G = zeros(length(R_r),1);
radial_average_R = zeros(length(R_r),1);
%resample radially
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
%normalize
radial_average_G = radial_average_G-radial_average_G(1);
radial_average_G = radial_average_G/mean(radial_average_G(end-8:end));
radial_average_R = radial_average_R-radial_average_R(1);
radial_average_R = radial_average_R/mean(radial_average_R(end-8:end));
%find midpoint
baseline = 0.5;
array = abs(radial_average_G-baseline);
id = find(array==min(array));
x = R_r(id-2:id+2)';
y = radial_average_G(id-2:id+2)-baseline;
p = polyfit(x,y,1);
radiusG = -p(2)/p(1);
array = abs(radial_average_R-baseline);
id = find(array==min(array));
x = R_r(id-2:id+2)';
y = radial_average_R(id-2:id+2)-baseline;
p = polyfit(x,y,1);
radiusR = -p(2)/p(1);
thickness = radiusR - radiusG;
thickness = thickness*pxlSize;
radiusG = radiusG*pxlSize;
if debug
    figure(6)
 %   hold on
    plot(R_r,radial_average_G,'g-',R_r,radial_average_R,'r-')
%     R_r = R_r(1:end-1);
%     D_radial_average_G=diff(radial_average_G);
%     D_radial_average_R=diff(radial_average_R);
%     plot(R_r,D_radial_average_G,'g*',R_r,D_radial_average_R,'r*')
end
if debug
    'green radius difference'
    dR = radiusG-radius*pxlSize
end

