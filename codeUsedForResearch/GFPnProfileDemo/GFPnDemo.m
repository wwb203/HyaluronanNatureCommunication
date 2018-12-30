%script
clear
files = dir('*.oib');
close all;
debug = false;

cRadiusArray = [];
bRadiusArray = [];
for fileId = 1:length(files)
    data = bfopen(files(fileId).name);
    numSlice = size(data{1,1},1);
    omeMeta = data{1,4};
    pxlSize = double(omeMeta.getPixelsPhysicalSizeX(0).value);%um
    imgSize = double(omeMeta.getPixelsSizeX(0).getValue());%pixel
    zStep = data{1,2}.get('Global [Axis 3 Parameters Common] Interval');
    zStep = str2double(zStep)/1000;%zStep size
    coreRadiusArray = zeros(numSlice,1);
    for idSlice = 1:numSlice
        Ib = data{1,1}{idSlice,1};% 
        coreRadiusArray(idSlice) = funGFPnRadius(Ib,idSlice,false);
        if (coreRadiusArray(idSlice)*pxlSize)>5
            coreRadiusArray(idSlice)=0;
        end
    end
    maxRadiusId = find(coreRadiusArray==max(coreRadiusArray),1,'last');
    Ib = data{1,1}{maxRadiusId,1};%[coatR, beadR, Profile] =
    Ib = im2double(Ib);%convert [0,1] matrix
    coat=funGFPnProfile(Ib,imgSize,pxlSize, false);
    coat.pxlSize = pxlSize;
    GFPnProfileDemo;
    GFPnCones;
end
