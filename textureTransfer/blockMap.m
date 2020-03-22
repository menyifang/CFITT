function [ trgimg ] = blockMap( trgmask,trgimg, srcimg ,ifv_sub )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% Avoid sample out of boundary positions
ifv_sub(:,:,1) = clamp(ifv_sub(:,:,1), 1, size(srcimg,2));
ifv_sub(:,:,2) = clamp(ifv_sub(:,:,2), 1, size(srcimg,1));
for i=1:size(trgimg,1)
   for j=1:1:size(trgimg,2)
      if trgmask(i,j)==1&& ~isnan(ifv_sub(i,j,1))&& ~isnan(ifv_sub(i,j,2))
          trgimg(i,j,:)=srcimg(ifv_sub(i,j,2),ifv_sub(i,j,1),:);
      end
   end
end

end

