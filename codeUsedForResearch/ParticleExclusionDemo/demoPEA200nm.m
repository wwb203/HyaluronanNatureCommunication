%script
%naming convention: b is for bead which stands for 8um silica bead
% c is for coat from the fact that pericellular coat
filename = {'4hour200nmDemo.oib',...
    '4hour100nmDemo.oib',...
    'bareBead200nmDemo.oib'};
imgName = {'200nm','100nm','bare200nm'};
num_channels = 2;%dextran and nanoparticles
debugMode = false;
%iterate *.oib files
for fileId = 1:length(filename)
    data = bfopen(filename{fileId});
    numSlice = size(data{1,1},1)/num_channels;
    omeMeta = data{1,4};
    pxlSize = double(omeMeta.getPixelsPhysicalSizeX(0).value);%um
    imgSize = double(omeMeta.getPixelsSizeX(0).getValue());%pixel
    zStep = data{1,2}.get('Global [Axis 3 Parameters Common] Interval');
    zStep = str2double(zStep)/1000;%zStep size in um
    
    rBArray = zeros(numSlice,1);%radius Bead Array
    %find XY slice of largest bead radius which should be close to bead center
    for idSlice = 1:numSlice
        Ib = data{1,1}{idSlice * 2,1};%dextran image, second channel
        Ib = im2double(Ib);
        Ic = data{1, 1}{idSlice * 2 - 1, 1};% 100/200nm nanoparticle image, first channel
        Ic = im2double(Ic);
        [rBArray(idSlice),~,~,~] = funBeadRadiusB(Ib,...
            zeros(1,2), 15, imgSize, pxlSize, idSlice, debugMode);
    end
    if max(rBArray) < 3
        %something is wrong with the image, silica microsphere radius is about 3.8um
        bRadius(fileId) = NaN;
        cRadius(fileId) = NaN;
    else
        %XY slice closest to microsphere center
        maxRadiusId = find(rBArray==max(rBArray),1,'last');
        Ib = data{1, 1}{maxRadiusId * 2, 1};
        Ib = im2double(Ib);
        Ic = data{1, 1}{maxRadiusId * 2 - 1, 1};
        Ic = im2double(Ic);
        [bRadius(fileId),centroid,~,~] = funBeadRadiusB(Ib, zeros(1,2),...
            25, imgSize, pxlSize, maxRadiusId, debugMode);
        edgeThreshold = 0.5;
        [cRadius(fileId),~,cRadialI,~] = funBeadRadiusR3(Ic,...
            centroid,... %use the microsphere center found in dextran channel
            imgSize, pxlSize, maxRadiusId, edgeThreshold, debugMode);
        [~,~,bRadialIForPlot,~] = funBeadRadiusR3(Ib,centroid,...
            imgSize, pxlSize, maxRadiusId, edgeThreshold, false);
        %plot microsphere radius in each XY slice
        h_fig = figure('Position', [100, 100, 800,800]);
        title(sprintf('Bead R = %.2f(um)',bRadius(fileId)));
        hold on
        plot((1:numSlice)*zStep,rBArray,'g-','LineWidth',2);
        plot(maxRadiusId*zStep,bRadius(fileId),'ro','MarkerSize',5);
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
        title(sprintf('Radial Average Intensity, thickness %.2f um', cRadius(fileId) - bRadius(fileId)))
        %in funBeadRadiusR3.m we have R_r = 10:rEstimate;
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
        saveas(h_fig,sprintf('Profile%s.tiff',imgName{fileId}));
        close(h_fig);
    end
end