function [radiusR,centroid,R_r,radial_average_R,p,valleyIntensity]=funBeadRadiusR20(Ic,bRadius,centroid,imgSize,pxlSize,idSlice,baseline,debug)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%process particles channel
levelR = graythresh(Ic);
RBW = im2bw(Ic,levelR);
RBWC =1 - imclose(RBW,strel('disk',20));
BWforeground = RBWC;
RBWC = imclearborder(RBWC);
%if centroid(1)<1
props = regionprops(RBWC,'Centroid','area');%get centroid
%end
if isempty(props)
        radiusR = 0;
    centroid = [NaN,NaN];
    p = [NaN,NaN];
    radial_average_R = NaN;
    valleyIntensity= NaN;
    %errorFlag = true;
    return
else
%centroid = props.Centroid;
end
BG = 1 - imdilate(BWforeground,strel('disk',floor(4/pxlSize)));
BGlevel = Ic(BG==1);
BGlevel = trimmean(BGlevel(:),10);
%radiusRBW = sqrt(bwarea(RBWC)/pi);
if debug
    overlay1 = imoverlay(imadjust(Ic),bwperim(BG),[.3 1 .3]);
    figure(1000+idSlice*2)
    hold on
    imshow(overlay1)
    viscircles(centroid,3);
    axis equal
    hold off
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%estimate exclusion radius
%rEstimate = sqrt(bwarea(RBWC)/pi)+60;
rEstimate = min([abs(centroid(1)-imgSize),...
    abs(centroid(2)-imgSize),centroid(1),centroid(2)]);
rEstimate = floor(rEstimate)-5;
% Create the meshgrid to be used in resampling
[X,Y] = meshgrid(1:imgSize,1:imgSize);
bRadius = floor(bRadius/pxlSize);
R_r = 20:rEstimate;
radial_average_R = zeros(length(R_r),1);
%resample radially
parfor i=1:length(R_r)
    R = R_r(i);
    num_pxls = 2*pi*R;
    theta = 0:1/num_pxls:2*pi;
    x = centroid(1) + R*cos(theta);
    y = centroid(2) + R*sin(theta);
   sampleR = interp2(X,Y,Ic,x,y);
   radial_average_R(i) = trimmean(sampleR,10);
end
%normalize
%radial_average_R = radial_average_R/BGlevel;
%radial_average_R = radial_average_R-radial_average_R(1);

radial_average_R = (radial_average_R-radial_average_R(1))/(BGlevel-radial_average_R(1));

%find peak at peak surface
[~, locs] = findpeaks(radial_average_R,'MinPeakProminence',0.2);
if isempty(locs)
peakId = 1;
else
peakId = locs(1);
end
valleyId = find(radial_average_R(peakId:end)==min(radial_average_R(peakId:end)),1,'last')+peakId-1;
valleyIntensity = min(radial_average_R(peakId:end));
%find midpoint
%baseline = 0.35;
array = abs(radial_average_R(valleyId:end)-baseline);
id = find(array==min(array),1,'first')+valleyId-1;
if id<5||(id+4)>length(R_r)
    figure(6+idSlice*2)
    hold on
    plot(R_r,radial_average_R,'r-');
    plot(R_r(id),radial_average_R(id),'*');
    plot(R_r(id),baseline,'^');
    hold off
    %
    radiusR = NaN;
    centroid = NaN;
    radial_average_R = NaN;
    p = [NaN,NaN];
    errorFlag = true;
    return
end
x = R_r(id-4:id+4)';
y = radial_average_R(id-4:id+4)-baseline;
p = polyfit(x,y,1);
radiusR = -p(2)/p(1);
radiusR = radiusR*pxlSize;
errorFlag = false;
%calculate slope
minId = find(radial_average_R(valleyId:end)<(radial_average_R(valleyId)*1.1),1,'last')+valleyId-1;
maxId = find(radial_average_R(valleyId:end)>0.8,1,'first')+valleyId-1;
if isempty(minId)||isempty(maxId)
    p = [NaN, NaN];
else
x = R_r(minId:maxId)';
y = radial_average_R(minId:maxId);
p = polyfit(x,y,1);
end
if debug
    figure(6+idSlice*2)
    hold on
    plot(R_r,radial_average_R,'r-');
    plot(R_r(peakId),radial_average_R(peakId),'*','MarkerSize',4);
    plot(R_r(valleyId),radial_average_R(valleyId),'*','MarkerSize',4);
    plot(R_r(minId),radial_average_R(minId),'*','MarkerSize',4);
    plot(R_r(maxId),radial_average_R(maxId),'*','MarkerSize',4);
    hold off
end