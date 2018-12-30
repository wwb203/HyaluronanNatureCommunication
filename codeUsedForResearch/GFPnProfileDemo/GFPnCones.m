h_fig=figure('Position', [100, 100, 800,800]);
hold on
backroundMask = coat.backroundMask;
centroid = coat.centroid;
imagesc(Ib);%,'InitialMagnification',200);
viscircles(centroid,coat.bRadius/pxlSize,'LineStyle','-','LineWidth',3,'EdgeColor','b');
colormap(gray);
rArray = 1:floor(imgSize*sqrt(2));
C = prism(sum(coat.labelArray>0)); 
ctr = 0;

for pId = 1:length(coat.labelArray)
    if coat.labelArray(pId)>0
    ctr = ctr + 1;
        plot(centroid(1)+rArray.*cos(coat.thetaEndArray(pId)),centroid(2)+rArray.*sin(coat.thetaEndArray(pId)),'color',C(ctr,:),'LineWidth',3,'LineStyle',':');
    plot(centroid(1)+rArray.*cos(coat.thetaStartArray(pId)),centroid(2)+rArray.*sin(coat.thetaStartArray(pId)),'color',C(ctr,:),'LineWidth',3,'LineStyle','--');
    end
end
for i=1:10:imgSize
    for j=1:10:imgSize
        if(backroundMask(j,i))
            plot(i,j,'g.','LineWidth',10,'MarkerSize',20)
        end
    end
end
axis square
%
hold off
xlim([0,640])
ylim([0,640])
axis off
set(gca,'position',[0 0 1 1],'units','normalized')
%iptsetpref('ImshowBorder','tight');
saveas(h_fig,'GFPnCone.png');