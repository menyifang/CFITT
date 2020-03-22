function [srcmask,color_top] = salient_label(srcsem,structMask)
% SALIENT_LABEL
%     recommand the label with salient structure
semantic = srcsem;
srcmask = zeros(size(structMask));
color_top = -1;
if ~all(structMask(:)==0)
    semantic(~structMask) = -1;
    label = tabulate(semantic(:));
    label = sortrows(label,3,'descend');
    color_top = label(2,1);
    if label(1,1)==-1
        tmp = (srcsem==color_top);
        srcmask(tmp) = 1;
    end
end

end


