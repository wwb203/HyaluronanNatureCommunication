function imageAnalysisResult(bead,filename)
imgSize = bead.imgSize;
pxlSize = bead.pxlSize;
numSlice = bead.numSlice;
zStep = bead.zStep;
bRadius = bead.bRadius;
cRadius = bead.cRadius;
rBArray = bead.rBArray;
maxRadiusId = bead.maxRadiusId;
cRadialI = bead.cRadialI;
bRadialI = bRadialI;
Ib = bead.Ib;
Ic = bead.Ic;
h_fig=figure('Position', [100, 100, 800,800]);
title(sprintf('HAS Bead R = %.2f(um)',bRadius));
subplot(2,2,1);
hold on
plot((1:numSlice)*zStep,rBArray,'g-');
plot(maxRadiusId*zStep,bRadius,'g*');
xlabel('Z (\mum)');
ylabel('Radius (\mum)');
title(sprintf('Thickness %.2f(um)',cRadius-bRadius));
hold off
subplot(2,2,2);
hold on
title('Bead Radius in Z');
%title(sprintf('HAS Bead R = %.2f(um)',bRadius));
Irgb=zeros(imgSize,imgSize,3); %initialize the image
Irgb(:,:,2)=imadjust(Ib);
imshow(Irgb,'InitialMagnification',200);
viscircles(bCentroid,bRadius/pxlSize,'LineStyle',':','LineWidth',1,'EdgeColor','b');
hold off
subplot(2,2,4);
hold on
title(sprintf('Exclusion Particle R = %.2f(um)',cRadius));
Irgb=zeros(imgSize,imgSize,3); %initialize the image
Irgb(:,:,1)=imadjust(Ic);
%Irgb(:,:,2)=imadjust(Ib);
imshow(Irgb,'InitialMagnification',200);
viscircles(bCentroid,cRadius/pxlSize,'LineStyle',':','LineWidth',1,'EdgeColor','b');
hold off
subplot(2,2,3);
hold on
title('Radial Average Intensity')
plot((1:length(cRadialI))*pxlSize+9*pxlSize,cRadialI,'r-');
plot((1:length(bRadialI))*pxlSize+9*pxlSize,bRadialI/max(bRadialI),'g-');
line([bRadius,bRadius],[-1.2,1.2],'color',[0,1,0]);
line([cRadius,cRadius],[-1.2,1.2],'color',[1,0,0]);
ylabel('Normalized Intensity');
xlabel('Radius (\mum)');
ylim([-1.2,1.2])
box on
hold off
saveas(h_fig,filename);
close(h_fig);
end