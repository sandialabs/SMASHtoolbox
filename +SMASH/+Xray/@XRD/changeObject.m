% CHANGEOBJECT - change object parameters that impact results
%
% This method changes basic object parameters that have an impact on the
% prediction and analysis. The method deletes relevant results upon making
% changes.
%
% Usage:
%   >> obj = changeObject(obj, category, subcategory, varargin)
%
% created May, 2023 by Nathan Brown (Sandia National Laboratories)
%
function obj = changeObject(obj, category, changeType, varargin)

if nargin < 4
    warning('Insufficient number of inputs. Nothing changed.')
    return
end

obj.simulation.current = false;
badInput = false;

switch lower(category)
    
    case 'crystal'
        switch lower(changeType)
            case 'location'
                
                newVal = varargin{1};
                opt = false; % true if translate source to maintain s0
                if numel(varargin) > 1
                    opt = varargin{2};
                end
                if isnumeric(newVal) && isequal(size(newVal), ...
                        [1, 3]) && ~any(isnan(newVal))
                    obj.crystal.location = newVal;
                    if opt
                        obj.source.location = newVal - obj.source.s0;
                    else
                        obj.source.s0 = newVal - obj.source.location;
                    end
                    newTBounds = ceil(0.2*vecnorm(obj.detector.location - ...
                        obj.crystal.location,2,2));
                    if newTBounds > 10
                        obj.calibration.searchBounds(1:3) = newTBounds;
                    end
                    obj = deletePredictionAndResults(obj);
                else
                    badInput = true;
                end
                
            case 'locationreference'
                
                newVal = varargin{1};
                if isnumeric(newVal) && isequal(size(newVal), ...
                        [1, 3]) && ~any(isnan(newVal))
                    obj.crystal.locationReference = newVal;
                else
                    badInput = true;
                end
                
            case 'orientation'
                
                if numel(varargin) == 1
                    newVal = varargin{1};
                    if isnumeric(newVal) && isequal(size(newVal), ...
                            [1, 3]) && ~any(isnan(newVal))

                        tVal = newVal - obj.crystal.orientation;
                        v = obj.crystal.vectors;

                        switch obj.crystal.orientationSystem
                            case 'xyz'
                                k_base = eye(3);
                            case 'abc'
                                k_base = v./vecnorm(v,2,2);
                        end

                        for ii = 1:3 % Rodrigues rotation
                            k = repmat(k_base(ii,:),3,1);
                            v = v*cosd(tVal(ii)) + ...
                                cross(k,v,2)*sind(tVal(ii)) + ...
                                k.*dot(k,v,2)*(1-cosd(tVal(ii)));
                        end
                        obj.crystal.vectors = v;
                        obj.crystal.orientation = newVal;
                        obj = deletePredictionAndResults(obj);
                    else
                        badInput = true;
                    end
                else % specified vector rotation
                    rotAngle = varargin{1};
                    rotVec = varargin{2};
                    if isnumeric(rotAngle) && isequal(size(rotAngle), ...
                            [1, 1]) && ~any(isnan(rotAngle)) && ...
                            isnumeric(rotVec) && isequal(...
                            size(rotVec), [1,3]) && ~any(isnan(rotVec))
                        k = repmat(rotVec/norm(rotVec),3,1);
                        v = obj.crystal.vectors;
                        obj.crystal.vectors = v*cosd(rotAngle) + ...
                            cross(k,v,2)*sind(rotAngle) + ...
                            k.*dot(k,v,2)*(1-cosd(rotAngle));
                        obj.crystal.orientation = [0 0 0];
                        obj.crystal.orientationReference = [0 0 0];
                        obj = deletePredictionAndResults(obj);
                    else
                        badInput = true;
                    end
                end

                
            case 'orientationreference'
                
                newVal = varargin{1};
                if isnumeric(newVal) && isequal(size(newVal), ...
                        [1, 3]) && ~any(isnan(newVal))
                    obj.crystal.orientationReference = newVal;
                else
                    badInput = true;
                end

            case 'orientationsystem'

                newVal = varargin{1};
                switch lower(newVal)
                    case 'xyz'
                        if ~strcmp(obj.crystal.orientationSystem, 'xyz')
                            obj.crystal.orientation = [0 0 0];
                            obj.crystal.orientationReference = [0 0 0];
                            obj.crystal.orientationSystem = 'xyz';
                        end
                    case 'abc'
                        if ~strcmp(obj.crystal.orientationSystem, 'abc')
                            obj.crystal.orientation = [0 0 0];
                            obj.crystal.orientationReference = [0 0 0];
                            obj.crystal.orientationSystem = 'abc';
                        end
                    otherwise
                        badInput = true;
                end
                
            case 'angles'
                
                newVal = varargin{1};
                if isnumeric(newVal) && isequal(size(newVal), ...
                        [1, 3]) && ~any(isnan(newVal))
                    obj.crystal.angles = newVal;
                    obj = generateUnitCell(obj);
                    obj = deletePredictionAndResults(obj);
                    obj.crystal.lengthsReference = obj.crystal.lengths;
                    obj.crystal.volumeRatio = 1;
                else
                    badInput = true;
                end
                
            case 'lengths' % input in angstrom
                
                newVal = varargin{1};
                if isnumeric(newVal) && isequal(size(newVal), ...
                        [1, 3]) && ~any(isnan(newVal))
                    obj.crystal.lengths = newVal;
                    obj.crystal.vectors = obj.crystal.lengths' .* ...
                        (obj.crystal.vectors./vecnorm(obj.crystal.vectors,2,2));
                    obj = computeVolumeAnddCalcs(obj);
                    obj = deletePredictionAndResults(obj);
                    obj.crystal.volumeRatio = prod(obj.crystal.lengths) / ...
                        prod(obj.crystal.lengthsReference);
                else
                    badInput = true;
                end

            case 'lengthsreference'

                newVal = varargin{1};
                if isnumeric(newVal) && isequal(size(newVal), ...
                        [1, 3]) && ~any(isnan(newVal))
                    obj.crystal.lengthsReference = newVal;
                    obj.crystal.volumeRatio = prod(obj.crystal.lengths) / ...
                        prod(obj.crystal.lengthsReference);
                else
                    badInput = true;
                end

            case 'volumeratio'

                newVal = varargin{1};
                if isnumeric(newVal) && isequal(size(newVal), ...
                        [1, 1]) && ~any(isnan(newVal)) && newVal > 0
                    obj = changeObject(obj, 'crystal', 'lengths', ...
                        newVal^(1/3) * obj.crystal.lengthsReference);
                else
                    badInput = true;
                end

            case 'elements'
                
                okflag = false;
                if nargin > 5
                    names = varargin{1};
                    locations = varargin{2};
                    occup = varargin{3};
                    if iscell(names) && iscell(locations) && ...
                            isnumeric(occup)
                        if numel(names) == numel(occup) && ...
                                numel(names) == numel(locations)
                            okflag = true;
                            for ii = 1:numel(names)
                                if ~ischar(names{ii}) || ...
                                        ~isnumeric(locations{ii}) || ...
                                        ~size(locations{ii}, 1) == 3
                                    okflag = false;
                                end
                            end
                        end
                    end
                end
                
                if okflag
                    obj.elementNames = names;
                    obj.elementLocations = locations;
                    obj.elementOccupancies = occup;
                    obj = deletePredictionAndResults(obj);
                else
                    warning(['Changing elements requires 3 inputs in', ...
                        ' the following order: names, locations, ', ...
                        'and occupancies. Inputted values must ', ...
                        'match outputs of readCIF.']);
                    badInput = true;
                end
                
            case 'cif'
                
                cifFile = varargin{1};
                
                try
                    obj = readCIF(obj, cifFile);
                    obj = deletePredictionAndResults(obj);
                catch
                    warning('Failed to read .cif file');
                end
                
            otherwise
                badInput = true;
        end
        
    case 'source'
        switch lower(changeType)

            case 's0'

                newVal = varargin{1};
                if isnumeric(newVal) && isequal(size(newVal), ...
                        [1, 3]) && ~any(isnan(newVal))
                    obj.source.s0 = newVal;
                    obj.source.location = obj.crystal.location - newVal;
                    obj.source.rotate = [0 0 0];
                    obj.source.rotateReference = obj.source.rotate;
                    obj = deletePredictionAndResults(obj);
                else
                    badInput = true;
                end

            case 'location'
                
                newVal = varargin{1};
                if isnumeric(newVal) && isequal(size(newVal), ...
                        [1, 3]) && ~any(isnan(newVal))
                    obj.source.location = newVal;
                    obj.source.s0 = obj.crystal.location - newVal;  
                    obj.source.rotate = [0 0 0];
                    obj.source.rotateReference = obj.source.rotate;
                    obj = deletePredictionAndResults(obj);
                else
                    badInput = true;
                end
                
            case 'locationreference'
                
                newVal = varargin{1};
                if isnumeric(newVal) && isequal(size(newVal), ...
                        [1, 3]) && ~any(isnan(newVal))
                    obj.source.locationReference = newVal;
                else
                    badInput = true;
                end
                
            case 'rotate'
                
                newVal = varargin{1};
                opt = false; % true if also rotating the detector
                rotVec = nan;
                if numel(varargin) > 1
                    opt = varargin{2};
                end
                if numel(varargin) > 2
                    rotVec = varargin{3};
                end
                if isnumeric(newVal) && (isequal(size(newVal), ...
                        [1, 3]) || numel(newVal)==1) && ~any(isnan(newVal))
                    
                    % rotate the source about the crystal location

                    vec = obj.source.location - obj.crystal.location;
                    if isnan(rotVec)
                        tVal = newVal - obj.source.rotate;
                        R = rotate(tVal);
                        newVec = vec*R;
                        obj.source.rotate = newVal;
                    else
                        rotAngle = newVal(1);
                        rotVec = rotVec(:)'/norm(rotVec);
                        newVec = vec*cosd(rotAngle) + ...
                            cross(rotVec,vec,2)*sind(rotAngle) + ...
                            rotVec.*dot(rotVec,vec,2)*(1-cosd(rotAngle));
                        obj.source.rotate = [0 0 0];
                    end
                    obj.source.location = obj.crystal.location + newVec;
                    obj.source.s0 = obj.crystal.location - obj.source.location;
                    
                    % rotate the detector about the crystal location
                    
                    if opt
                        
                        % perform rotation about the crystal center
                        
                        vec1 = obj.detector.location - ...
                            obj.crystal.location;
                        vec2 = obj.detector.planePoints(1,:) - ...
                            obj.crystal.location;
                        vec3 = obj.detector.planePoints(2,:) - ...
                            obj.crystal.location;
                        
                        if isnan(rotVec)
                            newVec1 = vec1*R;
                            newVec2 = vec2*R;
                            newVec3 = vec3*R;
                        else
                            newVec1 = vec1*cosd(rotAngle) + ...
                                cross(rotVec,vec1,2)*sind(rotAngle) + ...
                                rotVec.*dot(rotVec,vec1,2)*(1-cosd(rotAngle));
                            newVec2 = vec2*cosd(rotAngle) + ...
                                cross(rotVec,vec2,2)*sind(rotAngle) + ...
                                rotVec.*dot(rotVec,vec2,2)*(1-cosd(rotAngle));
                            newVec3 = vec3*cosd(rotAngle) + ...
                                cross(rotVec,vec3,2)*sind(rotAngle) + ...
                                rotVec.*dot(rotVec,vec3,2)*(1-cosd(rotAngle));
                        end
                        
                        obj.detector.location = obj.crystal.location + ...
                            newVec1;
                        obj.detector.planePoints = obj.crystal.location + ...
                            [newVec2; newVec3];
                        obj.detector.orientation = [0 0 0];
                        obj.detector.locationReference = [0 0 0];
                        obj.detector.orientationReference = [0 0 0];
                    end
                    
                    obj = deletePredictionAndResults(obj);
                else
                    badInput = true;
                end
                
            case 'lambda' % input in A
                
                newVal = varargin{1};
                if isnumeric(newVal) && isequal(size(newVal), ...
                        [1, 1])  && ~any(isnan(newVal))
                    startFlag = true;
                    obj.source.distributionDriver = 'lambda';
                    if isfield(obj.source, 'lambda')
                        oldVallam = obj.source.lambda;
                        startFlag = false;
                    end
                    obj.source.lambda = abs(newVal);
                    obj.source.E = obj.source.conversion / ...
                        obj.source.lambda;
                    if startFlag
                        return
                    end
                    if isnumeric(obj.source.lambdaDistribution) && ...
                        numel(obj.source.lambdaDistribution) >= 2
                        move = obj.source.lambda - oldVallam;
                        obj.source.lambdaDistribution(:,1) = ...
                            obj.source.lambdaDistribution(:,1) + move;
                        if numel(obj.source.lambdaDistribution) == 2
                            obj.source.EDistribution = ...
                                obj.source.conversion ./ ...
                                obj.source.lambdaDistribution(end:-1:1);
                        end
                    else
                        obj = changeObject(obj, 'source', ...
                            'lambdaDistribution', 0.01);
                    end
                    obj = deletePredictionAndResults(obj);
                else
                    badInput = true;
                end

            case 'lambdadistribution' % input in A

                [newVal, peakVal, badInput] = ...
                    distributionInput(varargin{1}, 'lambda');
                
                if ~badInput
                    obj.source.lambdaDistribution = newVal;
                    obj.source.distributionDriver = 'lambda';
                    obj.source.EDistribution = 'N/A';
                    if ~isnan(peakVal)
                        obj.source.lambda = peakVal;
                        obj.source.E = obj.source.conversion ./ ...
                            obj.source.lambda;
                    end
                    if isnumeric(newVal) && numel(newVal) == 2
                        obj.source.EDistribution = ...
                            obj.source.conversion ./ newVal(end:-1:1);
                    end
                    obj = deletePredictionAndResults(obj);
                end
                
            case 'e' % input in keV
                
                newVal = varargin{1};
                if isnumeric(newVal) && isequal(size(newVal), ...
                        [1, 1])  && ~any(isnan(newVal))
                    startFlag = true;
                    obj.source.distributionDriver = 'E';
                    if isfield(obj.source, 'E')
                        oldValE = obj.source.E;
                        startFlag = false;
                    end
                    obj.source.E = abs(newVal);
                    obj.source.lambda = obj.source.conversion / ...
                        obj.source.E;
                    if startFlag
                        return
                    end
                    if isnumeric(obj.source.EDistribution) && ...
                        numel(obj.source.EDistribution) >= 2
                        move = obj.source.E - oldValE;
                        obj.source.EDistribution(:,1) = ...
                            obj.source.EDistribution(:,1) + move;
                        if numel(obj.source.EDistribution) == 2
                            obj.source.lambdaDistribution = ...
                                obj.source.conversion ./ ...
                                obj.source.EDistribution(end:-1:1);
                        end
                    else
                        obj = changeObject(obj, 'source', ...
                            'EDistribution', 1);
                    end
                    obj = deletePredictionAndResults(obj);
                else
                    badInput = true;
                end

            case 'edistribution' % input in keV

                [newVal, peakVal, badInput] = ...
                    distributionInput(varargin{1}, 'e');
                
                if ~badInput
                    obj.source.EDistribution = newVal;
                    obj.source.distributionDriver = 'E';
                    obj.source.lambdaDistribution = 'N/A';
                    if ~isnan(peakVal)
                        obj.source.E = peakVal;
                        obj.source.lambda = obj.source.conversion ./ ...
                            obj.source.E;
                    end
                    if isnumeric(newVal) && numel(newVal) == 2
                        obj.source.lambdaDistribution = ...
                            obj.source.conversion ./ newVal(end:-1:1);
                    end
                    obj = deletePredictionAndResults(obj);
                end

            case 'polarizationfraction'
                
                newVal = varargin{1};
                if isnumeric(newVal) && isscalar(newVal) && ...
                        newVal >= 0 && newVal <= 1
                    obj.source.polarizationFraction = newVal;
                else
                    badInput = true;
                end
                
            case 'polarizationvector'

                newVal = varargin{1};
                if isnumeric(newVal) && numel(newVal) == 3 && ...
                        ~any(isnan(newVal(:)))
                    % decided not to check for orthogonality here - I do that in calculation
                    obj.source.polarizationVector = reshape(newVal, 1, 3);
                else
                    badInput = true;
                end

            otherwise
                badInput = true;
        end
        
    case 'detector'
        switch lower(changeType)
            case 'shape'
                           
                newVal = varargin{1};
                switch lower(newVal)
                    case 'rectangle'
                        obj.detector.shape = 'rectangle';
                    case 'circle'
                        obj.detector.shape = 'circle';
                    otherwise
                        badInput = true;
                end
                
            case 'location'
                
                newVal = varargin{1};
                if isnumeric(newVal) && isequal(size(newVal), ...
                        [1, 3]) && ~any(isnan(newVal))
                    
                    tVal = newVal - obj.detector.location;
                    
                    obj.detector.location = newVal;
                    obj.detector.planePoints = ...
                        obj.detector.planePoints + tVal;

                    newTBounds = ceil(0.2*vecnorm(obj.detector.location - ...
                        obj.crystal.location,2,2));
                    if newTBounds > 10
                        obj.calibration.searchBounds(1:3) = newTBounds;
                    end
                    
                    obj = deletePredictionAndResults(obj);
                else
                    badInput = true;
                end
                
            case 'locationreference'
                
                newVal = varargin{1};
                if isnumeric(newVal) && isequal(size(newVal), ...
                        [1, 3]) && ~any(isnan(newVal))
                    obj.detector.locationReference = newVal;
                else
                    badInput = true;
                end
                
            case 'orientation'
                
                newVal = varargin{1};
                if isnumeric(newVal) && isequal(size(newVal), ...
                        [1, 3]) && ~any(isnan(newVal))
                      
                    tVal = newVal - obj.detector.orientation;
                    R = rotate(tVal);
                    
                    % perform rotation about the center of the detector
                    
                    loc = obj.detector.location;
                    point1 = (obj.detector.planePoints(1,:) - loc)*R + ...
                        loc;
                    point2 = (obj.detector.planePoints(2,:) - loc)*R + ...
                        loc;
                    obj.detector.planePoints = [point1; point2];
                    
                    obj.detector.orientation = newVal;
                    obj = deletePredictionAndResults(obj);
                    
                else
                    badInput = true;
                end
                
            case 'orientationreference'
                
                newVal = varargin{1};
                if isnumeric(newVal) && isequal(size(newVal), ...
                        [1, 3]) && ~any(isnan(newVal))
                    obj.detector.orientationReference = newVal;
                else
                    badInput = true;
                end
                
            case 'size'
                
                newVal = varargin{1};
                if isnumeric(newVal) && isequal(size(newVal), ...
                        [1, 2]) && ~any(isnan(newVal))
                    
                    % make point 1 height/2 away from location and point 2
                    % width/2 away from location
                    
                    r = obj.detector.planePoints - obj.detector.location;
                    obj.detector.planePoints(1,:) = ...
                        obj.detector.location + (r(1,:)/norm(r(1,:))) * ...
                        newVal(1)/2;
                    obj.detector.planePoints(2,:) = ...
                        obj.detector.location + (r(2,:)/norm(r(2,:))) * ...
                        newVal(2)/2;
                    obj.detector.size = newVal;

                    % reset image grid in case it had simulation
                    % dimensions

                    im = obj.detector.image;
                    if ~isnumeric(im)
                        im = replaceGrid(im, 'Grid1', 1:numel(im.Grid1));
                        im = replaceGrid(im, 'Grid2', 1:numel(im.Grid2));
                        obj.detector.image = im;
                    end

                    % other resets
                    
                    obj = deleteSimulation(obj); % may change this later
                    obj = deletePredictionAndResults(obj);
                    obj = resetMatch(obj);
                else
                    badInput = true;
                end
                
            case 'facealpha'
                
                newVal = varargin{1};
                if isnumeric(newVal) && isequal(size(newVal), ...
                        [1, 1]) && ~any(isnan(newVal)) && newVal >= 0 ...
                        && newVal <= 1
                    obj.detector.faceAlpha = newVal;
                else
                    badInput = true;
                end
                
            case 'image'
                
                detectorImg = varargin{1};
                
                if isnumeric(detectorImg) && isscalar(detectorImg)
                    obj = deleteDetectorHistory(obj, 'detector', true);
                    return
                end
                         
                if ~isa(detectorImg, 'SMASH.ImageAnalysis.Image')
                    try
                        if isnumeric(detectorImg)
                            detectorImg = SMASH.ImageAnalysis.Image([], ... 
                                [], detectorImg);
                        else
                            detectorImg = SMASH.ImageAnalysis.Image(detectorImg);
                        end
                    catch
                        warning(['Failed to read detector image file. ', ...
                            'Debug by loading your image with ', ...
                            'SMASH.ImageAnalysis.Image']);
                        return
                    end
                    detectorImg = replace(detectorImg, 1e-6, ...
                        detectorImg.Data <= 0);
                    if ~isnumeric(obj.detector.image)
                        detectorImg.GraphicOptions.YDir = ...
                            obj.detector.image.GraphicOptions.YDir;
                        if strcmp(detectorImg.GraphicOptions.YDir, ...
                                'normal')
                            disp(['Maintained non-standard vertical ', ...
                                'axis of previous image']);
                        end
                    end
                end

                % force monotonically uniformly increasing grids, 
                % eliminate negative values, and eliminate nans

                detectorImg = makeGridNormal(detectorImg);
                detectorImg = makeGridUniform(detectorImg);
                minVal = min(detectorImg.Data(:));
                if minVal < 0
                    detectorImg = detectorImg - minVal;
                end
                detectorImg = replacenan(detectorImg);

                % change image settings and add to object

                detectorImg.DataLabel = 'Intensity';
                detectorImg.GraphicOptions.ColorMap = parula; % perceptually uniform
                detectorImg.GraphicOptions.AspectRatio = 'equal'; % square
                obj.detector.image = detectorImg;

                obj = deletePredictionAndResults(obj);
                
                % change detector size if requested
                
                obj = changeObject(obj, 'detector', 'shape', 'rectangle');
                conv = obj.detector.importUnitConversion;
                % total size is spacing between the pixels PLUS half
                % spaces between the outer pixels and the grid box wall
                if ischar(conv)
                    w = detectorImg.Grid1(end) - detectorImg.Grid1(1) + ...
                        detectorImg.Grid1(2) - detectorImg.Grid1(1);
                    h = detectorImg.Grid2(end) - detectorImg.Grid2(1) + ...
                        detectorImg.Grid2(2) - detectorImg.Grid2(1);
                    obj = changeObject(obj, 'detector', 'size', [h w]);
                elseif ~isnan(conv)
                    w = conv * numel(detectorImg.Grid1);
                    h = conv * numel(detectorImg.Grid2);
                    obj = changeObject(obj, 'detector', 'size', [h w]);
                end
                
                % fill in the image history
                
                obj = deleteDetectorHistory(obj, 'detector', false);
                obj.detector.imageHistory.original = obj.detector.image;
                obj.detector.imageHistory.lastsave = obj.detector.image;
                
                % update faceAlpha to 1 to avoid confusion
                
                obj.detector.faceAlpha = 1;

                % reset target image

                obj = deleteDetectorHistory(obj, 'target', true);

            case 'importunitconversion'
                
                newVal = varargin{1};
                if isnumeric(newVal) && numel(newVal) == 1
                    obj.detector.importUnitConversion = newVal;
                elseif ischar(newVal) && strcmpi(newVal(1), 'g')
                    obj.detector.importUnitConversion = 'grid';
                else
                    badInput = true;
                end

            otherwise
                badInput = true;
        end

    case 'calibration'
        switch lower(changeType)
            case 'type'

                obj.calibration = struct;
                newVal = varargin{1};
                switch lower(newVal)
                    case 'detectorauto'
                        obj.calibration.type = 'detectorAuto';
                    case 'detectormanual'
                        obj.calibration.type = 'detectorManual';
                    case 'crystal'
                        obj.calibration.type = 'crystal';
                    otherwise
                        badInput = true;
                end
                if ~badInput
                    obj = resetCalParams(obj);
                end

            case 'roi'

                newVal = varargin{1};
                if ~isempty(newVal) && isnumeric(newVal) && ...
                        size(newVal,2) == 2
                    obj.calibration.roi = newVal;
                else
                    badInput = true;
                end

            case 'cc'

                newVal = varargin{1};
                if isstruct(newVal) && isfield(newVal, 'PixelIdxList') ...
                        && ~isempty(newVal.PixelIdxList)
                    obj.calibration.cc = newVal;
                else
                    badInput = true;
                end

            case 'poi'

                newVal = varargin{1};
                if ~isempty(newVal) && isnumeric(newVal) && ...
                        size(newVal,2) == 2
                    obj.calibration.poi = newVal;
                else
                    badInput = true;
                end

            case 'searchbounds'

                newVal = varargin{1};
                if contains(obj.calibration.type, 'detector') && ...
                        isnumeric(newVal) && numel(newVal) == 6 && ...
                        all(isfinite(newVal))
                    obj.calibration.searchBounds = newVal(:)';
                elseif isnumeric(newVal) && numel(newVal) == 4 && ...
                        all(isfinite(newVal))
                    obj.calibration.searchBounds = newVal(:)';
                else
                    badInput = true;
                end

            case 'opts'

                badInput = true;
                if nargin > 4
                    newVal = varargin{2};
                    type = obj.calibration.type;
                    switch lower(varargin{1})
                        case 'threshold'
                            if contains(type, 'detector') && ...
                                    isnumeric(newVal) && isfinite(newVal)
                                obj.calibration.opts.threshold = newVal;
                                badInput = false;
                            end
                        case 'minregsize'
                            if contains(type, 'detector') && ...
                                    isnumeric(newVal) && ...
                                    numel(newVal) == 1 && isfinite(newVal)
                                obj.calibration.opts.minRegSize = newVal;
                                badInput = false;
                            end
                        case 'threshfrac'
                            if isnumeric(newVal) && numel(newVal) == 1 && ...
                                    isfinite(newVal)
                                obj.calibration.opts.threshFrac = newVal;
                                badInput = false;
                            end
                        case 'minpointdist'
                            if contains(type, 'detector') && ...
                                    isnumeric(newVal) && numel(newVal) == 1 && ...
                                    isfinite(newVal)
                                obj.calibration.opts.minPointDist = newVal;
                                badInput = false;
                            end
                        case 'maxpointnum'
                            if contains(type, 'detector') && ...
                                    isnumeric(newVal) && numel(newVal) == 1 && ...
                                    isfinite(newVal)
                                obj.calibration.opts.maxPointNum = ...
                                    round(newVal);
                                badInput = false;
                            end
                        case 'intcutoff'
                            if contains(type, 'detector') && ...
                                    isnumeric(newVal) && isscalar(newVal) & ...
                                    isfinite(newVal)
                                obj.calibration.opts.intCutoff = newVal;
                                badInput = false;
                            end
                        case 'thetaind'
                            if contains(type, 'detector') && ...
                                    (isnumeric(newVal) || ...
                                    isstring(newVal) || ...
                                    ischar(newVal))
                                obj.calibration.opts.thetaInd = newVal;
                                badInput = false;
                            end
                        case 'gapopulation'
                            if  isnumeric(newVal) && ...
                                    numel(newVal) == 1 && ...
                                    newVal >=1e1 && newVal <= 1e6
                                obj.calibration.opts.gaOpts.PopulationSize = ...
                                    round(newVal);
                                badInput = false;
                            end
                        case 'roiselect'
                            if ~contains(type, 'detector') && ...
                                    (isstring(newVal) || ...
                                    ischar(newVal))
                                newVal = lower(newVal);
                                if contains(newVal, 'auto')
                                    obj.calibration.opts.roiSelect = ...
                                        'auto';
                                    badInput = false;
                                elseif strcmp(newVal, 'manual')
                                    obj.calibration.opts.roiSelect = ...
                                        'manual';
                                    badInput = false;
                                end
                             end
                        case 'roinum'
                            if ~contains(type, 'detector') && ...
                                    isnumeric(newVal) && ...
                                    numel(newVal) == 1 && ...
                                    isfinite(newVal) && ...
                                    newVal >= 1
                                obj.calibration.opts.roiNum = round(newVal);
                                badInput = false;
                            end
                        case 'poitype'
                            if ~contains(type, 'detector') && ...
                                    (isstring(newVal) || ...
                                    ischar(newVal))
                                newVal = lower(newVal);
                                if contains(newVal, 'mean')
                                    obj.calibration.opts.poiType = ...
                                        'mean';
                                    badInput = false;
                                elseif contains(newVal, 'max')
                                    obj.calibration.opts.poiType = ...
                                        'max';
                                    badInput = false;
                                elseif contains(newVal, 'exact')
                                    obj.calibration.opts.poiType = ...
                                        'exact';
                                    badInput = false;
                                end
                            elseif contains(type, 'Manual') && ...
                                    (isstring(newVal) || ...
                                    ischar(newVal))
                                newVal = lower(newVal);
                                if contains(newVal, 'auto')
                                    obj.calibration.opts.poiType = ...
                                        'auto';
                                    badInput = false;
                                elseif contains(newVal, 'manual')
                                    obj.calibration.opts.poiType = ...
                                        'manual';
                                    badInput = false;
                                elseif contains(newVal, 'semiauto')
                                    obj.calibration.opts.poiType = ...
                                        'semiauto';
                                    badInput = false;
                                end
                            end
                        case 'gaopts'
                            if isa(newVal, 'optim.options.GaOptions') 
                                obj.calibration.opts.gaOpts = newVal;
                                badInput = false;
                            elseif (ischar(newVal) || isstring(newVal)) && ...
                                    contains(lower(newVal), 'def')
                                obj = setDefaultgaOpts(obj);
                                badInput = false;
                            end
                        case 'filterbounds'
                            if isnumeric(newVal) && numel(newVal) == 2 && ...
                                    ~contains(type, 'Manual')
                                newVal(newVal < 0) = 0;
                                newVal(newVal > 1) = 1;
                                obj.calibration.opts.filterBounds = ...
                                    sort(newVal, 'ascend');
                                badInput = false;
                            elseif (ischar(newVal) || isstring(newVal)) && ...
                                    contains(type, 'crystal')
                                obj.calibration.opts.filterBounds = 'none';
                                badInput = false;
                            end
                    end
                end


            otherwise
                badInput = true;
        end
        
    case 'prediction'
        switch lower(changeType)
            case 'type'
                
                newVal = varargin{1};
                
                switch lower(newVal)
                    case 'powder'
                        obj.prediction.type = 'powder';
                        obj = deletePredictionAndResults(obj, 'p');
                    case 'single-crystal'
                        obj.prediction.type = 'single-crystal';
                        obj = deletePredictionAndResults(obj, 'p');
                    otherwise
                        badInput = true;
                end
                
            case 'option'
                
                newVal = varargin{1};
                
                switch lower(newVal)
                    case 'default' % combined and on detector
                        obj.prediction.option = 'default';
                        obj = deletePredictionAndResults(obj, 'p');
                    case 'separate' % separate and on detector
                        obj.prediction.option = 'separate';
                        obj = deletePredictionAndResults(obj, 'p');
                    case 'all' % combined and all - even off detector
                        obj.prediction.option = 'all';
                        obj = deletePredictionAndResults(obj, 'p');
                    case 'allseparate' % separate and all - even off detector
                        obj.prediction.option = 'allseparate';
                        obj = deletePredictionAndResults(obj, 'p');
                    otherwise
                        badInput = true;
                end

            case 'combinationtolerance'

                newVal = varargin{1};
                if isnumeric(newVal) && isequal(size(newVal), ...
                        [1, 1]) && ~any(isnan(newVal))
                    obj.prediction.combinationTolerance = newVal;
                    obj = deletePredictionAndResults(obj, 'p');
                else
                    badInput = true;
                end
                
            case 'max_hkl'
                
                newVal = varargin{1};
                if isnumeric(newVal) && isequal(size(newVal), ...
                        [1, 1]) && ~any(isnan(newVal))
                    obj.prediction.max_hkl = newVal;
                    obj = deletePredictionAndResults(obj, 'p');
                else
                    badInput = true;
                end 
                
            case 'plotind'
                
                newVal = varargin{1};
                if isnumeric(newVal) && isequal(size(newVal), ...
                        size(obj.prediction.combined.m)) && ...
                        ~any(isnan(newVal))
                    obj.prediction.combined.plotInd = newVal;
                else
                    badInput = true;
                end 
                             
            otherwise
                badInput = true;
        end
        
    case 'results'

        obj = deletePredictionAndResults(obj, 'r');
        
        switch lower(changeType)
            
            case 'thetaresolution'
                
                newVal = varargin{1};
                if isnumeric(newVal) && newVal > 0 && newVal < 11
                    obj.results.thetaResolution = newVal;
                else
                    badInput = true;
                end

            case 'average'
                newVal = varargin{1};
                if islogical(newVal) && numel(newVal) == 1
                    obj.results.average = newVal;
                else
                    badInput = true;
                end

            case 'inverselorentz'
                newVal = varargin{1};
                if islogical(newVal) && numel(newVal) == 1
                    obj.results.inverseLorentz = newVal;
                else
                    badInput = true;
                end
                
            otherwise
                badInput = true;
        end

    case 'simulation'

        switch lower(changeType)

            case 'mosaicity'
                
                newVal = varargin{1};
                if isnumeric(newVal) && numel(newVal) < 4 && ...
                        ~any(isnan(newVal))
                    newVal = abs(newVal); % prevent negative and complex values
                    if numel(newVal) == 1
                        obj.simulation.mosaicity = repmat(newVal, [1, 3]);
                    elseif numel(newVal) == 3
                        obj.simulation.mosaicity = reshape(newVal, [1, 3]);
                    else
                        badInput = true;
                    end
                else
                    badInput = true;
                end

            case 'max_hkl'
                
                newVal = varargin{1};
                if isnumeric(newVal) && isequal(size(newVal), ...
                        [1, 1]) && newVal >= 1
                    obj.simulation.max_hkl = newVal;
                else
                    badInput = true;
                end

            case 'simulationsize'

                newVal = varargin{1};
                if isnumeric(newVal) && isequal(size(newVal), ...
                        [1 1]) && newVal > 1
                    obj.simulation.simulationSize = round(newVal);
                else
                    badInput = true;
                end

            case 'pixelnum'

                newVal = varargin{1};
                if isnumeric(newVal) && isequal(size(newVal), ...
                        [1 1]) && newVal >= 4 
                    obj.simulation.pixelNum = round(newVal);
                else
                    badInput = true;
                end

            case 'reportthreshold'

                newVal = varargin{1};
                if isnumeric(newVal) && isequal(size(newVal), ...
                        [1, 1]) && ~any(isnan(newVal))
                    obj.simulation.reportThreshold = newVal;
                else
                    badInput = true;
                end

            case 'mosaicitydistribution'

                newVal = varargin{1};
                if strcmpi(newVal, 'uniform')
                    obj.simulation.mosaicityDistribution = 'uniform';
                elseif strcmpi(newVal, 'normal')
                    obj.simulation.mosaicityDistribution = 'normal';
                else
                    badInput = true;
                end

            case 'mosaicitysystem'

                newVal = varargin{1};
                if strcmpi(newVal, 'abc') || strcmpi(newVal, 'crystal')
                    obj.simulation.mosaicitySystem = 'abc';
                elseif strcmpi(newVal, 'cs') || contains(lower(newVal), ...
                        'coord') || strcmpi(newVal, 'xyz')
                    obj.simulation.mosaicitySystem = 'xyz';
                else
                    badInput = true;
                end

            case 'uniformspotintensity'

                newVal = varargin{1};
                if islogical(newVal) && numel(newVal) == 1
                    obj.simulation.uniformSpotIntensity = newVal;
                else
                    badInput = true;
                end

            case 'normalizedspotintensity'

                newVal = varargin{1};
                if islogical(newVal) && numel(newVal) == 1
                    obj.simulation.normalizedSpotIntensity = newVal;
                else
                    badInput = true;
                end

            case 'beamdivergencedistribution'

                newVal = varargin{1};
                if strcmpi(newVal, 'uniform')
                    obj.simulation.beamDivergenceDistribution = 'uniform';
                elseif strcmpi(newVal, 'normal')
                    obj.simulation.beamDivergenceDistribution = 'normal';
                else
                    badInput = true;
                end

            case 'beamdivergencehalfangle'

                newVal = varargin{1};
                if isnumeric(newVal) && isequal(size(newVal), ...
                        [1, 1]) && newVal >= 0
                    obj.simulation.beamDivergenceHalfAngle = newVal;
                else
                    badInput = true;
                end

            case 'gaussianspreadhalfangle'

                newVal = varargin{1};
                if isnumeric(newVal) && isequal(size(newVal), ...
                        [1, 1]) && newVal >= 0
                    obj.simulation.gaussianSpreadHalfAngle = newVal;
                else
                    badInput = true;
                end

            case 'facealpha'

                newVal = varargin{1};
                if isnumeric(newVal) && isequal(size(newVal), ...
                        [1, 1]) && ~any(isnan(newVal)) && newVal >= 0 ...
                        && newVal <= 1
                    obj.simulation.faceAlpha = newVal;
                else
                    badInput = true;
                end

            case 'displayindennis'

                newVal = varargin{1};
                if islogical(newVal) || isnumeric(newVal)
                    obj.simulation.displayInDENNIS = newVal(1);
                else
                    badInput = true;
                end

            case 'displaylabelsindennis'

                newVal = varargin{1};
                if islogical(newVal) || isnumeric(newVal)
                    obj.simulation.displayLabelsInDENNIS = newVal(1);
                else
                    badInput = true;
                end

            case 'hkltype'

                newVal = varargin{1};
                if strcmpi(newVal, 'limited')
                    obj.simulation.hklType = 'limited';
                elseif strcmpi(newVal, 'all')
                    obj.simulation.hklType = 'all';
                else
                    badInput = true;
                end

            case 'datalim'

                newLim = varargin{1};
                if ~isnumeric(obj.simulation.image)
                    obj.simulation.image.DataLim = newLim;
                end

            case 'centroidthreshold'
                newVal = varargin{1};
                if isnumeric(newVal) && isscalar(newVal) && ...
                        newVal >= 0 && newVal < 1
                    obj.simulation.centroidThreshold = newVal;
                else
                    badInput = true;
                end

            otherwise
                badInput = true;
                
        end

    case 'match'
        
        if nargin < 5
            warning('Too few inputs for match')
            return
        end

        subCat = lower(varargin{1});
        newVal = varargin{2};
        switch lower(changeType)
            case 'centroids'
                switch subCat

                    case 'roiselect'
                        if  isstring(newVal) || ischar(newVal)
                            newVal = lower(newVal);
                            if contains(newVal, 'auto')
                                obj.match.centroids.roiSelect = 'auto';
                                badInput = false;
                            elseif strcmp(newVal, 'manual')
                                obj.match.centroids.roiSelect = 'manual';
                                badInput = false;
                            end
                        end

                    case 'roinum'
                        if isnumeric(newVal) && numel(newVal) == 1 && ...
                                isfinite(newVal) && newVal >= 1
                            obj.match.centroids.roiNum = round(newVal);
                            badInput = false;
                        end

                    case 'threshfrac'
                        if isnumeric(newVal) && numel(newVal) == 1 && ...
                                isfinite(newVal) && newVal <= 1 && ...
                                newVal >= 0
                            obj.match.centroids.threshFrac = newVal;
                            badInput = false;
                        end

                    case 'poitype'
                        if isstring(newVal) || ischar(newVal)
                            newVal = lower(newVal);
                            if contains(newVal, 'mean')
                                obj.match.centroids.poiType = 'mean';
                                badInput = false;
                            elseif contains(newVal, 'max')
                                obj.match.centroids.poiType = 'max';
                                badInput = false;
                            elseif contains(newVal, 'exact')
                                obj.match.centroids.poiType = 'exact';
                                badInput = false;
                            end
                        end

                    case 'filterbounds'
                        if isnumeric(newVal) && numel(newVal) == 2
                            newVal(newVal < 0) = 0;
                            newVal(newVal > 1) = 1;
                            obj.match.centroids.filterBounds = ...
                                sort(newVal, 'ascend');
                            badInput = false;
                        elseif ischar(newVal) || isstring(newVal)
                            obj.match.centroids.filterBounds = 'none';
                            badInput = false;
                        end

                    case 'orientationsearchbound'
                        if isnumeric(newVal) && (isscalar(newVal) || ...
                                numel(newVal) == 3)
                            if isscalar(newVal)
                                newVal = newVal*ones(1,3);
                            else
                                newVal = reshape(newVal, 1, 3);
                            end
                            newVal = abs(newVal);
                            newVal(newVal > 180) = 180;
                            obj.match.centroids.orientationSearchBound = newVal;
                        else
                            badInput = true;
                        end

                    case 'mosaicitysearchbound'
                        if isnumeric(newVal) && (isscalar(newVal) || ...
                                numel(newVal) == 3)
                            if isscalar(newVal)
                                newVal = newVal*ones(1,3);
                            else
                                newVal = reshape(newVal, 1, 3);
                            end
                            newVal = abs(newVal);
                            newVal(newVal > 180) = 180;
                            obj.match.centroids.mosaicitySearchBound = newVal;
                        else
                            badInput = true;
                        end

                    case 'gaopts'
                        if isa(newVal, 'optim.options.GaOptions')
                            obj.match.centroids.gaOpts = newVal;
                        else
                            badInput = true;
                        end

                    case 'scorefunction'
                        if isstruct(newVal) && isfield(newVal, 'name')
                            obj.match.centroids.scoreFunction = newVal;
                        else
                            badInput = true;
                        end

                    case 'solution'
                        if isstruct(newVal) && isfield(newVal, 'orientation') && ...
                                isfield(newVal, 'mosaicity') && ...
                                size(newVal.orientation,2) == 3 && ...
                                size(newVal.mosaicity,2) == 3 && ...
                                numel(newVal.mosaicity) == numel(newVal.orientation)
                            obj.match.centroids.solution = newVal;
                            n = size(newVal.orientation,1);
                            if ~isfield(newVal, 'image') || ...
                                    numel(newVal.image) ~= n || ...
                                    ~isa(newVal.image, ...
                                    'SMASH.ImageAnalysis.Image')
                                obj.match.centroids.solution.image = ...
                                    repmat(SMASH.ImageAnalysis.Image(...
                                    [],[],0), n, 1);
                            end
                            obj.match.centroids.solutionInfo = struct(...
                                'fval', nan(n,1), 'exitflag', nan(n,1), ...
                                'output', nan(n,1));
                        else
                            badInput = true;
                        end

                    otherwise
                        badInput = true;
                end
            case 'image'
                switch subCat

                    case 'orientationsearchbound'
                        if isnumeric(newVal) && (isscalar(newVal) || ...
                                numel(newVal) == 3)
                            if isscalar(newVal)
                                newVal = newVal*ones(1,3);
                            else
                                newVal = reshape(newVal, 1, 3);
                            end
                            newVal = abs(newVal);
                            newVal(newVal > 180) = 180;
                            obj.match.image.orientationSearchBound = newVal;
                        else
                            badInput = true;
                        end

                    case 'mosaicitysearchbound'
                        if isnumeric(newVal) && (isscalar(newVal) || ...
                                numel(newVal) == 3)
                            if isscalar(newVal)
                                newVal = newVal*ones(1,3);
                            else
                                newVal = reshape(newVal, 1, 3);
                            end
                            newVal = abs(newVal);
                            newVal(newVal > 180) = 180;
                            obj.match.image.mosaicitySearchBound = newVal;
                        else
                            badInput = true;
                        end

                    case 'gaussianspreadbound'
                        if isnumeric(newVal) && isscalar(newVal)
                            newVal = abs(newVal);
                            newVal(newVal > 180) = 180;
                            obj.match.image.gaussianSpreadBound = newVal;
                        else
                            badInput = true;
                        end

                    case 'volumeratiobound'
                        if isnumeric(newVal) && isscalar(newVal)
                            obj.match.image.volumeRatioBound = ...
                                abs(newVal);
                        else
                            badInput = true;
                        end

                    case 'minspotpixels'
                        if isnumeric(newVal) && isscalar(newVal) && ...
                                newVal < 1 && newVal >= 0
                            obj.match.image.minSpotPixels = newVal;
                        else
                            badInput = true;
                        end

                    case 'minccfiltersize'
                        if isnumeric(newVal) && isscalar(newVal) && ...
                                newVal < 1 && newVal >= 0
                            obj.match.image.minCCFilterSize = newVal;
                        else
                            badInput = true;
                        end

                    case 'intensitypercentile'
                        if isnumeric(newVal) && isscalar(newVal) && ...
                                newVal <= 1 && newVal >= 0
                            obj.match.image.intensityPercentile = newVal;
                        else
                            badInput = true;
                        end

                    case 'weightscheme'
                        if isstring(newVal) || ischar(newVal)
                            newVal = lower(newVal);
                            if contains(newVal, 'ranksqrt')
                                obj.match.image.weightScheme = 'ranksqrt';
                                badInput = false;
                            elseif contains(newVal, 'rank')
                                obj.match.image.weightScheme = 'rank';
                                badInput = false;
                            elseif contains(newVal, 'intensity')
                                obj.match.image.weightScheme = 'intensity';
                                badInput = false;
                            end
                        end

                    case 'overlapdistance'
                        if isnumeric(newVal) && isscalar(newVal) && ...
                                newVal < 1 && newVal >= 0
                            obj.match.image.overlapDistance = newVal;
                        else
                            badInput = true;
                        end

                    case 'gaopts'
                        if isa(newVal, 'optim.options.GaOptions')
                            obj.match.image.gaOpts = newVal;
                        else
                            badInput = true;
                        end

                    case 'scorefunction'
                        if isstruct(newVal) && isfield(newVal, 'name')
                            obj.match.image.scoreFunction = newVal;
                        else
                            badInput = true;
                        end
                end

            otherwise
                badInput = true;
        end

    case 'externaluserdata'
        
        obj.externalUserData.(changeType) = varargin{1}; % not necessary, just added in case user wants it
        
    otherwise
        badInput = true;
