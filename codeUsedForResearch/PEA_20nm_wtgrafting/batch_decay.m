%files = dir('*.oif');
numBead = 7;
beadFile = cell(numBead,1);

beadFile{1} = [13,20,27,37,44,51,58,65,72,79,86,93,100,107,114];
beadFile{2} = [14,21,28,38,45,52,59,66,73,80,87,94,101,108];
beadFile{3} = [15,22,32,39,46,53,60,67,74,81,88,95,102,109];
beadFile{4} = [16,23,33,40,47,54,61,68,75,82,89,96,103,110];
beadFile{5} = [17,24,34,41,48,55,62,69,76,83,90,97,104,111];
beadFile{6} = [18,25,35,42,49,56,63,70,77,84,91,98,105,112];
beadFile{7} = [19,26,36,43,50,57,64,71,78,85,92,99,106,113];
for idBead = 2:7%numBead
    numTime = length(beadFile{idBead});
    thickness = [];
    radius = [];
    debug = false;
    Beads = struct('maxRadiusId',{},'rArray25',{},'thickness',{},...
        'radial_average_G',{},'radial_average_R',{});
    for idTime = 1:numTime
        data = bfopen(sprintf('Image%04d.oif',beadFile{idBead}(idTime)));
        sprintf('idBead:%d, numBead:%d,idFrame:%d,numFrame:%d',idBead,numBead,idTime,numTime)
        date1 = data{1,2}.get('Global [Acquisition Parameters Common] ImageCaputreDate');
        date1= datenum(date1(2:end-1),'yyyy-mm-dd HH:MM:SS');
        [maxRadiusId,rArray25] = maxRadiusSliceR(data,debug);
        
        [thickness,radiusG,R_r,radial_average_G,radial_average_R,dRG,dRR,centroid,pxlSize,Ig,Ir]=funCoatThickness(data,maxRadiusId,debug);
        
        Beads(idTime).maxRadiusId = maxRadiusId;
        Beads(idTime).rArray25 = rArray25;
        Beads(idTime).thickness = thickness;
        Beads(idTime).radiusG = radiusG;
        Beads(idTime).radial_average_G = radial_average_G;
        Beads(idTime).radial_average_R = radial_average_R;
        Beads(idTime).dRG = dRG;
        Beads(idTime).dRR = dRR;
        Beads(idTime).centroid = centroid;
        Beads(idTime).pxlSize = pxlSize;
        Beads(idTime).Ig = Ig;
        Beads(idTime).Ir = Ir;
        Beads(idTime).R_r = R_r;
        Beads(idTime).date = date1;
    end
    tArray = zeros(numTime,1);
    dArray = zeros(numTime,1);
    for idTime = 1:numTime
        tArray(idTime) = Beads(idTime).thickness;
        dArray(idTime) = Beads(idTime).date;
    end
    figure(idBead)
    plot((dArray(:)-dArray(1))*24*60,tArray)
    ylabel('Polymer Thickness (\mum)')
    xlabel('Time (min)')
    set(gca,'FontSize',18)
    save(sprintf('Rbead%d.mat',idBead),'Beads','tArray','dArray');
end
