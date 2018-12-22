%%Possible Changes
%What to do when there is no brush?
%Should we assume that the thickness is zero and call it a day?
%This could be calculated by setting a threshold. If the red bead intensity
%of the slide location found from the green bead intensity profile is too
%large, we can then just set the thickness to zero.


%%
%Clears all previous output in Command Window.

cf = 1;
%Folder with the images.
folder='20181114 Height vs Energy Density';

%Must name the folder variable after the folder that contains the oib files
files = dir([folder, '/*.oib']);

%Finds all filenames in the folder
filenames = {files.name};

%Initializes the thickness array. 16 because 4x4 chunks of the images.
bthick = ones(cf^2,length(filenames));

%Creates a new folder in which to put individual plots. 
newFolder = [folder, ' plots ', num2str(cf), 'x', num2str(cf)];
mkdir(newFolder)

%Loops through each oib file in the folder
for x=1:length(filenames)
    F = fullfile(folder, filenames(x));
    img = bfopen(F{1});
    
    %cf is the chunking factor
    bthick(:,x) = greenBeadPlotter(img, x, folder, newFolder, cf);
    
end
%Saves the array bthick to a .mat file called "(folder name) thicknesses"
save([folder,' thicknesses'],'bthick')

%%Possible improvements: Have it go through EVERY folder
    %Name things better
    %Output more cohesive data
    
function bThickness = greenBeadPlotter(data, num, folder, newFolder, cf)
[b,a] = butter(1,20/50);

%extracts the cell array that contains all the zstacks
images = length(data{1,1}); 

%assigns the number of zstacks to rows
[rows, cols] = size(data{1,1}{1,1}); 

%initializing a vector for the mat2cell function
% rowsplits = rows./4; 
% rowsplitter = [rowsplits, rowsplits, rowsplits, rowsplits]; 
% colsplits = cols./4;
% colsplitter = [colsplits, colsplits, colsplits, colsplits];

rowsplits = floor(rows./cf); 
rowsplitter = ones(1,cf);
rowsplitter(1,:) = rowsplits;
if rowsplits * cf ~= rows
    rowsplitter(end) = rows - (cf - 1) * rowsplits;
end
colsplits = floor(cols./cf);
colsplitter = ones(1,cf);
colsplitter(1,:) = colsplits;
if colsplits * cf ~= cols
    colsplitter(end) = cols - (cf - 1) * colsplits;
end

% dexProf
% rBeadProf
% gBeadProf

dexProf = []; %initializing Dextran profiles
rBeadProf = []; %initializing 200nm Red Bead profiles
gBeadProf = []; %initializing 20nm Green Bead profiles

%Checks the number of channels and runs with 2 channels if no Dextran. Or
%runs with 3 channels if Dextran is present. 
num_channels = data{1,4}.getChannelCount(0)
if num_channels == 2
    for slice = 1:floor(images / 2)
        
        %mat2cell splits the intensity profile into a 4x4 cell array
        gBeadChunks = mat2cell(data{1,1}{slice*2 - 1,1}, rowsplitter, colsplitter);
        rBeadChunks = mat2cell(data{1,1}{slice*2,1}, rowsplitter, colsplitter);
        
        %It was reading them in backwards
        %rBeadChunks = mat2cell(data{1,1}{slice*2,1}, rowsplitter, colsplitter);
        %gBeadChunks = mat2cell(data{1,1}{slice*2 -1,1}, rowsplitter, colsplitter);
    
        for y=1:cf^2 

            %loops through all 16 indices of the mat2cell output and 
            %replaces them with the average of the intensity profile of that "chunk"
            rBeadChunks{y} = mean(mean(rBeadChunks{y}));
            gBeadChunks{y} = mean(mean(gBeadChunks{y}));
        end
    
    rBeadChunks = cell2mat(rBeadChunks);
    rBeadChunks = rBeadChunks(1:(cf^2))';
    
    gBeadChunks = cell2mat(gBeadChunks);
    gBeadChunks = gBeadChunks(1:(cf^2))';
    
    %assigns chunks(x) to out(x)
    out2 = rBeadChunks;
    out3 = gBeadChunks;
    
    %rBeadProf = [rBeadProf out2]; %200nm RED BEADS
    %gBeadProf = [gBeadProf, out1]; %20nm GREEN BEADS
    