end

if badInput
    if ~contains(changeType, 'Reference', 'IgnoreCase', true)
        warning('Invalid input - no changes made');
    end
end

end

function R = rotate(xyzRot)

% assumes degrees and rotates in x, y, z order
% use like: new = old * R (where new and old are row vectors)

% this is slower than Rodrigues' formula, so I presently only use it for
% changeObject detector and source rotations where the speed difference is
% inconsequential

Rx = rotationMatrix(xyzRot(1), [1 0 0]);
Ry = rotationMatrix(xyzRot(2), [0 1 0]);
Rz = rotationMatrix(xyzRot(3), [0 0 1]);
R = Rx*Ry*Rz;

end

function [newVal, maxVal, badInput] = distributionInput(newVal, type)

% options:
% 1) single value for sigma in Gaussian distribution
% 2) probability density object
% 3) (not recommended) curve fit object
% 4) (not recommended) anonymous function
% 5) raw data in MATLAB variable to be linearly interpolated
% 6) raw data in Excel/CSV file to be linearly interpolated

maxVal = nan;
badInput = false;

if ischar(newVal)
    yr = version('-release');
    yr = str2double(yr(1:4));
    try
        if yr >= 2019
            newVal = readmatrix(newVal);
        else
            newVal = xlsread(newVal);
        end
    catch
        badInput = true;
    end
    if ~badInput
        badCol = all(isnan(newVal), 1);
        newVal(:,badCol) = [];
        badRow = all(isnan(newVal), 2);
        newVal(badRow, :) = [];
    end
