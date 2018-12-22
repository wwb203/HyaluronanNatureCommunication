function [radiusB, radiusC, radial_profile,R_r,centroid,variation_profile]=funGFPnAnalyze(Ib, imgSize, pxlSize,debug)
% [coatR, beadR, Profile] =
level = graythresh(Ib);
bw = im2bw(Ib, level);
bwC = imclose(bw, strel('disk',15));
bwCClear = imclearborder(bwC);
bwCD = imdilate(bwCClear,strel('disk',10));
BG = (1 - imfill(bwC,'holes'))>0;
BG = imreconstruct(bwCD,BG);
bwCore = imfill(bwC,'holes') - bwC;
bwCore = imclearborder(bwCore);
if debug
    overlay1 = imoverlay(imadjust(Ib), BG,[.3 1 .3]);
    figure()
    imshow(overlay1)
end
BG = imerode(BG,strel('disk',30));
BGlevel = Ib(BG==1);
BGlevel = trimmean(BGlevel(:),15);
radiusBW = sqrt(bwarea(bwCore)/3.1415926);
props = regionprops(bwCore,'Centroid','area');%get centroid
if isempty(props)
    radiusB = 0;
    radiusC = 0;
    centroid = [NaN,NaN];
    radial_profile = NaN;
    R_r = NaN;
    variation_profile = NaN;
    return
else
    centroid = props.Centroid;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%estimate exclusion radius
rEstimate = min([abs(centroid(1)-imgSize),...
    abs(centroid(2)-imgSize),centroid(1),centroid(2)]);
rEstimate = floor(rEstimate)-5;
[X,Y] = meshgrid(1:imgSize,1:imgSize);
R_r = max((radiusBW-50),10):rEstimate;
radial_profile = zeros(length(R_r),1);
%resample radially
numAz = 30;
variation_profile = zeros(length(R_r),numAz);
for i=1:length(R_r)
    R = R_r(i);
    num_pxls = 2*pi*R;
    theta = 0:1/num_pxls:2*pi;
    x = centroid(1) + R*cos(theta);
    y = centroid(2) + R*sin(theta);
    sampleR = interp2(X,Y,Ib,x,y);
    radial_profile(i) = mean(sampleR);
    step = floor(length(theta)/numAz);
    variation_profile(i,1) = mean(sampleR(1:step));
    for j = 1:(numAz-1)
        variation_profile(i,j+1) = mean(sampleR((j*step):(j*step+step)));
    end
end

idMax = find(radial_profile==max(radial_profile),1,'first');
radiusB = R_r(idMax)*pxlSize;

c_profile=radial_profile(idMax:end);
c_R_r = R_r(idMax:end);
c_idMin = find(c_profile<BGlevel*1.05,1,'first');
if(length(c_idMin)<1)
    c_idMin = find(c_profile==min(c_profile),1,'first');
end
radiusC = c_R_r(c_idMin)*pxlSize;
if debug
    figure()
    hold on
    plot(R_r,radial_profile,'r-');
    plot(R_r,ones(size(R_r))*BGlevel,'b-');
    hold off
end
end