function [costPatchCand, uvBiasCand] = ...
    patch_cost(trgPatchPyr, srcPatchPyr, trgSemPatchPyr, srcSemPatchPyr, trgStructPatch, wStructPatch,wDistPatchCur, ...
    freqMap, srcInd, pSizeweight, optS, iLvl, iter, numIterLvl)
% PATCH_COST
%
% compute the objective function 
%
% Input:
%   - trgPatchPyr, trgSemPatchPyr, trgStructPatch
%   - srcPatchPyr, srcSemPatchPyr
%   - wDistPatchCur: voting weight for patches
%   - NNF
%   - wDistPatch
%   - optS
%   - iLvl, numIterLvl: current level, current iteration
%   - lockAngleFlag: whether to use patch rotation
% Output:
%   - NNF
%   - trgimgPyr

pSizeweight = ones(size(pSizeweight));

numUvPix = size(wDistPatchCur, 2);
costPatchCand = zeros(4, numUvPix);

% Patch cost - texture, semantic
[costApp, uvBiasCand] = patch_cost_app(trgPatchPyr{1}, srcPatchPyr{1}, wDistPatchCur, optS, optS.useBiasCorrection);
costAppSem = patch_cost_app(trgSemPatchPyr{1}, srcSemPatchPyr{1}, wDistPatchCur, optS);

if optS.useMultiscale == true
    costApp = costApp .* pSizeweight(1,:);
    costAppSem = costAppSem .* pSizeweight(1,:);
    for i = 2:size(trgPatchPyr,1)
        [tmpcostApp, ~] = patch_cost_app(trgPatchPyr{i}, srcPatchPyr{i}, wDistPatchCur, optS, optS.useBiasCorrection, uvBiasCand);
        costApp = costApp + tmpcostApp.*pSizeweight(i,:);
        [tmpcostAppText, ~] = patch_cost_app(trgSemPatchPyr{i}, srcSemPatchPyr{i}, wDistPatchCur, optS);
        costAppSem = costAppSem + tmpcostAppText.*pSizeweight(i,:);
    end
    costApp = costApp./size(trgPatchPyr,1);
    costAppSem = costAppSem./size(trgPatchPyr,1);
end

% Patch cost - structure
costStruct = patch_cost_struct(trgPatchPyr{1}, trgStructPatch, wStructPatch,optS);

freqData = freqMap(:)';
costRep = freqData(srcInd);

% Weighted sum of the costs
costPatchCand(1,:) = costApp;
costPatchCand(2,:) = optS.lambdaText * costAppSem;
costPatchCand(3,:) = optS.lambdaStruct * costStruct;
costPatchCand(4,:) = optS.lambdaRep * costRep;

% Adaptive weighting for patch cost
% loose the penalty of character shape differences along with the iteration
costPatchCand(2,:) = (1-iter/numIterLvl)*costPatchCand(2,:);
% clamp distribution term
costPatchCand(3,:) = min(1, costPatchCand(3,:));
% normalize repetitiveness based on the size of S and T
% loose the penalty of repetitiveness as the distance to the text goes further
% costPatchCand(4,:) = optS.repCostRatio * costPatchCand(4,:) ./ max(1,abs(distweight));

end