end

if isnumeric(newVal)
    if numel(newVal) <= 2
        newVal = abs(newVal);
        if numel(newVal) == 2
            newVal = sort(reshape(newVal,2,[]));
        end
    elseif numel(newVal) > 2
        if size(newVal, 2) ~= 2
            newVal = newVal';
            if size(newVal, 2) ~= 2
                badInput = true;
            end
            newVal = sortrows(newVal);
        end
        if ~badInput && min(newVal(:,2)) > 0
            newVal(:,2) = newVal(:,2) - min(newVal(:,2));
            disp(['Removed non-zero baseline. Add zero point to data ' ...
                'to avoid removal.']);
        end
    end
elseif numel(newVal) ~= 1
    badInput = true;
elseif ~contains(class(newVal), 'prob') && ...
        ~contains(class(newVal), 'function') && ...
        ~contains(class(newVal), 'cfit')
    badInput = true;
end

if badInput
    warning(['Failed to read input. Distribution must be: ', ...
        '1) Two-element vector for range OR ', ...
        '2) sigma for Gaussian OR ', ...
        '3) two-column spectral scan data contained in MATLAB variable ', ...
        'or CSV/Excel file (first column is lambda or E and second ', ...
        'column is count) OR ', ...
        '4) probability density object OR ', ...
        '5) (not recommended) curve fit object OR ', ...
        '6) (not recommended) anonymous function']);
