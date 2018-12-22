%test sample noise
I = Ib;
for xi = 1:size(I,2)
    for yi = 1:size(I,1)
        angle = atan2(yi-centroid(2),xi-centroid(1));
        if angle<0
            angle = angle + 2*pi;
        end
        angle = angle/pi*180;
        if (angle>270)&&(angle<315)
            I(yi,xi) = 0;
        end
    end
end
figure(2)
imagesc(I)
axis equal
figure(3)
imagesc(Ib)
axis equal            