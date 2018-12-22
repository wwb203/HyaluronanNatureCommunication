function bead = processImgFile(filename)
bead.filename = filename;
data = bfopen(filename);
numSlice = size(data{1,1},1)/2;
omeMeta = data{1,4};
pxlSize = omeMeta.getPixelsPhysicalSizeX(0).getValue();%um
imgSize = omeMeta.getPixelsSizeX(0).getValue();%pixel
zStep = data{1,2}.get('Global [Axis 3 Parameters Common] Interval');
zStep = str2double(zStep)/1000;%zStep size
date = data{1,2}.get('Global [Acquisition Parameters Common] ImageCaputreDate');
date= datenum(date(2:end-1),'yyyy-mm-dd HH:MM:SS');
date = date*24*60;%convert to minute
rBArray = zeros(numSlice,1);%radius Bead Array

for idSlice = 1:numSlice
    Ib = data{1,1}{idSlice*2,1};%200nm image, first channel
    Ib = im2double(Ib);%convert [0,1] matrix
    centroid = zeros(1,2);
    [rBArray(idSlice),~,~,~,~] = ...
        funBeadRadiusB(Ib,centroid,15,imgSize,pxlSize,idSlice,false);
end
if max(rBArray) < 3
    bead.errorFlag = true;
else
    maxRadiusId = find(rBArray==max(rBArray),1,'last');
    Ib = data{1, 1}{maxRadiusId*2, 1};
    Ibd = im2double(Ib);
    Ic = data{1, 1}{maxRadiusId*2 - 1, 1};
    Icd = im2double(Ic);
    centroid = zeros(1,2);
    [bRadius,bCentroid,bRadialI,~,bErrorFlag] = ...
        funBeadRadiusB(Ibd,centroid,25,imgSize,pxlSize,maxRadiusId,false);
    [cRadius,cCentroid,cRadialI,~,cErrorFlag] = ...
        funBeadRadiusR3(Icd,bCentroid,imgSize,pxlSize,maxRadiusId,0.5,false);
    if (bErrorFlag == true) || (cErrorFlag == true)
        bead.errorFlag = true;
    elseif cRadius>(pxlSize*imgSize)
        bead.errorFlag = true;
    else
        bead.errorFlag = false;
        bead.date = date;
        bead.imgSize = imgSize;
        bead.pxlSize = pxlSize;
        bead.numSlice = numSlice;
        bead.zStep = zStep;
        bead.maxRadiusId = maxRadiusId;
        bead.Ib = Ib;
        bead.Ic = Ic;
        bead.bRadius = bRadius;
        bead.cRadius = cRadius;
        bead.bCentroid = bCentroid;
        bead.cCentroid = cCentroid;
        bead.rBArray = rBArray;
        bead.bRadialI = bRadialI;
        bead.cRadialI = cRadialI;
    end
end
end