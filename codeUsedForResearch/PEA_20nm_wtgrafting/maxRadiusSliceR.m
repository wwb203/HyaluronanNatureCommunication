function [maxRadiusId,rArray]=maxRadiusSliceR(data,debug)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%filename = './active/Image0115.oif';
%filename = './overnight/Image0028.oif';
%debug = true;
numSlice = size(data{1,1},1)/2;
rArray = zeros(numSlice,1);
omeMeta = data{1,4};
pxlSize = omeMeta.getPixelsPhysicalSizeX(0).getValue();%um
imgSize = omeMeta.getPixelsSizeX(0).getValue();%pixel
for idSlice = 1:numSlice   
Ig = data{1,1}{idSlice*2-1,1};
Ig = im2double(Ig);
Ir = data{1,1}{idSlice*2,1};
Ir = im2double(Ir);
rArray(idSlice) = funBeadRadiusR(Ig,Ir,imgSize,pxlSize,idSlice,debug);
end
maxRadiusId = find(rArray == max(rArray));
