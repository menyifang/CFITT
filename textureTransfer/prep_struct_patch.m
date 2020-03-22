function [wDistPatch] = prep_struct_patch(trgmask, trgPixPos, iLvl, optS)

% PREP_STRUCTURE_PATCH
% 
% Precompute patch weights and summation for patch matching and voting
% 
% Input:
%   - trgmask
%   - trgPixPos
%   - iLvl
%   - optS
% Output:
%   - wDistPatch

[imgH, imgW] = size(trgmask);

wDistPatch  = prep_target_patch(trgmask, trgPixPos, optS);
% wDistPatchC = bsxfun(@minus, wDistPatch, wDistPatch(optS.pMidPix,:));
% wDistPatchC  = optS.wDist(iLvl).^ (- wDistPatchC); 

numUvPix = size(wDistPatch, 2);

wDistImg = zeros(imgH, imgW, 'single');
indMap = reshape(1:imgH*imgW, imgH, imgW);
indPatch  = prep_target_patch(indMap, trgPixPos, optS);

for i = 1: numUvPix
    wDistImg(indPatch(:,i)) = wDistImg(indPatch(:,i)) + wDistPatch(optS.pMidPix,i);
end
 
end