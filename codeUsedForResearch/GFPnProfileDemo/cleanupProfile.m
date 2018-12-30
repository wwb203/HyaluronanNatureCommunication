function ctr = cleanupProfile(variation_profile)
%peak up clean GFPn profile
ctr = 0;
figure
hold on
for i=1:size(variation_profile,2)
    profile = variation_profile(:,i);
    %     min_profile = min(profile);
    %     thresId = find(profile==min_profile,1,'first');
    %     max_after_thres = max(profile(thresId:end));
    %     if (max_after_thres<1.1*min_profile)&&(profile(end)<=(1.2*min_profile))
    peakId = find(profile==max(profile),1,'first');
    profileStd = movstd(profile,10);
    [noiseLevel,ind] = sort(profileStd);
    noiseLevel = mean(noiseLevel(1:5));
    background = profile(ind);
    background = mean(background(1:5));
    profile_clean = profile - background;
    endId = peakId + find(profile_clean(peakId:end)<(5*noiseLevel),1,'First');
    if(isempty(find(profile_clean((endId+10):end)>16*noiseLevel,1)))
        ctr = ctr + 1;
        %thresId = find(profileStd
        %profile_clean = smooth(profile_clean,0.05,'rloess');
        profile_clean = profile_clean/max(profile_clean);
        peakId = find(profile_clean==max(profile_clean),1,'first');
        %profile_clean = profile_clean(peakId:end);
        plot(1:length(profile_clean(peakId:end)),profile_clean(peakId:end),'--')
        %plot(peakId-peakId,profile_clean(peakId),'^');
        %plot(1,profile_clean(endId-peakId+1),'*');
    end
    
    %plot(1:length(profile),profile);
    %plot(thresId,profile(thresId),'*')
    
end
hold off
%end

