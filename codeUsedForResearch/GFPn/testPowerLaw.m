figure(33)
hold on
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
                profile_clean = profile_clean/max(profile_clean);
                profile_clean = profile_clean(1:100);
                plot(1:length(profile_clean),1-profile_clean,'b-')
                %plot(endId-peakId+1,profile(endId),'*','MarkerSize',3);
            end
        end
    end
end
hold off