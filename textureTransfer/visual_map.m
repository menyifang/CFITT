function [ featureMap] = visual_map(uvTform,srcimg,trgimg,trgstructEdge)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
valid = (uvTform(:,:,1)~=0)&(uvTform(:,:,2)~=0);
trgstructEdge = trgstructEdge & valid;
[by, bx] = find(trgstructEdge(:,:,1));
uvTformX = uvTform(:,:,1);
uvTformY = uvTform(:,:,2);
ax = (uvTformX(trgstructEdge))';
ay = (uvTformY(trgstructEdge))';
bx = bx+size(srcimg,2);
bx = bx';
by = by';
figure
imshow(cat(2, srcimg, trgimg)) ;
hold on;  
h = line([ax ; bx], [ay ; by]) ;
set(h,'linewidth', 0.1, 'color', 'b') ;
hold off;  
bx=bx-size(srcimg,2);
featureMap=[ax;ay;bx;by];
end

