%script
clear
if exist('../imageAnalyze3','dir')~=7
    mkdir('../imageAnalyze3');
end
files = dir('../rawData/*.oib');
close all;
debug = false;
set(0,'DefaultFigureVisible','off');
%coatCell = cell(length(files),1);
cRadiusArray = [];
bRadiusArray = [];
for fileId = 12:length(files)
    
    filename = fullfile('../rawData',files(fileId).name);
    data = bfopen(filename);
    numSlice = size(data{1,1},1);
    omeMeta = data{1,4};
    pxlSize = omeMeta.getPixelsPhysicalSizeX(0).getValue();%um
    imgSize = omeMeta.getPixelsSizeX(0).getValue();%pixel
    zStep = data{1,2}.get('Global [Axis 3 Parameters Common] Interval');
    zStep = str2double(zStep)/1000;%zStep size
    coreRadiusArray = zeros(numSlice,1);
    for idSlice = 1:numSlice
        Ib = data{1,1}{idSlice,1};% [coatR, beadR, Profile] =
        coreRadiusArray(idSlice) = funGFPnRadius(Ib,idSlice,false);
        if (coreRadiusArray(idSlice)*pxlSize)>5
            coreRadiusArray(idSlice)=0;
        end
    end
    if max(coreRadiusArray)<2
        cRadiusArray(fileId) = NaN;
        bRadiusArray(fileId) = NaN;
    else
        maxRadiusId = find(coreRadiusArray==max(coreRadiusArray),1,'last');
        Ib = data{1,1}{maxRadiusId,1};%[coatR, beadR, Profile] =
        Ib = im2double(Ib);%convert [0,1] matrix
        coat=funGFPnProfile(Ib,imgSize,pxlSize, false);
        coat.pxlSize = pxlSize;
        
        coatCell{fileId,1} = coat;
        if isfield(coat, 'centroid')
            centroid = coat.centroid;
            h_fig=figure('Position', [100, 100, 1600,1600]);
%            title(sprintf('HAS Bead R = %.2f(um)',bRadius(fileId)));

            subplot(2,2,2);
            hold on
            %title(sprintf('Bead R = %.2f(um)',bRadius(fileId)));
            %title(sprintf('HAS Bead R = %.2f(um)',bRadius(fileId)));
            Irgb=zeros(imgSize,imgSize,3); %initialize the image
            Irgb(:,:,2)=imadjust(Ib);
            imshow(Irgb,'InitialMagnification',200);
            viscircles(centroid,coat.bRadius/pxlSize,'LineStyle',':','LineWidth',1,'EdgeColor','b');
            %viscircles(centroid,cRadius(fileId)/pxlSize,'LineStyle',':','LineWidth',1,'EdgeColor','r');
            hold off
            subplot(2,2,3);
            %plot profile
            hold on
            cArray = coat.cRadiusArray;
            bArray = coat.bRadiusArray;
            cRadiusArray(fileId) = mean(cArray(coat.labelArray>0))*pxlSize;
            bRadiusArray(fileId) = mean(bArray(coat.labelArray>0))*pxlSize;
            title(sprintf('Thickness %.2f',cRadiusArray(fileId)-bRadiusArray(fileId)));
            for pId = 1:length(coat.labelArray)
                if coat.labelArray(pId)>0
                y = coat.profileMatrix(:,pId);
                peakId = coat.peakIdArray;
                peakId = peakId(pId);
                endId = coat.endIdArray;
                endId = endId(pId);
                y = y/y(peakId);
                x = 1:length(y);
                x = x*pxlSize;
                plot(x,y);
                plot(x(peakId),y(peakId),'*','MarkerSize',3);
                plot(x(endId),y(endId),'*','MarkerSize',3);
                end
            end
            subplot(2,2,4);
            hold on
            title('Azimuthal Variation of Thickness');
            imagesc(coat.profileMatrix);
            hold off
            subplot(2,2,1);
            hold on
            plot((1:numSlice)*zStep,coreRadiusArray*pxlSize,'g-');
            plot(maxRadiusId*zStep,coat.bRadius,'g*');
            %plot(maxRadiusId*zStep,cRadius(fileId),'r^');
            xlabel('Z (\mum)');
            ylabel('Radius (\mum)');
            title(sprintf('Bead Radius %.2f(um)',bRadiusArray(fileId)));
            hold off
%             subplot(2,2,3);
%             hold on
%             title('Radial Average Intensity')
%             plot(radius_list*pxlSize,radial_profile/max(radial_profile),'g-');
%             line([bRadius(fileId),bRadius(fileId)],[0,1.2],'color',[0,1,0]);
%             %line([cRadius(fileId),cRadius(fileId)],[0,1.2],'color',[1,0,0]);
%             ylabel('Normalized Intensity');
%             xlabel('Radius (\mum)');
%             ylim([0,1.2])
%             box on
%             hold off
            saveas(h_fig,sprintf('../imageAnalyze3/Beadb%s.tiff',filename(end-8:end-4)));
            close(h_fig);
        end
        sprintf('process %d out of %d\n',fileId,length(files))
    end
end
save('coatCellRawWT.mat','coatCell');
set(0,'DefaultFigureVisible','on');
cRadius = cRadiusArray;
bRadius = bRadiusArray;
thicknessRaw = cRadius - bRadius;
thickness = thicknessRaw(~isnan(thicknessRaw));
thickness = thickness(thickness>0);
save('thicknessRaw.mat','thicknessRaw','cRadius','bRadius');
h_fig = figure(555);
hold on
title(sprintf('Thickness (um) %d beads',length(thickness)));
hist(thickness,10)
hold off
saveas(h_fig,'thickness.tiff');
close(h_fig)