filename = 'Image0013.oif';
data = bfopen(filename);
debug = false;
[maxRadiusIdR,rArrayR]=maxRadiusSliceR(data,debug);
%[maxRadiusIdG,rArrayG]=maxRadiusSlice(data,debug)
figure(12)
plot(1:length(rArrayR),rArrayR,'-r',1:length(rArrayG),rArrayG,'g*')