%     %Still backwards?
     rBeadProf = [out2,rBeadProf]; %200nm RED BEADS
     gBeadProf = [out3,gBeadProf]; %20nm GREEN BEADS
    end
    figure;plot(gBeadProf);
    
    %sets up a column vector of the number of stacks in a full zstack
    stacks = (1:images/2)';
   
    
%%    
elseif num_channels == 3
    %Loops through all the individual stacks in a oib file with 3 channels
    for x=images:-3:1
    
    %mat2cell splits the intensity profile into a 4x4 cell array
    %channel order: green, red, 594 dex
    %dexChunks = mat2cell(data{1,1}{x,1}, rowsplitter, colsplitter); 
    %rBeadChunks = mat2cell(data{1,1}{x-1,1}, rowsplitter, colsplitter);
    %gBeadChunks = mat2cell(data{1,1}{x-2,1}, rowsplitter, colsplitter);
    
    %channel order: blue dex, green, red
    dexChunks = mat2cell(data{1,1}{x,1}, rowsplitter, colsplitter); 
    rBeadChunks = mat2cell(data{1,1}{x-1,1}, rowsplitter, colsplitter);
    gBeadChunks = mat2cell(data{1,1}{x-2,1}, rowsplitter, colsplitter);
    
        for y=1:cf^2 

            %loops through all 16 indices of the mat2cell output and 
            %replaces them with the average of the intensity profile of that "chunk"
            dexChunks{y} = mean(mean(dexChunks{y}));
            rBeadChunks{y} = mean(mean(rBeadChunks{y}));
            gBeadChunks{y} = mean(mean(gBeadChunks{y}));
        end
    
    dexChunks = cell2mat(dexChunks); %turns cell array into a double array
    dexChunks = dexChunks(1:(cf^2))'; %turns double array into a row vector
    
    rBeadChunks = cell2mat(rBeadChunks);
    rBeadChunks = rBeadChunks(1:(cf^2))';
    
    gBeadChunks = cell2mat(gBeadChunks);
    gBeadChunks = gBeadChunks(1:(cf^2))';
    
    out1 = dexChunks; %assigns chunks(x) to out(x)
    out2 = rBeadChunks;
    out3 = gBeadChunks;

    dexProf = [dexProf out1]; %DEXTRAN
    rBeadProf = [rBeadProf out2]; %200nm RED BEADS
    gBeadProf = [gBeadProf, out3]; %20nm GREEN BEADS
    end
    stacks = (1:images/3)'
%     figure(37);
%     plot(gBeadProf)
%     error('here');
else
    error('I can only handle 2 or 3 channels');
end

