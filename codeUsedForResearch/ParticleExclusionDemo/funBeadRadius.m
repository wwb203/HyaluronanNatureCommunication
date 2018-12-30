function [radiusG,radiusG_width,radial_average_G]=funBeadRadius(Ig,imgSize,pxlSize,idSlice,debug)
%process dextran channel
BMask = ones(imgSize,imgSize);
Bwidth = floor(0.1*imgSize);
BMask(Bwidth:(imgSize-Bwidth),Bwidth:(imgSize-Bwidth))=0;
BWlevel = mean(Ig(BMask==1))*3;
H = fspecial('gaussian', 10, 10);
Igb = imfilter(Ig,H,'replicate');
GBW = im2bw(Igb,BWlevel);
GBW = imclose(GBW,strel('disk',10));
GBW = bwareaopen(GBW,20);%remove noise
GBW = imfill(GBW,'holes');
GBW = imclearborder(GBW);
GBW = bwareaopen(GBW,floor(bwarea(GBW)/2));
props = regionprops(GBW,'Centroid','area');%get centroid
if isempty(props)
    radiusG = 0;
    radiusG_width = 0;
    return
end
if length(props)>1
    area = zeros(length(props),1);
    for i=1:length(props)
        area(i) = props(i).Area;
    end
    centroid = props(find(area==max(area))).Centroid;
else
    centroid = props.Centroid;
end
radius = sqrt(bwarea(GBW)/pi);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%estimate exclusion radius
rEstimate = sqrt(bwarea(GBW)/pi)+50;
rEstimate = min([rEstimate,abs(centroid(1)-imgSize),...
    abs(centroid(2)-imgSize),centroid(1),centroid(2)]);
rEstimate = floor(rEstimate)-5;
% Create the meshgrid to be used in resampling
[X,Y] = meshgrid(1:imgSize,1:imgSize);
R_r = 10:rEstimate;
radial_average_G = zeros(length(R_r),1);
%resample radially
parfor i=1:length(R_r)
    R = R_r(i);
    num_pxls = 2*pi*R;
    theta = 0:1/num_pxls:2*pi;
    x = centroid(1) + R*cos(theta);
    y = centroid(2) + R*sin(theta);
    sampleG = interp2(X,Y,Ig,x,y);
    radial_average_G(i) = mean(sampleG);
end
radial_peak_G = max(radial_average_G);
radiusG = R_r(find(radial_average_G==radial_peak_G));
radiusG_width = range(find(radial_average_G>(0.8*radial_peak_G)));
if debug
    figure(6+idSlice*2+100)
    plot(R_r*pxlSize,radial_average_G,'g-');
    xlabel('radial distance \mum')
    ylabel('radial average intensity')
end
radiusG = radiusG*pxlSize;
radiusG_width =radiusG_width*pxlSize;
if debug
    overlay1 = imoverlay(imadjust(Ig),bwperim(GBW),[.3 1 .3]);
    figure(1+idSlice*2)
    hold on
    imshow(overlay1)
    viscircles(centroid,radiusG/pxlSize);
    axis equal
    hold off
    radiusG = sqrt(bwarea(GBW)/pi);
    'green radius difference(um)'
    dR = radiusG-radius*pxlSize
end
