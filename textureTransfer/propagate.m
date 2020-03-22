function [ NNF, nUpdateTotal ] = propagate( trgPatchPyr, srcimgPyr, trgSemPatchPyr, srcSemPyr, trgStructPatch, wStructPatch, wDistPatch, NNF, optS, indDirection, iLvl, iter, numIterLvl )
% PROPAGATE: update the nearest neighbor field using propagation

% Input:
%   - trgPatchPyr, trgsemPatchPyr, trgStructPatch
%   - srcimgPyr, srcsemPyr
%   - wDistPatch,wStructPatch: voting weight for patches
%   - NNF
%   - optS
%   - indDirection
%   - iLvl, iter, numIterLvl: adjust cost weights based on level and iteration
% Output:
%   - NNF, nUpdateTotal

numPSizeLvl = size( trgPatchPyr, 1 );
nUpdateTotal = 0;

% The positions of neighboring pixels
uvPixN = NNF.uvPixN{ indDirection };
uvPixActiveInd = true( 1, NNF.uvPix.numUvPix );
uvPixActiveInd = uvPixActiveInd & uvPixN.validInd;

numUpdatePix = NNF.uvPix.numUvPix;
while ( numUpdatePix ~= 0 )
    % Prepare uvPix, uvPixNCur
    uvPix.sub = NNF.uvPix.sub( :, uvPixActiveInd );uvPix.ind = NNF.uvPix.ind( :, uvPixActiveInd );
    uvPixNCur.sub = uvPixN.sub( :, uvPixActiveInd );uvPixNCur.ind = uvPixN.ind( :, uvPixActiveInd );
    trgPatchPyrCur = cell( numPSizeLvl, 1 );
    trgTextPatchPyrCur = cell( numPSizeLvl, 1 );
    for i = 1:numPSizeLvl
        trgPatchPyrCur{ i } = trgPatchPyr{ i }( :, :, uvPixActiveInd );
        trgTextPatchPyrCur{ i } = trgSemPatchPyr{ i }( :, :, uvPixActiveInd );
    end
    trgStructPatchCur = trgStructPatch( :, :, uvPixActiveInd );
    wDistPatchCur = wDistPatch( :, uvPixActiveInd );
    wStructPatchCur = wStructPatch( :, uvPixActiveInd );
    pSizeWeightCur = NNF.pSizeWeight.data( :, uvPixActiveInd );
    srcPosCur = NNF.uvTform.data( :, uvPixActiveInd );
    uvCostCur = NNF.uvCost.data( :, uvPixActiveInd );
    
    % Active pixel positions
    uvPixActivePos = find( uvPixActiveInd );
    
    % Get candidate uvTform candidates
    uvTformCand = uvMat_from_uvMap( NNF.uvTform.map, uvPixNCur );
    
        % Generate candidate transformation by propagation
    uvTformCand = trans_tform( uvTformCand, optS.propDir( :, indDirection ) );
    
        % Check if the nearest neighbors are valid source patches
    uvValidSrcInd = check_valid_uv( uvTformCand( 1:2, : ), NNF.validPix.mask );
    
        % Check if the nearest neighbors are already the same as the existing one
    diff = abs( uvTformCand - srcPosCur );
    uvValidDistInd = ( ( diff( 1, : ) > 1 ) | ( diff( 2, : ) > 1 ) | ( diff( 3, : ) > 0.05 ) );
    
        % Valid pixel indices
    uvValidInd = uvValidSrcInd & uvValidDistInd;
    
    numUvValid = sum( uvValidInd );
    
    if ( numUvValid ~= 0 )
        for i = 1:numPSizeLvl
            trgPatchPyrCur{ i } = trgPatchPyrCur{ i }( :, :, uvValidInd );
            trgTextPatchPyrCur{ i } = trgTextPatchPyrCur{ i }( :, :, uvValidInd );
        end
        
        trgStructPatchCur = trgStructPatchCur( :, :, uvValidInd );
        wDistPatchCur = wDistPatchCur( :, uvValidInd );
        wStructPatchCur = wStructPatchCur( :, uvValidInd );
        pSizeWeightCur = pSizeWeightCur( :, uvValidInd );
        uvTformCand = uvTformCand( :, uvValidInd );
        uvCostCur = uvCostCur( uvValidInd );
        
        uvPixUpdatePos = uvPixActivePos( uvValidInd );
        uvPixValid.sub = uvPix.sub( :, uvValidInd );
        uvPixValid.ind = uvPix.ind( uvValidInd );
       
        % Grab source patches
        srcPatchPyr = prep_source_patchPyr( srcimgPyr, uvTformCand, NNF.pSizeWeight.LvlInd, iLvl, optS );
        srcTextPatchPyr = prep_source_patchPyr( srcSemPyr, uvTformCand, NNF.pSizeWeight.LvlInd, iLvl, optS );
        
        for i = 1:numPSizeLvl
            srcTextPatchPyr{ i } = reshape( srcTextPatchPyr{ i }, optS.pNumPix, 1, size(uvTformCand,2) );
        end
        srcInd = sub2ind( size( NNF.validPix.mask ), round( uvTformCand( 2, : ) ), round( uvTformCand( 1, : ) ) );
        
        % Compute patch matching cost
        [ costPatchCandAll, uvBiasCand ] = patch_cost( trgPatchPyrCur, srcPatchPyr, trgTextPatchPyrCur, srcTextPatchPyr, trgStructPatchCur,  ...
            wStructPatchCur, wDistPatchCur, NNF.freq.map, srcInd, pSizeWeightCur, optS, iLvl, iter, numIterLvl );
        costPatchCand = sum( costPatchCandAll, 1 );
        if optS.lambdaRep ~= 0
            freqData = NNF.freq.map( : )';
            costRetCand = freqData( srcInd );
        else
            costRetCand = costPatchCandAll( 4, : );
        end
        
        % Check which one to update
        updateInd = costPatchCand < uvCostCur;
        uvPixUpdatePos = uvPixUpdatePos( updateInd );
        numUpdatePix = size( uvPixUpdatePos, 2 );
    else
        numUpdatePix = 0;
    end

    % Update NNF data
    if ( numUpdatePix ~= 0 )
        nUpdateTotal = nUpdateTotal + numUpdatePix;

        % === Update NNF data ===
        NNF.uvTform.data( :, uvPixUpdatePos ) = uvTformCand( :, updateInd );
        NNF.uvCost.data( uvPixUpdatePos ) = costPatchCand( updateInd );
        NNF.freqCost.data( uvPixUpdatePos ) = costRetCand( updateInd );
        
        % Apply bias correction
        if ( optS.useBiasCorrection )
            NNF.uvBias.data( :, uvPixUpdatePos ) = uvBiasCand( :, updateInd );
        end
        NNF.update.data( :, uvPixUpdatePos ) = 1;
        
        % Label as update by propagation
        NNF.uvPixUpdateSrc.data( uvPixUpdatePos ) = 3;
        
        % === Update NNF map ===
        NNF.uvTform.map = update_uvMap( NNF.uvTform.map, uvTformCand( :, updateInd ), uvPixValid, updateInd );
        NNF.uvCost.map = update_uvMap( NNF.uvCost.map, costPatchCand( updateInd ), uvPixValid, updateInd );
        NNF.freqCost.map = update_uvMap( NNF.freqCost.map, costRetCand( updateInd ), uvPixValid, updateInd );
        if ( optS.useBiasCorrection )
            NNF.uvBias.map = update_uvMap( NNF.uvBias.map, uvBiasCand( :, updateInd ), uvPixValid, updateInd );
        end
        NNF.update.map = update_uvMap( NNF.update.map, 1, uvPixValid, updateInd );
        NNF.uvPixUpdateSrc.map = update_uvMap( NNF.uvPixUpdateSrc.map, 3, uvPixValid, updateInd );       
        
        % === Update uvPixActiveInd ===
        uvPixNextSub = uvPixValid.sub( :, updateInd );
        uvPixNextSub( 1, : ) = uvPixNextSub( 1, : ) + optS.propDir( 1, indDirection );
        uvPixNextSub( 2, : ) = uvPixNextSub( 2, : ) + optS.propDir( 2, indDirection );
        uvPixNextInd = sub2ind( [ NNF.imgH, NNF.imgW ], uvPixNextSub( 2, : ), uvPixNextSub( 1, : ) );
        
        updateMap = NNF.uvPix.mask;
        updateMap( uvPixNextInd ) = 0;
        uvPixActiveInd = ~updateMap( NNF.uvPix.ind );
        uvPixActiveInd = uvPixActiveInd & uvPixN.validInd;
        
    end
end

[ NNF.freq, freqCost ] = get_NNF_freq( NNF );
NNF.freqCost = freqCost;

end