assignin('base','dexProf',dexProf)
assignin('base','rBeadProf',rBeadProf)
assignin('base','gBeadProf',gBeadProf)
assignin('base','stacks',stacks')

gBeadProf = gBeadProf'; %transposes the 20nm Green Bead values to be a column vector
bThickness = ones(1,cf^2); %sets up a row vector of 16 ones

for z=1:(cf^2) 
    
    %This will loop through and analyze each "chunk" separately
    %Averaged intensity value for 200nm Red beads as a row vector
    rBeadProfZ = rBeadProf(z,:);
    rBeadProfZ = filtfilt(b,a,rBeadProfZ);
    
    %Averaged intensity value for 20nm Green beads as a column vector
    gBeadProfZ = gBeadProf(:,z);
    gBeadProfZ = gBeadProfZ - gBeadProfZ(1);
    
   % dexProfZ = dexProf(z,:);
    hold on;
    rBeadProfZ_plot = rBeadProfZ - 200;
   % dexProfZ_plot = dexProfZ - 200;
    
    plot(gBeadProfZ,'g');
    plot(rBeadProfZ_plot,'r');
   % plot(dexProfZ_plot,'c');
    hold off;
    gMax = max(gBeadProfZ); %Used for MinPeakProminence so that findpeaks doesn't find small peaks
    gWidth = floor(length(stacks)./30); %Used for MinPeakWidth so that findpeaks doesn't find skinny peaks
    gWidth = 0;
    [~, gPeak] = findpeaks(gBeadProfZ(1:floor(length(gBeadProf)/2)),'MinPeakHeight',10);%gMax./num_channels);
    gPeak = gPeak(1);
    %Finds the beginning of a peak
    firstGPeak = gPeak - 14;
    
    %If the beginning of the peak is negative, then it will start at the
    %first value
    if firstGPeak <= 0
        firstGPeak = 1;
    end
    
    %Sets up a vector of the x values that correspond to the x values of
    %the peak in the intensity profile
    gGaussX = (firstGPeak:(gPeak+7))';
    
    %Extracts the y values that correspond to the y values of the peak in
    %the intensity profile
    gGaussY = gBeadProfZ(gGaussX);
    assignin('base','gGaussY',gGaussY)
   
    %Creates more points in between the range of xgauss3 to make the fit 
    %more accurate
    gGaussMoreX = linspace(gGaussX(1),gGaussX(end), 1200);
    
    %Performs a gaussian fit on the peak and output a fit object
    f = fit(gGaussX, gGaussY, 'gauss2');
    
    %Fit object is evaluated at all the points of xxgauss3 and outputs
    %yygauss3
    gGaussMoreY = feval(f,gGaussMoreX);
    assignin('base','gGaussMoreY',gGaussMoreY)
    
    f2 = betterFitter(gGaussX, gGaussY);
    gCubicInterp = feval(f2, gGaussMoreX);
    assignin('base','gCubicInterp',gCubicInterp);
    %plot(gGaussX,gGaussY,'b', gGaussMoreX,gGaussMoreY, 'r', gGaussMoreX, gCubicInterp, 'g')
    gGaussMoreY = gCubicInterp;
    %This was used to compare which was more accurate, a gaussian fit or
    %polynomial interpolation
    %yyinterp3 = interp1(gGaussX,gGaussY,gGaussMoreX, 'cubic');
    %assignin('base','yyinterp3',yyinterp3)
    %Finds new max of the fitted output
    gMinPkProm = max(gGaussMoreY);
    rBeadProfMore = interp1(gGaussX, rBeadProfZ(gGaussX), gGaussMoreX);

    %Finds the new peak location of the fitted output
    [gPks,gLocs] = findpeaks(gGaussMoreY,'MinPeakProminence',gMinPkProm./10,'MinPeakWidth',gWidth);
    if isempty(gPks)
        gLocs = input('Where is the slide? (integers only)  ');
        gPks = gBeadProfZ(gLocs);
        slideLoc = gLocs;
        rBeadZeroPoint = rBeadProfZ(gLocs(1));
        
    else
        gPks = gPks(1);
        gLocs = gLocs(1);
        slideLoc = gGaussMoreX(gLocs(1));
        rBeadZeroPoint = rBeadProfMore(gLocs(1));
    end
    
    %Assigns the slide location to the corresponding x value of the peak
    
    %Linearly interpolates more values for the Red Bead profile
    
    %Finds the intensity value that corresponds to the Green Bead peak's x
    %value
    
    %Uses the bead0 value to calibrate for noise
    rBeadCalibProfZ = rBeadProfZ - rBeadZeroPoint;
    
    %Finds the location of the peak in the Red Bead Profile
    [rBeadMax1, rIndMax1] = max(rBeadCalibProfZ);
    if (rIndMax1 > stacks(end) * .7)
        rIndMax1 = ceil(stacks(end) * .65);
    end
    
    %Creates a vector for the x values used to create the best fit line for
    %the decay due to PSF
    rBeadDecayX = rIndMax1:stacks(end);
    
    %Creates a vector for the y values used to create the best fit line for
    %the decay due to PSF
    rBeadDecayY = rBeadCalibProfZ(rIndMax1:end);
    
    %Performs a linear polyfit on the decay trend
    rDecayCoeffs = polyfit(rBeadDecayX, rBeadDecayY, 1);
    if rDecayCoeffs(1) > 0
            [rBeadMax1, rIndMax1] = max(rBeadCalibProfZ);
    end
    rBeadDecayX = rIndMax1:stacks(end);
    rBeadDecayY = rBeadCalibProfZ(rIndMax1:end);
    rDecayCoeffs = polyfit(rBeadDecayX, rBeadDecayY, 1);
    
    
    %Evaluates the best fit line over the entire profile
    rDecayLine = polyval(rDecayCoeffs, 1:stacks(end));
    
    %Divides the Red Bead profile adjusted for noise by the values for the
    %decay best fit line
    if rDecayCoeffs(1) > 0
        rBeadCalibProfZ = rBeadCalibProfZ./rBeadMax1;        
    else
        rBeadCalibProfZ = rBeadCalibProfZ./rDecayLine;
    end
    
    
    %Finds the new maximum of the adjusted Red Bead Profile
    %beadmax2 = max(ydecay);
    rBeadMax2 = 1;
    
    %Establishes the critical bead intensity value as half of the maximum
    %critbead = beadmax2 * 0.5;
    rCritBead = 0.5;
    
    %Used to create more points to find the exact value closest to the
    %critical bead value
    spacing = images./num_channels.*100;
    extrapoints = linspace(1, images./3, spacing);
    
    %Interpolates the extra points
    rBeadCalibProfZMore = interp1(stacks, rBeadCalibProfZ, extrapoints);
    
    %Finds where the difference between the decay values is below a small
    %threshold
    rCritBeadX = find((abs(rBeadCalibProfZMore-rCritBead)<rBeadMax2*0.03));
    
    %Turns the index values of beadx to the raw x values
    rCritBeadX = extrapoints(rCritBeadX);
    
    %This part was used if the threshold was too low, but by creating extra
    %points I was able to by pass this. May be a problem in the future.
    % if isempty(beadx)
    %     beadx = find((abs(ydecay-critbead)<beadmax2*0.07));
    % end
    % if isempty(beadx)
    %     beadx = find((abs(ydecay-critbead)<beadmax2*0.11));
    % end
    % if isempty(beadx)
    %     beadx = find((abs(ydecay-critbead)<beadmax2*0.15));
    % end
    % if isempty(beadx)
    %     beadx = find((abs(ydecay-critbead)<beadmax2*0.19));
    % end
    % if isempty(beadx)
    %     beadx = find((abs(ydecay-critbead)<beadmax2*0.23));
    % end
    
    %Takes the average of all the x values to get the middle one
    rCritBeadX = mean(rCritBeadX);
    
    %Calculates the thickness by subtracting the location of the critical
    %bead value by the slide location
    bThickness(z)= rCritBeadX - slideLoc;
    
    
    % yset1 = mean(yset1,1);
    % yset2 = mean(yset2,1);
    % yset3 = mean(yset3,2);
    
    %Sets up a subplot
    %First plot is the Green Beads and slide location line, and the Red Beads and Red Bead decay line
    %Second plot is a line that shoes the location of the slide, the
    %adjusted Red Beads, and a line that goes from the slide to the
    %critical bead value
    subplot(1,2,1)
    if rDecayCoeffs(1) > 0
        plot([slideLoc, slideLoc], [0, gPks], 'k', stacks, gBeadProfZ, 'g', stacks, rBeadProfZ - rBeadZeroPoint, 'r')

    else
        plot([slideLoc, slideLoc], [0, gPks], 'k', stacks, gBeadProfZ, 'g', stacks, rBeadProfZ - rBeadZeroPoint, 'r', stacks, rDecayLine, 'b')

    end
    axis square
    subplot(1,2,2)
    plot([slideLoc, slideLoc], [0, 1], 'k', stacks, rBeadCalibProfZ, 'r', [slideLoc, rCritBeadX], [rCritBead, rCritBead], 'k')
    axis square
    %Sets directory location to new folder
    cd(newFolder)
    
    %Saves the plots
    print([folder,'img',num2str(num),'chunk',num2str(z)],'-dpng') 
    
    %Goes back to original folder 
    cd ../
    close
    
end
%Transposes the thickness values so that each row corresponds to a "chunk",
%and each column corresponds to an image
bThickness = bThickness';

%These were used to changes the bthickness values to micrometer values
%bthickness = bthickness./10;
%bthickness = num2str(bthickness);
%bthickness = [bthickness,'um'];

end