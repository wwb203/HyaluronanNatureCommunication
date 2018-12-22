%Profile fitting
clear
if exist('../imageAnalyzeFit','dir')~=7
    mkdir('../imageAnalyzeFit');
end
load('coatCellFITWT.mat');
profileStruct = struct();
idStruct = 0;
set(0,'DefaultFigureVisible','off');
for idBead = 1:length(coatCell)
    coat = coatCell{idBead,1};
    if isfield(coat, 'labelArray')
        for pId = 1:size(coat.labelArray,1)
            if coat.labelArray(pId)>0
                idStruct = idStruct + 1;
                y = coat.profileMatrix(:,pId);
                peakId = coat.peakIdArray;
                peakId = peakId(pId);
                endId = coat.endIdArray;
                endId = endId(pId);
                y = y/y(peakId);
                x = coat.R_r*coat.pxlSize;
                x = x';
                profileStruct(idStruct).x = x(peakId:endId)-x(peakId);
                profileStruct(idStruct).y = y(peakId:endId);
                X = profileStruct(idStruct).x;
                Y = profileStruct(idStruct).y;
                [f,gof] = fit(X,Y,'exp1');
                a = coeffvalues(f);
                profileStruct(idStruct).a = a;
                profileStruct(idStruct).gof = gof;
                profileStruct(idStruct).f = f;
                h_fig = figure();
                width = 3;     % Width in inches
                height =3;    % Height in inches
                set(gcf,'InvertHardcopy','on');
                set(gcf,'PaperUnits', 'inches');
                papersize = get(gcf, 'PaperSize');
                left = (papersize(1)- width)/2;
                bottom = (papersize(2)- height)/2;
                myfiguresize = [left, bottom, width, height];
                set(gcf,'PaperPosition', myfiguresize);
                set(gca, 'FontName', 'Times New Roman')
                set(gca,'FontSize',12);
                hold on
                %title(sprintf('%.3f Exp(-x/%.3f), R^2=%.3f',a(1),-1/a(2),gof.rsquare));
                h = plot(f,X,Y);
                set(h,'LineWidth',2);
                set(h,'MarkerSize',12);
                xlabel('Distance to bead surface (\mum)');
                ylabel('Normalized intensity');
                set(gca,'FontSize',12);
                
                legend('data','exp fit');
                box on
                ax = gca;
                ax.LineWidth = 2;
                hold off
                print('GPFn_fit','-dsvg');
                break;
                %saveas(h_fig,sprintf('../imageAnalyzeFit/Bead%dProfile%d.tiff',idBead,pId));
                %close(h_fig)
            end
        end
    end
end
a = extractfield(profileStruct,'a');
a1 = a(1:2:end);
a2 = a(2:2:end);
b = -1./a2;
h_fig = figure();
subplot(2,1,1)
hold on
title(sprintf('a in a*exp(-x/b), mean %.3f std %.3f',mean(a),std(a)));
hist(a1);
%xlabel('Distance to bead surface (\mum)');
%ylabel('Normalized intensity');
set(gca,'FontSize',14);
box on
hold off
subplot(2,1,2)
hold on
title(sprintf('b in a*exp(-x/b), mean %.3f std %.3f',mean(b),std(b)));
hist(b);
%xlabel('Distance to bead surface (\mum)');
%ylabel('Normalized intensity');
set(gca,'FontSize',14);
box on
hold off
saveas(h_fig,'../imageAnalyzeFit/histA.tiff');
close(h_fig)
set(0,'DefaultFigureVisible','on');
save('profileStruct.mat','profileStruct');