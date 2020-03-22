function [costStruct] = patch_cost_struct(trgPatch, trgStructPatch, wStructPatch, optS)

% PATCH_COST_STRUCT
%
% Compute the weighted sum of the squared difference between
% cost between target-structure and target patches

% Input:
%   - trgPatch, trgStructPatch, optS
% Output:
%   - costApp


% Initialization
numUvValidPix = size(wStructPatch, 2);

patchStruct = trgPatch - trgStructPatch;

% vaild patch using structure guide
wStructPatch1 = reshape(wStructPatch, optS.pNumPix, 1, numUvValidPix);

% Sum of squared distance
if(strcmp(optS.costType, 'L1'))
    patchStruct = abs(patchStruct);
elseif(strcmp(optS.costType, 'L2'))
    patchStruct = patchStruct.^2;
end

% pick vaild structure points
patchStruct = bsxfun(@times, patchStruct, wStructPatch1);
patchStruct = sum(sum(patchStruct, 1),2);
patchStruct = reshape(patchStruct, 1, numUvValidPix);

% Weight normalization
sumStructWeight = sum(wStructPatch, 1);%1*N
costStruct = patchStruct./sumStructWeight;%1*N
costStruct(isnan(costStruct))=0;
end