%script
%clear
if exist('../imageAnalyze4','dir')~=7
    mkdir('../imageAnalyze4');
end
files = dir('../rawData/*.oib');
close all;
debug = false;
set(0,'DefaultFigureVisible','off');
for fileId =1:length(files)
    
    filename = fullfile('../rawData',files(fileId).name);
    data = bfopen(filename);
    numSlice = size(data{1,1},1)/2;
    omeMeta = data{1,4};
    pxlSize = omeMeta.getPixelsPhysicalSizeX(0).getValue();%um
    imgSize = omeMeta.getPixelsSizeX(0).getValue();%pixel
    zStep = data{1,2}.get('Global [Axis 3 Parameters Common] Interval');
    zStep = str2double(zStep)/1000;%zStep size
    
    rBArray = zeros(numSlice,1);%radius Bead Array
    rCArray = zeros(numSlice,1);%radius Coat Array
    rWArray = zeros(numSlice,1);
    pArray = zeros(numSlice,2);
    
    for idSlice = 1:numSlice
        Ib = data{1,1}{idSlice*2,1};%200nm image, first channel
        Ib = im2double(Ib);%convert [0,1] matrix
        Ic = data{1, 1}{idSlice*2 - 1, 1};
        Ic = im2double(Ic);
        centroid = zeros(1,2);
        %[rBArray(idSlice),~,~,~] = funBeadRadiusR(Ib,centroid,imgSize,pxlSize,idSlice,0.35,false);
        [rBArray(idSlice),centroid,~,~] = funBeadRadiusB(Ib,centroid,15,imgSize,pxlSize,idSlice,false);
        %[rCArray(idSlice),~,~,~] = funBeadRadiusR(Ic,centroid,imgSize,pxlSize,idSlice,0.5,false);
        %[rCArray(idSlice),~,~,~] = funBeadRadiusB(Ic,centroid,15,imgSize,pxlSize,idSlice,false);
    end
    if max(rBArray) < 3
        bRadius(fileId) = NaN;
        cRadius(fileId) = NaN;
    else
    maxRadiusId = find(rBArray==max(rBArray),1,'last');
    Ib = data{1, 1}{maxRadiusId*2, 1};
    Ib = im2double(Ib);
    Ic = data{1, 1}{maxRadiusId*2 - 1, 1};
    Ic = im2double(Ic);
    centroid = zeros(1,2);
    [bRadius(fileId),centroid,bRadialI,~] = funBeadRadiusB(Ib,centroid,25,imgSize,pxlSize,maxRadiusId,false);
    [cRadius(fileId),~,cRadialI,~] = funBeadRadiusR3(Ic,centroid,imgSize,pxlSize,maxRadiusId,0.5,false);
    h_fig=figure('Position', [100, 100, 800,800]);
    title(sprintf('HAS Bead R = %.2f(um)',bRadius(fileId)));
    subplot(2,2,1);
    hold on
    plot((1:numSlice)*zStep,rBArray,'g-');
    plot(maxRadiusId*zStep,bRadius(fileId),'g*');
    %plot(maxRadiusId*zStep,cRadius(fileId),'r^');
    xlabel('Z (\mum)');
    ylabel('Radius (\mum)');
    title(sprintf('Thickness %.2f(um)',cRadius(fileId)-bRadius(fileId)));
    hold off
    subplot(2,2,2);
    hold on
    title('Bead Radius in Z');
    %title(sprintf('HAS Bead R = %.2f(um)',bRadius(fileId)));
    Irgb=zeros(imgSize,imgSize,3); %initialize the image
    Irgb(:,:,2)=imadjust(Ib);
    imshow(Irgb,'InitialMagnification',200);
    viscircles(centroid,bRadius(fileId)/pxlSize,'LineStyle',':','LineWidth',1,'EdgeColor','b');
    hold off
    subplot(2,2,4);
    hold on
    title(sprintf('Exclusion Particle R = %.2f(um)',cRadius(fileId)));
    Irgb=zeros(imgSize,imgSize,3); %initialize the image
    Irgb(:,:,1)=imadjust(Ic);
    %Irgb(:,:,2)=imadjust(Ib);
    imshow(Irgb,'InitialMagnification',200);
    viscircles(centroid,cRadius(fileId)/pxlSize,'LineStyle',':','LineWidth',1,'EdgeColor','b');
    hold off
    subplot(2,2,3);
    hold on
    title('Radial Average Intensity')
    plot((1:length(cRadialI))*pxlSize+9*pxlSize,cRadialI,'r-');
    plot((1:length(bRadialI))*pxlSize+9*pxlSize,bRadialI/max(bRadialI),'g-');
    line([bRadius(fileId),bRadius(fileId)],[-1.2,1.2],'color',[0,1,0]);
    line([cRadius(fileId),cRadius(fileId)],[-1.2,1.2],'color',[1,0,0]);
    ylabel('Normalized Intensity');
    xlabel('Radius (\mum)');
    ylim([-1.2,1.2])
    box on
    hold off
    saveas(h_fig,sprintf('../imageAnalyze4/Beadb%s.tiff',filename(end-8:end-4)));
    close(h_fig);
    end
end
set(0,'DefaultFigureVisible','on');
thicknessRaw = cRadius - bRadius;
thickness = thicknessRaw(~isnan(thicknessRaw));
thickness = thickness(thickness>0.3);
save('thicknessRaw2_13_new2.mat','thicknessRaw','cRadius','bRadius');
h_fig = figure(555);
hold on
title(sprintf('Thickness (um) %d beads',length(thickness)));
hist(thickness,sshist(thickness))
hold off
saveas(h_fig,'thickness4.tiff');
close(h_fig)