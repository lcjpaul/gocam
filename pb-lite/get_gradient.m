function [ gradient ] = get_gradient(img,binvalues,masks)
%args:
%       img: single channel image of uint8
%       binvalues: an array of boundaries for each bin
%       masks: half-disc pairs of size n_orient x n_scales x 2
%output:
%       gradient: 3D matrix of size n x m x dim
%                 where n x m is the size of img
%                 dim is n_orient x n_scales
%
%
%hint:  when computing chi-sqr distance, you might want to
%       add 'eps' to the denominator to avoid dividing by zero
%       in MATLAB, eps = 2.2204e-16

maskSize = size(masks)
numMasks = maskSize(1) * maskSize(2);
masks = reshape(masks, 1, numMasks, 2);

numBins = numel(binvalues);
imgSize = size(img);
imgHeight = imgSize(1);
imgWidth = imgSize(2);

% Initialize cell array with matrices of all 0s
chiSqrDist = cell(1, numMasks);
for i=1:numMasks
    chiSqrDist{i} = zeros(imgHeight, imgWidth);
end

%loop over binvalues (and loop over each mask pair)
lastB = -1;
for binIndex=1:numBins
    b = binvalues(binIndex);

    %turn tmp into a binary matrix where 1's indicate the current binvalue
    tmp = img>lastB & img<=b; 
    tmp = single(tmp); %Convert to single for conv2
        
    for i=1:numMasks
        leftMask = masks{1, i, 1};
        rightMask = masks{1, i, 2};
        %leftMaskTmp = imfilter(tmp, leftMask);
        %rightMaskTmp = imfilter(tmp, rightMask);
        leftMaskTmp = conv2(tmp, leftMask, 'same');
        rightMaskTmp = conv2(tmp, rightMask, 'same');
        
        %Add chi-sqr for every pixel
        chiSqrDist{i} = chiSqrDist{i} + ...
            0.5 .* ( (leftMaskTmp - rightMaskTmp) .^ 2) ./ ...
            (leftMaskTmp + rightMaskTmp + eps);
    end
    lastB = b;
end

% Convert gradient back to 3d matrix
gradient = reshape(cell2mat(chiSqrDist), imgHeight, imgWidth, numMasks);
end

