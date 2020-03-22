function [ uvTform_L ] = getInitUvTform( mapH, sizeH, sizeL, pRad)
% GETINITUVTFORM:
%    convert structure matching in sizeH into uvTform format in sizeL
%   
% Input:
%   - mapH, sizeH, sizeL, pRad
% Output:
%   - uvTform_L

imgH_H = sizeH(1);
imgW_H = sizeH(2);
imgH_L = sizeL(1);
imgW_L = sizeL(2);
uvMaps = ones(imgH_L, imgW_L);
uvMaps([1:pRad, end-pRad+1:end], :) = 0;
uvMaps(:, [1:pRad, end-pRad+1:end]) = 0;
[rUv, cUv] = find(uvMaps);
subL = cat(2, cUv, rUv)';

sX = imgH_H/imgH_L;     sY = imgW_H/imgW_L;
uvPixH.sub = round(diag([sX, sY])* subL);
uvPixH.sub(1,:) = clamp(uvPixH.sub(1,:), pRad+1, imgW_H - pRad);
uvPixH.sub(2,:) = clamp(uvPixH.sub(2,:), pRad+1, imgH_H - pRad);
uvPixH.ind = sub2ind([imgH_H, imgW_H], uvPixH.sub(2,:), uvPixH.sub(1,:));

uvTform_H = uvMat_from_uvMap(mapH, uvPixH);
uvTform_H(1:2,:) = diag([1/sX, 1/sY])*uvTform_H(1:2,:);

% % Refinement
% refineVec = subL - diag([1/sX, 1/sY])*uvPixH.sub;
% uvTform_L = trans_tform(uvTform_H, refineVec);

uvTform_L = uvTform_H;

% Clamp
uvTform_L(1,:) = clamp(uvTform_L(1,:), pRad+1, imgW_L - pRad);
uvTform_L(2,:) = clamp(uvTform_L(2,:), pRad+1, imgH_L - pRad);
end

