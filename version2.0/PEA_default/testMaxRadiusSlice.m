%test maxRadiusSlice
filename = 'Image0013.oif';
close all
data = bfopen(filename);

rArray = maxRadiusSlice(data,false);
id=find(rArray==max(rArray));
R_r = cell(length(rArray),1);
radial_average_G = cell(length(rArray),1);
radial_average_R = cell(length(rArray),1);
thickness = zeros(length(rArray),1);
radiusG = zeros(length(rArray),1);
for i = 1:length(rArray)
    if rArray(i)>0
[thickness(i),radiusG(i),R_r{i},radial_average_G{i},radial_average_R{i}] = funCoatThickness(data,i,false);
    end
end
figure(1)
%cc=hsv(length(find(rArray>0)));
cc = jet(length(rArray))
hold on
for i = 1:length(rArray)
    if rArray(i)>0%&&mod(i,2)==0
        r = R_r{i}';
        G = radial_average_G{i};
        R = radial_average_R{i};
    plot(r,G,'-','color',cc(i,:))
    plot(r,R,'*','color',cc(i,:))
    end
end
hold off
cat(2,rArray,radiusG,thickness)
return
figure(3)
plot(1:13,radiusG(1:13),'g-',1:13,radiusG(1:13)+thickness(1:13)-thickness(1),'r*')
legend('bead','coat')
figure(2)
plot(1:13,radiusG(1:13),'g*',1:13,radiusG(2)*cos((-1:11)/20*pi/2),'g-',1:13,radiusG(1:13)+thickness(1:13),'r*')
%legend('bead','coat')
figure(5)
imageId = 2;
subplot(1,2,1)
imagesc(data{1,1}{imageId*2-1,1})
axis square
subplot(1,2,2)
imagesc(data{1,1}{imageId*2,1})
axis square
figure(6)
plot(1:13,radiusG(1:13),'g-',1:13,radiusG(2)*cos((-1:11)/20*pi/2),'r*')
legend('bead','coat')