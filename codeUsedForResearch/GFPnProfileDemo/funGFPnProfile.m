function coat=funGFPnProfile(Ib, imgSize,pxlSize,debug)
coat = struct();
backroundMask = zeros(imgSize,imgSize);
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
    return
else
    centroid = props.Centroid;
    coat.centroid = centroid;
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
coat.bRadius = radiusB;
profileMatrix = zeros(length(R_r),numAz);
bRadiusArray = zeros(numAz,1);
cRadiusArray = zeros(numAz,1);
labelArray = zeros(numAz,1);
peakIdArray = zeros(numAz,1);
endIdArray = zeros(numAz,1);
thetaStartArray = zeros(numAz,1);
thetaEndArray = zeros(numAz,1);
rawMeanArray = zeros(numAz,1);
rawStdArray = zeros(numAz,1);
ctr = 0;
for i=1:size(variation_profile,2)
    profile = variation_profile(:,i);
    peakId = find(profile==max(profile),1,'first');
    profileStd = movstd(profile,10);
    [noiseLevel,ind] = sort(profileStd);
    noiseLevel = mean(noiseLevel(1:5));
    background = profile(ind);
    background = mean(background(1:5));
    profile_clean = profile - background;
    endId = peakId + find(profile_clean(peakId:end)<(5*noiseLevel),1,'First');
    if(isempty(find(profile_clean((endId+10):end)>16*noiseLevel,1)))
        I = Ib;
        thetaStart = (i-1)*2*pi/numAz;
        thetaEnd = i*2*pi/numAz;
        maxRadius = R_r(end);
        minRadius = R_r(endId)+5;
        if (maxRadius>(minRadius+15))
            for xi = 1:size(I,2)
                for yi = 1:size(I,1)
                    angle = atan2(yi-centroid(2),xi-centroid(1));
                    radius = sqrt((yi-centroid(2))^2+(xi-centroid(1))^2);
                    if angle<0
                        angle = angle + 2*pi;
                    end
                    %angle = angle/pi*180;
                    if (angle>thetaEnd)||(angle<thetaStart)||(radius>maxRadius)||(radius<minRadius)
                        I(yi,xi) = -1;
                    end
                end
            end
            backroundMask = backroundMask + I>=0;
            rawData = I(I>=0);
            if isempty(rawData)
                continue;
            end
            rawMean = mean(rawData);
            rawStd = std(rawData);
            ctr = ctr + 1;
            profile = variation_profile(:,i);
            profile = profile - rawMean;
            endId = peakId -1 + find(profile(peakId:end)<(2*rawStd),1,'first');
            bRadiusArray(i) = R_r(peakId);
            cRadiusArray(i) = R_r(endId);
            labelArray(i) = 1;
            endIdArray(i) = endId;
            peakIdArray(i) = peakId;
            rawMeanArray(i) = rawMean;
            rawStdArray(i) = rawStd;
            thetaStartArray(i) = thetaStart;
            thetaEndArray(i) = thetaEnd;
            %profile_clean = profile_clean(peakId:end);
            if debug
                profile_clean = profile(peakId:end);
                plot(1:length(profile_clean),profile_clean,'b-')
                plot(endId-peakId+1,profile(endId),'*','MarkerSize',3);
            end
        end
    end
end
coat.profileMatrix = variation_profile;
coat.bRadiusArray = bRadiusArray;
coat.cRadiusArray = cRadiusArray;
coat.labelArray = labelArray;
coat.peakIdArray = peakIdArray;
coat.endIdArray = endIdArray;
coat.thetaStartArray = thetaStartArray;
coat.thetaEndArray = thetaEndArray;
coat.rawMeanArray = rawMeanArray;
coat.rawStdArray = rawStdArray;
coat.R_r = R_r;
coat.backroundMask = backroundMask;
% for j = 1:numAz

% end
%
% ctr = 0;
% for i=1:numAz
%     profile = variation_profile(:,i);
%     min_profile = min(profile);
%     thresId = find(profile==min_profile,1,'first');
%     max_after_thres = max(profile(thresId:end));
%     if (max_after_thres<1.1*min_profile)&&(profile(end)<=(1.2*min_profile))
%         ctr = ctr+1;

%         radiusMax = R_r(end);
%         radiusMin = R_r(thresId-3);
%         rawR = sqrt((X-centroid(1)).^2+(Y-centroid(2)).^2);
%         rawAngle = atan2(Y-centroid(2),X-centroid(1));
%         rawAngle(rawAngle<0) = rawAngle(rawAngle<0)+2*pi;
%         rawId1 = find(rawR>radiusMin);
%         rawId2 = find(rawR<radiusMax);
%         rawId3 = find(rawAngle>thetaStart);
%         rawId4 = find(rawAngle<thetaEnd);
%         rawId = intersect(rawId1,rawId2);
%         rawId = intersect(rawId, rawId3);
%         rawId = intersect(rawId, rawId4);
%         sampleRaw = interp2(X,Y,Ib,X(rawId),Y(rawId),'nearest');
%         rawMean(i) = mean(sampleRaw);
%         rawStd(i) = std(sampleRaw);
%         finalProfile = profile - rawMean(i);
%         thresId = find(finalProfile>2*rawStd(i),1,'Last');
%         figure(i)
%         hold on
%         plot(R_r,finalProfile)
%         plot(R_r(thresId),finalProfile(thresId),'*')
%         hold off
%     else
%         rawMean(i) = NaN; rawStd(i) = NaN;
%     end
% end
%
% ctr
% idMax = find(radial_profile==max(radial_profile),1,'first');
% radiusB = R_r(idMax)*pxlSize;
%
% c_profile=radial_profile(idMax:end);
% c_R_r = R_r(idMax:end);
% c_idMin = find(c_profile<BGlevel*1.05,1,'first');
% if(length(c_idMin)<1)
%     c_idMin = find(c_profile==min(c_profile),1,'first');
% end
% radiusC = c_R_r(c_idMin)*pxlSize;
% if debug
%     figure()
%     hold on
%     plot(R_r,radial_profile,'r-');
%     plot(R_r,ones(size(R_r))*BGlevel,'b-');
%     hold off
% end
end