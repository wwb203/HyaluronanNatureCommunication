numBead = 7;
close all
figure(1)
cc = jet(numBead);
hold on
title('Exclusion Radius - R0')
pArray=[];
for idBead = 1:numBead
    load(sprintf('Rbead%d.mat',idBead));
    tArray = [];
    dArray = [];
    for idTime = 1:length(Beads)
        tArray(idTime) = Beads(idTime).thickness+Beads(idTime).radiusG-Beads(1).radiusG;
        dArray(idTime) = Beads(idTime).date;
    end
    plot((dArray(:)-dArray(1))*24*60+40,tArray,'-','Color',cc(idBead,:),'LineWidth',2);
    t=(dArray(:)-dArray(1))*24*60;
     pArray=cat(1,pArray,polyfit(t(1:7),tArray(1:7)',1));
end
return
ylabel('Polymer Thickness (\mum)')
xlabel('Time (min)')
xlim([30,180])
set(gca,'FontSize',18)
box on
hold off
return
figure(4)
cc = jet(numBead);
hold on
title('Exclusion Radius - R(t)')
for idBead = 1:numBead
    load(sprintf('bead%d.mat',idBead));
    tArray = [];
    dArray = [];
    for idTime = 1:length(Beads)
        tArray(idTime) = Beads(idTime).thickness+Beads(idTime).radiusG-Beads(1).radiusG;
        dArray(idTime) = Beads(idTime).date;
    end
    plot((dArray(:)-dArray(1))*24*60+40,tArray,'-','Color',cc(idBead,:),'LineWidth',2)
end
ylabel('Polymer Thickness (\mum)')
xlabel('Time (min)')
xlim([30,180])
set(gca,'FontSize',18)
box on
hold off
figure(2)
cc = jet(numBead);
hold on
title('2 Hour Synthesis, 37C')
for idBead = 1:numBead
    load(sprintf('bead%d.mat',idBead));
    tArray = [];
    dArray = [];
    for idTime = 1:length(Beads)
        tArray(idTime) = Beads(idTime).radiusG;
        dArray(idTime) = Beads(idTime).date;
    end
    plot((dArray(:)-dArray(1))*24*60+40,tArray,'-','Color',cc(idBead,:),'LineWidth',2)
end
ylabel('Bead Radius (\mum)')
xlabel('Time (min)')
xlim([30,180])
set(gca,'FontSize',18)
box on
hold off
figure(4)
cc = jet(numBead);
hold on
title('Glass Bead Radius')
for idBead = 2:2
    load(sprintf('bead%d.mat',idBead));
    tArray = [];
    dArray = [];
    for idTime = 1:length(Beads)
        tArray(idTime) = Beads(idTime).radiusG+Beads(idTime).thickness;
        dArray(idTime) = Beads(idTime).date;
    end
    plot((dArray(:)-dArray(1))*24*60+40,tArray,'-','Color','Black','LineWidth',2)
end
ylabel('Radius (\mum)')
xlabel('Time (min)')
xlim([30,180])
set(gca,'FontSize',18)
box on
hold off