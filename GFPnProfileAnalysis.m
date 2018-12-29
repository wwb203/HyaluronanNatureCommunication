%%estimate bead radius using GFPn channel to locate the XY slice closest to
%%bead center
%%code snippet is from codeUsedForResearch/GFPn/funGFPnRadius.m
%Ib is image of GFPn channel
function radius = funGFPnRadius(Ib)
%[coatR, beadR, Profile] =
level = graythresh(Ib);
bw = im2bw(Ib, level);
bw = bwareaopen(bw,1000);
bwC = imclose(bw, strel('disk',15));
bwCore = imfill(bwC,'holes') - bwC;
bwCore = imclearborder(bwCore);
radius = sqrt(bwarea(bwCore)/3.1415926);
props = regionprops(bwCore,'area');
if length(props)>1
    radius = 0;
end
end
%%code snippet is from codeUsedForResearch/GFPn/funGFPnProfile.m
%%locate the brush region from the radially averaged profile
%brush region starts from where the intensity peaks
peakId = find(profile==max(profile),1,'first');
profileStd = movstd(profile,10);
[noiseLevel,ind] = sort(profileStd);
noiseLevel = mean(noiseLevel(1:5));
background = profile(ind);
background = mean(background(1:5));
profile_clean = profile - background;
%edge of brush is defined where the intensity drops to 5 fold of noise
%level estimated at the tail of the radially averaged profile
endId = peakId + find(profile_clean(peakId:end)<(5*noiseLevel),1,'First');