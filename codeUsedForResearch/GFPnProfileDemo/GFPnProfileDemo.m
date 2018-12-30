h_fig=figure();%'Position', [100, 100, 800,800]);
ctr = 0;
hold on
map = [1,0,0;...
    0,0,1;...
    0,1,0];
C = lines(3);
for pId = 1:length(coat.labelArray)
    fittingResult = [];
    if coat.labelArray(pId)>0&&ctr<3
        ctr = ctr + 1;
        y = coat.profileMatrix(:,pId);
        peakId = coat.peakIdArray;
        peakId = peakId(pId);
        endId = coat.endIdArray;
        endId = endId(pId);
        y = y/y(peakId);
        x = coat.R_r;
        x = x';
        x = x*pxlSize;
        plot(x,y,'LineWidth',2,'LineStyle','--','Color',[0,0,1]);
        plot(x(peakId),y(peakId),'o','MarkerSize',10,'LineWidth',2,'Color',C(ctr,:));%,'Color',map(ctr,:));
        plot(x(endId),y(endId),'^','MarkerSize',10,'LineWidth',2,'Color',C(ctr,:));%;,'Color',map(ctr,:));
        f = fit(x(peakId:endId),y(peakId:endId),'exp1');% fit to exponential decay
        fittingResult = cat(1,fittingResult,[f.a,f.b]);
    end
end
hold off
%axis square
ax = gca;
ax.LineWidth = 1;
box on
xlim([2,10])
ylim([0.05,1.05])
xlabel('Distance to Center (\mum)');
ylabel('Intensity (A.U.)');
set(gca,'FontSize',18);
saveas(h_fig,'GFPnProfile.png');