else
    if isnumeric(newVal)
        if numel(newVal) == 2
            maxVal = mean(newVal);
        elseif numel(newVal) > 2
            [~, maxInd] = max(newVal(:,2));
            maxVal = newVal(maxInd,1);
        end
    else
        switch lower(type)
            case 'lambda'
                b1 = 1e-6; b2 = 10;
            case 'e'
                b1 = 1e-6; b2 = 50;
        end
        x = linspace(b1, b2, 1e6);
        if contains(class(newVal), 'prob')
            [~, ind] = max(pdf(newVal,x)); % somehow no MATLAB function for this...
        else % not recommended and highly likely to fail throughout...
            warning(['Distribution type not recommended', ...
                ' - may generate unexpected results and cause', ...
                ' calibrations to fail']);
            y = newVal(x);
            badInd = y < 0;
            y(badInd) = [];
            x(badInd) = [];
            offset = min(y);
            y = y - offset;
            cumProb = cumtrapz(y); % no need for x b/c we normalize
            cumProb = cumProb/cumProb(end); % normalized CDF (hopefully...)
            [~, lowInd] = min(abs(cumProb-0.01));
            [~, highInd] = min(abs(cumProb-0.99));
            lowBound = x(lowInd);
            highBound = x(highInd);
            newVal = {newVal, offset, lowBound, highBound};
            [~, ind]  = max(y);
        end
        maxVal = x(ind);
        warning('Peak estimated via discrete method');
    end
