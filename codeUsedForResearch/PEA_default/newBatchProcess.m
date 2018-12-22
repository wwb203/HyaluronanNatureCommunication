%clear;
experimentFolder = {'day1','day3','day5','day7','day14','1hour','2hour','SDS'};
rootFolder = 'D:\Project Material\grafting\';
for idExperiment = 4:length(experimentFolder)
    currentFolder = fullfile(rootFolder,...
        experimentFolder{idExperiment},'rawData');
    fileArray = dir(fullfile(currentFolder,'*.oib'));
    beadArray = cell(length(fileArray),1);
    for idBead = 1:length(fileArray)
        filename = fullfile(currentFolder,fileArray(idBead).name);
        sprintf('processing %s (%d/%d)',...
            experimentFolder{idExperiment},idBead,length(fileArray))
        beadArray{idBead} = processImgFile(filename);
    end
    save(sprintf('desorption4H_EDC_1%s.mat',...
        experimentFolder{idExperiment}),...
        'beadArray');
end
