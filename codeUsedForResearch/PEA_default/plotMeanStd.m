clear;
experimentFolder = {'day1','day3','day5','day7','day14','1hour','2hour','SDS'};
meant = [];
stdt = [];
meanb = [];
stdb = [];
for idExperiment = 1:length(experimentFolder)
    tArray = [];
    bArray = [];
    cArray = [];
    ctr = 0;
    load(sprintf('desorption4H_EDC_1%s.mat',...
        experimentFolder{idExperiment}));
    for idBead = 1:length(beadArray)
        if(~beadArray{idBead}.errorFlag)
            ctr = ctr + 1;
            tArray(ctr) = beadArray{idBead}.cRadius-beadArray{idBead}.bRadius;
            bArray(ctr) = beadArray{idBead}.bRadius;
            cArray(ctr) = beadArray{idBead}.cRadius;
        end

    end
        meant(idExperiment) = mean(tArray);
        stdt(idExperiment) = std(tArray);
        meanb(idExperiment) = mean(bArray);
        stdb(idExperiment) = std(bArray);
        meanc(idExperiment) = mean(cArray);
        stdc(idExperiment) = std(cArray);
end
return
%figure(33)
%errorbar([1,3,5,7,14,20,21,22],meant,stdt)
h_fig = figure(1);
hold on
%errorbar(time(1),mean_thickness(1),std_thickness(1),'b','LineWidth',2);
errorbar([1,3,5,7,9], meant(1:5), stdt(1:5),'k','LineWidth',2);
ylim([0,5])
xlim([-0.5,10])
set(gca,'XTick',[0 1 3 5 7 9])
labelsx = ['0 ';
    ' 1';
    ' 3';
    ' 5';
    ' 7';
    '14';];
set(gca,'XTickLabel',labelsx);
%title('PEA Growth Curve');
xlabel('Desorption Duration(day)');
ylabel('HA Thickness (\mum)');
set(gca,'FontSize',18);
hold off
box on
saveas(h_fig,'CrosslinkCurve.tiff');
close(h_fig);
h_fig = figure(1);
hold on
%errorbar(time(1),mean_thickness(1),std_thickness(1),'b','LineWidth',2);
errorbar([1,3,5,7,9], meanb(1:5), stdb(1:5),'k','LineWidth',2);
ylim([0,5])
xlim([-0.5,10])
set(gca,'XTick',[0 1 3 5 7 9])
labelsx = ['0 ';
    ' 1';
    ' 3';
    ' 5';
    ' 7';
    '14';];
set(gca,'XTickLabel',labelsx);
%title('PEA Growth Curve');
xlabel('Desorption Duration(day)');
ylabel('HA Thickness (\mum)');
set(gca,'FontSize',18);
hold off
box on
saveas(h_fig,'beadRadius.tiff');
close(h_fig);
h_fig = figure(1);
hold on
%errorbar(time(1),mean_thickness(1),std_thickness(1),'b','LineWidth',2);
errorbar([1,3,5,7,9], meanc(1:5), stdc(1:5),'k','LineWidth',2);
ylim([0,5])
xlim([-0.5,10])
set(gca,'XTick',[0 1 3 5 7 9])
labelsx = ['0 ';
    ' 1';
    ' 3';
    ' 5';
    ' 7';
    '14';];
set(gca,'XTickLabel',labelsx);
%title('PEA Growth Curve');
xlabel('Desorption Duration(day)');
ylabel('HA Thickness (\mum)');
set(gca,'FontSize',18);
hold off
box on
saveas(h_fig,'coatRadius.tiff');
close(h_fig);