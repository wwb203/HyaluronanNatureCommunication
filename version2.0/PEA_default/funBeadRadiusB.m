function [radiusB,centroid,radial_average_R,p,errorFlag]=funBeadRadiusB(Ib,centroid,sigma,imgSize,pxlSize,idSlice,debug)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%process silica bead channel
Ibb = imgaussfilt(Ib,sigma);
Ibf = Ib - Ibb;
Ibf = Ibf - min(Ibf(:));
if debug
    figure(500 + idSlice*2)
    imagesc(Ibf)
end
levelB = graythresh(Ibb);
RBW = im2bw(Ibb,levelB);
RBWC =1 - imclose(RBW,strel('disk',10));
RBWC = imclearborder(RBWC);
if centroid(1)<1
props = regionprops(RBWC,'Centroid','area');%get centroid
if isempty(props)
        radiusB = 0;
    centroid = [NaN,NaN];
    p = NaN;
    radial_average_R = NaN;
    errorFlag = true;
    return
else
centroid = props.Centroid;
end
end
if debug
    overlay1 = imoverlay(imadjust(Ib),bwperim(RBWC),[.3 1 .3]);
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
   sampleR = interp2(X,Y,Ibf,x,y);
   radial_average_R(i) = trimmean(sampleR,10);
end
%normalize
%radial_average_R = radial_average_R/BGlevel;
radial_average_R = radial_average_R-mean(radial_average_R(1:10));
idMin = find(radial_average_R==min(radial_average_R),1,'first');
idMax = find(radial_average_R==max(radial_average_R),1,'first');
LradialArray = length(radial_average_R);
if (idMax-1<1)||((idMax+1)>LradialArray)
          radiusB = 0;
    centroid = [NaN,NaN];
    p = NaN;
    radial_average_R = NaN;
    errorFlag = true;
    return
end
if abs(mean(radial_average_R((idMax-1):(idMax+1))))<0.3*abs(radial_average_R(idMin))
      radiusB = 0;
    centroid = [NaN,NaN];
    p = NaN;
    radial_average_R = NaN;
    errorFlag = true;
    return
end
idMax = find(radial_average_R(idMin:end)>0.1*abs(radial_average_R(idMin)),1,'first');
idMax = idMax + idMin - 1;
%find midpoint
array = radial_average_R(idMin:idMax);
arrayAbs = abs(array);
id = find(arrayAbs==min(arrayAbs),1,'first');
if id<3
        radiusB = 0;
    centroid = [NaN,NaN];
    p = NaN;
    radial_average_R = NaN;
    errorFlag = true;
%     figure(6+idSlice*2)
%     plot(R_r,radial_average_R,'r-');
    return
end
id = id + idMin - 1;
p = NaN;
if isempty(id)
    radiusB = 0;
    centroid = [NaN,NaN];
    p = NaN;
    radial_average_R = NaN;
    errorFlag = true;
    return
end
% x = R_r(id-2:id+2)';
% y = radial_average_R(id-2:id+2);
% p = polyfit(x,y,1);
% radiusB = -p(2)/p(1);
% radiusB = radiusB*pxlSize;
radiusB = R_r(id)*pxlSize;
errorFlag = false;
if debug
    figure(6+idSlice*2)
    plot(R_r,radial_average_R,'r-');
end