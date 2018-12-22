bRadiusArray = [];
for i=1:length(coatCell)
    if ~isempty(coatCell{i,1})&&isfield(coatCell{i,1},'bRadius')
        bRadiusArray = [bRadiusArray,coatCell{i,1}.bRadius];
    end
end
mean(bRadiusArray)
std(bRadiusArray)