end
end

function obj = resetCalParams(obj)

% common

obj.calibration.roi = [];
obj.calibration.cc = [];
obj.calibration.poi = [];

% specific

if contains(obj.calibration.type, 'detector')
    obj.calibration.processedImage = -1;
    obj.calibration.searchBounds = [10 10 10 1 1 1]; % Tx Ty Tz Rx Ry Rz
    newTBounds = ceil(0.2*vecnorm(obj.detector.location - ...
        obj.crystal.location,2,2));
    if newTBounds > obj.calibration.searchBounds(1)
        obj.calibration.searchBounds(1:3) = newTBounds;
    end
    obj.calibration.opts = struct('threshold', 9000, ...
        'minRegSize', 1000, ...
        'threshFrac', 0.5, ...
        'minPointDist', 20, ...
        'maxPointNum', 100, ...
        'intCutoff', 0.7, ...
        'thetaInd', 'first', ...
        'filterBounds', [1/100 1/10], ...
        'poiType', 'auto');
    if contains(obj.calibration.type, 'Manual')
        obj.calibration = rmfield(obj.calibration,'roi');
        obj.calibration.opts = rmfield(obj.calibration.opts,'filterBounds');
    end
elseif contains(obj.calibration.type, 'crystal')
    obj.calibration.searchBounds = [180 180 180 0]; % R1 R2 R3 vol%
    obj.calibration.opts = struct('roiSelect', 'auto', ...
        'roiNum', 5, ...
        'threshFrac', 0.25, ...
        'poiType', 'mean', ...
        'filterBounds', 'none');
