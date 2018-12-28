%Snippets are based on cdoeUsedForResearch/planarBrush/BrushThicknessCode.m

%algorithm to locate the surface of the coverslip
%20nm green paritcles sticking to the surface produces a peak
[gPks,gLocs] = findpeaks(gGaussMoreY,'MinPeakProminence',max(gGaussMoreY)./10,'MinPeakWidth',0);

%algorithm for nonuniform z illumination correction
%Uses the bead0 value to substract the noise
rBeadProfZ = rBeadProfZ - rBeadZeroPoint;%rBeadZeroPoint is the intensity at coverslip
%Finds the location of the peak in the Red Bead Profile
[rBeadMax1, rIndMax1] = max(rBeadProfZ);
%starting from the peak location away from the coverslip
%all the change in flourscent intensity is caused by optics instead of
%particle exclusion effect
rBeadDecayX = rIndMax1:stacks(end);
rBeadDecayY = rBeadProfZ(rIndMax1:end);
rDecayCoeffs = polyfit(rBeadDecayX, rBeadDecayY, 1);
rBeadCaliProfZ = rBeadProfZ./rDecayLine;
