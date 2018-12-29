%code snippet from codeUsedForResearch/PEA_default/funBeadRadiusB.m

%%Difference of Gaussian
sigma = 25; % unit: pixel
Ibb = imgaussfilt(Ib,sigma);%Ib is image of silica bead from dextran channel
Ibf = Ib - Ibb;
Ibf = Ibf - min(Ibf(:));
centroid = regionprops(RBWC,'Centroid','area').Centroid;%get centroid
%%code snippet for raidally averaged intensity profile
% Create the meshgrid to be used in resampling
[X,Y] = meshgrid(1:imgSize,1:imgSize);
rEstimate = sqrt(bwarea(RBWC)/pi)+60;
R_r = 10:rEstimate;
radial_average_R = zeros(length(R_r),1);
%resample radially
for i=1:length(R_r)
    R = R_r(i);
    num_pxls = 2*pi*R;
    theta = 0:1/num_pxls:2*pi;
    x = centroid(1) + R*cos(theta);
    y = centroid(2) + R*sin(theta);
   sampleR = interp2(X,Y,Ibf,x,y);
   radial_average_R(i) = trimmean(sampleR,10);
end
%subtract noise which is estimate at the bead center
radial_average_R = radial_average_R-mean(radial_average_R(1:10));
%locating silica bead surface
%where the profile is closest to zero
arrayAbs = abs(array);
id = find(arrayAbs==min(arrayAbs),1,'first');

%%code snippet for process 20nm particle exclusion assay
%%from codeUsedForResearch/PEA_20nm_wtgrafting/funBeadRadiusR20.m
% 20nm particles partially penetrate brush and stick to the surface of the
% silica bead, when locating the edge of the brush, we avoid the region of
% aggrecated 20nm paricles
%find peak at peak surface
[~, locs] = findpeaks(radial_average_R,'MinPeakProminence',0.2);