end

obj = setDefaultgaOpts(obj);

end

function obj = setDefaultgaOpts(obj)

if ~license('test', 'GADS_Toolbox')
    obj.calibration.opts.gaOpts = 'Missing Toolbox';
    return
end

% apply options with pre-2021 syntax just in case (may have to change later
% if MATLAB stops supporting it)

if contains(obj.calibration.type, 'detector')

    obj.calibration.opts.gaOpts = optimoptions('ga', 'Display', 'none', ...
        'PlotFcn', @xrdgaplot, ...
        'UseVectorized', true, ...
        'FunctionTolerance',1e-3, ...
        'MaxStallGenerations',10, ...
        'PopulationSize',500, ...
        'MutationFcn','mutationadaptfeasible', ...
        'CrossoverFcn',{@crossoverintermediate, 1}, ...
        'CrossoverFraction',0.8);

elseif contains(obj.calibration.type, 'crystal')

    obj.calibration.opts.gaOpts = optimoptions('ga', 'Display','none', ...
        'PlotFcn', @xrdgaplot, 'UseVectorized',true, ...
        'FunctionTolerance',1e-3, 'MaxStallGenerations', 10, ...
        'PopulationSize', 1e4, ...
        'MutationFcn', 'mutationadaptfeasible', ...
        'CrossoverFcn', {@crossoverintermediate, 1}, ...
        'CrossoverFraction',0.5);

end

end

function state = xrdgaplot(options, state, flag)

if(strcmp(flag,'init')) % Set up the plot
    movegui(gcf, 'center');
    xlim([0, 10]);
    hold on;
    xlabel('Generation')
    ylabel('Min Objective Function Value') 
    title('Genetic Algorithm')
    set(gca, 'fontsize', 12);
    grid on
end

best = min(state.Score); % Best score in the current generation
plot(state.Generation, best, 'r.', 'markersize', 25);
if state.Generation > 10
    xlim([0 state.Generation])
end

end