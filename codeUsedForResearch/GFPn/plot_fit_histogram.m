load('fithistogram.mat');
a1 = a(1:2:end);
a2 = a(2:2:end);
b = -1./a2;
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
set(gca,'FontSize',12);
set(gca, 'FontName', 'Times New Roman');

subplot(2,1,1)
hold on
title(sprintf('\\alpha = %.2f ± %.2f',mean(a1),std(a1)));
histogram(a1);
%xlabel('Distance to bead surface (\mum)');
%ylabel('Normalized intensity');
box on
hold off
ax = gca;
ax.LineWidth = 2;
subplot(2,1,2)
hold on
title(sprintf('\\beta = %.2f ± %.2f',mean(b),std(b)));
histogram(b);
ax = gca;
ax.LineWidth = 2;
%xlabel('Distance to bead surface (\mum)');
%ylabel('Normalized intensity');
box on

hold off
print('fit_hist','-dsvg');