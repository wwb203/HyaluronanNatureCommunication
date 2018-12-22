function radius = funGFPnRadius(Ib,idSlice,debug)
%[coatR, beadR, Profile] = 
level = graythresh(Ib);
bw = im2bw(Ib, level);
bw = bwareaopen(bw,1000);
bwC = imclose(bw, strel('disk',15));
bwCore = imfill(bwC,'holes') - bwC;
bwCore = imclearborder(bwCore);
if debug
    overlay1 = imoverlay(imadjust(Ib), bwCore,[.3 1 .3]);
    figure(100+idSlice)
    imshow(overlay1)
end
radius = sqrt(bwarea(bwCore)/3.1415926);
props = regionprops(bwCore,'Centroid','area');
if length(props)>1
    radius = 0;
end
end