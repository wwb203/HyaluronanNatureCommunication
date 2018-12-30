%script
%naming convention: b is for bead which stands for 8um silica bead
% c is for coat from the fact that pericellular coat
clear
files = {'4hour20nmDemo.oib'};
imgName = {'20nm'};
bRadius = zeros(length(files),1);
cRadius05 = zeros(length(files),1);
cRadius10 = zeros(length(files),1);
pArray = zeros(length(files),2);
valleyArray = zeros(length(files),1);

for fileId =1:length(files)
    data = bfopen(files{fileId});
    numSlice = size(data{1,1},1)/2;
    omeMeta = data{1,4};
    pxlSize = double(omeMeta.getPixelsPhysicalSizeX(0).value);%um
    imgSize = double(omeMeta.getPixelsSizeX(0).getValue());%pixel
    zStep = data{1,2}.get('Global [Axis 3 Parameters Common] Interval');
    zStep = str2double(zStep)/1000;%zStep size
    
    rBArray = zeros(numSlice,1);%radius Bead Array
    rCArray = zeros(numSlice,1);%radius Coat Array
    
    for idSlice = 1:numSlice
        Ib = data{1,1}{idSlice * 2,1};%dextran image, second channel (Alexa 647)
        Ib = im2double(Ib);
        Ic = data{1, 1}{idSlice * 2 - 1, 1};%nanoparticle image, first channel
        Ic = im2double(Ic);
        [rBArray(idSlice),centroid,~,~] = funBeadRadiusB(Ib,...
            zeros(1,2) , 15, imgSize, pxlSize, idSlice, false);
    end
    if max(rBArray) < 3
        bRadius(fileId) = NaN;
        cRadius05(fileId) = NaN;
        cRadius10(fileId) = NaN;
    else
        maxRadiusId = find(rBArray==max(rBArray),1,'last');
        Ib = data{1, 1}{maxRadiusId * 2, 1};
        Ib = im2double(Ib);
        Ic = data{1, 1}{maxRadiusId * 2 - 1, 1};
        Ic = im2double(Ic);
        [bRadius(fileId), centroid, ~, ~] = funBeadRadiusB(Ib,...
            zeros(1, 2),25,imgSize,pxlSize,maxRadiusId,false);
        edgeThreshold = 0.5;
        [cRadius(fileId),~,R_r,cRadialI,pFittingNearBrushEdge,valleyArray(fileId)] = funBeadRadiusR20(Ic, ...
            bRadius(fileId), centroid, imgSize, pxlSize, maxRadiusId,edgeThreshold,false);
        [~,~,bRadialIForPlot,~] = funBeadRadiusR3(Ib,...
            centroid, imgSize, pxlSize, maxRadiusId, edgeThreshold, false);
        pArray(fileId,1)=pFittingNearBrushEdge(1);
        pArray(fileId,2)=pFittingNearBrushEdge(2);
        if ~isnan(pFittingNearBrushEdge(1))
            intercept = pFittingNearBrushEdge(2);
            slope = pFittingNearBrushEdge(1);
            x05 = (0.5 - intercept)/slope;
            x10 = (1.0 - intercept)/slope;
            %radius of particle exclusion at 50% threshold
            cRadius05(fileId) = x05*pxlSize;
            %radius at 100% threshold when flouresecent intensity matches non-brush region
            cRadius10(fileId) = x10*pxlSize;
            %plot microsphere radius in each XY slice
            h_fig = figure('Position', [100, 100, 800, 800]);
            title(sprintf('Bead R = %.2f(um)', bRadius(fileId)));
            hold on
            plot((1:numSlice) * zStep, rBArray, 'g-', 'LineWidth', 2);
            plot(maxRadiusId * zStep, bRadius(fileId), 'ro', 'MarkerSize', 5);
            xlabel('Z (\mum)');
            ylabel('Radius (\mum)');
            hold off
            saveas(h_fig,sprintf('BeadZSlice%s.tiff',imgName{fileId}));
            
            %print the flourescent image of the XY slice closest to microsphere
            %center
            h_fig=figure('OuterPosition', [100, 100, 640, 640]);
            Irgb=zeros(imgSize,imgSize,3);
            IbAdj = imadjust(Ib);
            Irgb(:,:,2) = IbAdj * 224 / (64 + 224 + 208);
            Irgb(:,:,3) = IbAdj * 208 / (64 + 224 + 208);
            Irgb(:,:,1)= imadjust(Ic);
            imshow(Irgb,'InitialMagnification', 200);
            saveas(gca,sprintf('Image%s.tiff', imgName{fileId}));
            close(h_fig);
            %plot the normalized intensity profile of dextran and nanoparticle
            %channel
            h_fig=figure();
            set(gca,'FontSize', 12)

            %in funBeadRadiusR20.m we have R_r = 10:rEstimate;
            offset = 9;
            plot((1:length(cRadialI)) * pxlSize + offset * pxlSize,...
                cRadialI , 'r-', 'LineWidth', 3);
            hold on
            plot((1:length(bRadialIForPlot)) * pxlSize + offset * pxlSize,...
                bRadialIForPlot ,'-','Color',[0,139,139]./255,'LineWidth',3);
            ylabel('Normalized Intensity');
            xlabel('Distance to Center (\mum)');
            legend('nanoparticle', 'dextran');
            box on
            hold off
            title(sprintf('Radial Average Intensity, thickness %.2f um', cRadius(fileId) - bRadius(fileId)))
            saveas(h_fig,sprintf('Profile%s.tiff',imgName{fileId}));
            close(h_fig);
        else
            bRadius(fileId) = NaN;
            cRadius05(fileId) = NaN;
            cRadius10(fileId) = NaN;
        end
    end
end