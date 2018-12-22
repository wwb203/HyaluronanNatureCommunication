function [radiusG,radiusG_width,radial_average_G]=funBeadRadius(Ig,imgSize,pxlSize,idSlice,debug)

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
%levelG = graythresh(Ig);
BMask = ones(imgSize,imgSize);
Bwidth = floor(0.1*imgSize);
BMask(Bwidth:(imgSize-Bwidth),Bwidth:(imgSize-Bwidth))=0;
BWlevel = mean(Ig(BMask==1))*3;
%BWlevel = graythresh(Ig);
H = fspecial('gaussian', 10, 10);
Igb = imfilter(Ig,H,'replicate');
GBW = im2bw(Igb,BWlevel);
%GBW = 1 - GBW;%flip image intensity so that bead area is bright
%GBW = imfill(GBW,'holes');
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
%show intermediate result
if debug

end
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
%radial_average_R = zeros(length(R_r),1);
%resample radially
parfor i=1:length(R_r)
    R = R_r(i);
    num_pxls = 2*pi*R;
    theta = 0:1/num_pxls:2*pi;
    x = centroid(1) + R*cos(theta);
    y = centroid(2) + R*sin(theta);
    sampleG = interp2(X,Y,Ig,x,y);
    radial_average_G(i) = mean(sampleG);
%    sampleR = interp2(X,Y,Ir,x,y);
%    radial_average_R(i) = mean(sampleR);
end
%normalize
%radial_average_G = radial_average_G-radial_average_G(1);
%radial_average_G = radial_average_G/mean(radial_average_G(end-8:end));
%radial_average_R = radial_average_R-radial_average_R(1);
%radial_average_R = radial_average_R/mean(radial_average_R(end-8:end));
%find midpoint
% baseline = 0.25;
% array = abs(radial_average_G-baseline);
% id = find(array==min(array));
% x = R_r(id-2:id+2)';
% y = radial_average_G(id-2:id+2)-baseline;
% p = polyfit(x,y,1);
radial_peak_G = max(radial_average_G);
radiusG = R_r(find(radial_average_G==radial_peak_G));
radiusG_width = range(find(radial_average_G>(0.8*radial_peak_G)));
% R_r = floor(radiusG-radiusG_width):floor(radiusG+radiusG_width);
% dX = 0;
% dY = 0;
% dX1 = 0;
% dY1 = 0;
% for ctr=1:15
% Q1 = zeros(length(R_r),1);
% Q2 = Q1;
% Q3 = Q1;
% Q4 = Q1;
% parfor i=1:length(R_r)
%     R = R_r(i);
%     num_pxls = 2*pi*R;
%     theta = 0:1/num_pxls:2*pi;
%     x = centroid(1) + R*cos(theta) + dX;
%     y = centroid(2) + R*sin(theta) + dY;
%     sampleG = interp2(X,Y,Ig,x,y);
%     Q1(i) = mean(sampleG(1:floor(num_pxls/4)));
%     Q2(i) = mean(sampleG(floor(num_pxls/4):floor(num_pxls/2)));
%     Q3(i) = mean(sampleG(floor(num_pxls/2):floor(num_pxls*0.75)));
%     Q4(i) = mean(sampleG(floor(num_pxls*0.75):end));
% %    sampleR = interp2(X,Y,Ir,x,y);
% %    radial_average_R(i) = mean(sampleR);
% end
% Q1 = sum(Q1);
% Q2 = sum(Q2);
% Q3 = sum(Q3);
% Q4 = sum(Q4);
% Qsum = Q1+Q2+Q3+Q4;
% dX1 = (Q1+Q4-Q2-Q3)/Qsum;
% dY1 = (Q1+Q2-Q3-Q4)/Qsum;
% dX = dX + 50*dX1;
% dY = dY + 50*dY1;
% if(sqrt(dX1^2+dY1^2)<0.002)
%     break
% end
% end
% rEstimate = radiusG+floor(radiusG_width*1.5);
% rEstimate = min([rEstimate,abs(centroid(1)-imgSize),...
%     abs(centroid(2)-imgSize),centroid(1),centroid(2)]);
% R_r = (rEstimate-floor(radiusG_width*3)):rEstimate;
% radial_average_G = zeros(length(R_r),1);
% %radial_average_R = zeros(length(R_r),1);
% %resample radially
% parfor i=1:length(R_r)
%     R = R_r(i);
%     num_pxls = 2*pi*R;
%     theta = 0:1/num_pxls:2*pi;
%     x = centroid(1) + R*cos(theta) + dX;
%     y = centroid(2) + R*sin(theta) + dY;
%     sampleG = interp2(X,Y,Ig,x,y);
%     radial_average_G(i) = mean(sampleG);
% %    sampleR = interp2(X,Y,Ir,x,y);
% %    radial_average_R(i) = mean(sampleR);
% end
% radial_peak_G = max(radial_average_G);
% radiusG = R_r(find(radial_average_G==radial_peak_G));
% radiusG_width = range(find(radial_average_G>(0.8*radial_peak_G)));
if debug
    figure(6+idSlice*2+100)
 %   hold on
    plot(R_r*pxlSize,radial_average_G,'g-');%,R_r,radial_average_R,'r-')
    xlabel('radial distance \mum')
    ylabel('radial average intensity')
%     R_r = R_r(1:end-1);
%     D_radial_average_G=diff(radial_average_G);
%     D_radial_average_R=diff(radial_average_R);
%     plot(R_r,D_radial_average_G,'g*',R_r,D_radial_average_R,'r*')
end
% if debug
%     %overlay1 = imoverlay(imadjust(Ig),GBW,[.3 1 .3]);
%     figure(1+idSlice*2)
%     hold on
%     imagesc(Ig)
%     viscircles(centroid,radiusG);
%     axis equal
%     hold off
% end
% array = abs(radial_average_R-baseline);
% id = find(array==min(array));
% x = R_r(id-2:id+2)';
% y = radial_average_R(id-2:id+2)-baseline;
% p = polyfit(x,y,1);
% radiusR = -p(2)/p(1);
% thickness = radiusR - radiusG;
% thickness = thickness*pxlSize;
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
    %dR = radiusRBW*pxlSize - radiusR*pxlSize
    %radiusG
end
%radiusG = radius*pxlSize;
