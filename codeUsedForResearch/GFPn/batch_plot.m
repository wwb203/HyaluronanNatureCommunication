numBead = 6;
for idBead = 1:numBead
    load(sprintf('bead%d.mat',idBead));
for idTime = 1:length(Beads)
    idSlice = Beads(idTime).maxRadiusId;
    Ig = Beads(idTime).Ig;
    Ir = Beads(idTime).Ir;
    R_r = Beads(idTime).R_r;
    R_r = R_r.*Beads(idTime).pxlSize;
    pxlSize = Beads(idTime).pxlSize;
    radiusG = Beads(idTime).radiusG;
    radiusR = Beads(idTime).thickness + radiusG;
    centroid = Beads(idTime).centroid;
    thickness = Beads(idTime).thickness;
    h_fig = figure(15);
    subplot(211)
    hold on
    title('Radial Average Intensity');
    plot(R_r,Beads(idTime).radial_average_G,'g-',...
         R_r,Beads(idTime).radial_average_R,'r*');
    xlabel('Radius \mum');
    ylabel('Intensity');
    legend('HAS Bead','Exclusion Particle','Location','northwest');
    hold off
    subplot(223)
    hold on
    title('Green Channel')
    imagesc(Ig)
    viscircles(centroid,radiusG/pxlSize);
    axis equal
    axis off
    hold off
    subplot(224)
    hold on
    title(sprintf('Red Channel, H=%.2f um',thickness))
    imagesc(Ir)
    viscircles(centroid,radiusR/pxlSize);
    axis equal
    axis off
    hold off
    set(gca,'DefaultTextFontSize',18)
    saveas(h_fig,sprintf('Bead%dFrame%d.tiff',idBead,idTime));
    close(h_fig);
end
end