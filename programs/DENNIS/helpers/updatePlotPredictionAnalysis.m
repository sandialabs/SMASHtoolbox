function updatePlotPredictionAnalysis(mainFigure, varargin)

%% main

obj = get(mainFigure, 'UserData');
ax = get(mainFigure, 'CurrentAxes');

if nargin < 2 % do everything
    updateEverything;
else % only update specific things
    switch varargin{1}
        case 'crystal'
            updateEverything(false);
        case 'source'
            updateEverything(false);
        case 'detector'
            updateEverything(false);
        case 'predictionDisplay'
            printPrediction;
            plotPrediction;
            updateAnalysis(false);
        case 'predictionTable'
            printPrediction;
            updateAnalysis(false);
        case 'predictionPlot'
            plotPrediction;
            updateAnalysis(false);
        case 'results'
            updateAnalysis;
        case 'imageProcessingDisplay'
            updateImageProcessing;
            plotDetector;
            updateAnalysis;
    end
end

set(mainFigure, 'UserData', obj);

%% nested helper functions

% update everything

    function updateEverything(varargin)
        
        % plot crystal, source, and detector first b/c these are easy
        
        plotCrystal;
        plotXray;
        plotDetector;
        
        % generate prediction and indices and check limits
        
        obj = generatePrediction(obj);
        if isfield(obj.externalUserData,'checkedInd') && ...
                isfield(obj.externalUserData, 'displayInd') && ...
                ~isempty(obj.externalUserData.checkedInd)
            showInd = obj.externalUserData.checkedInd & [true; ...
                obj.externalUserData.displayInd];
        else
            showInd = true;
        end
        if ~any(showInd)
            obj.externalUserData.checkedInd = false(1+size(obj.prediction.I, ...
                1), 1);
        else
            obj.externalUserData.checkedInd = true(1+size(obj.prediction.I, ...
                1), 1);
        end
        obj.externalUserData.clickedInd = false(numel(obj.prediction.I),1);
        
        badLims = true;
        if isfield(obj.externalUserData, 'min_I_show') && ...
                isfield(obj.externalUserData, 'max_hkl_show')
            minI = obj.externalUserData.min_I_show;
            maxhkl = obj.externalUserData.max_hkl_show;
            if isnumeric(minI) && isnumeric(maxhkl)
                if minI >= 1e-6 && maxhkl >= 0 && maxhkl <= ...
                        obj.prediction.max_hkl
                    badLims = false;
                end
            end
        end
        if badLims
            obj.externalUserData.min_I_show = 1e-6;
            obj.externalUserData.max_hkl_show = obj.prediction.max_hkl;
        end
        
        minI = obj.externalUserData.min_I_show;
        maxhkl = obj.externalUserData.max_hkl_show;
        I = obj.prediction.I;
        hkl = obj.prediction.hkl;
        displayInd = I >= minI & all(hkl <= maxhkl, 2);
        
        obj.externalUserData.displayInd = displayInd;

        plotPrediction;

        if nargin < 1 || varargin{1}
            printPrediction
            updateAnalysis;
            updateImageProcessing;
        end

        % put detector in background

        ch = get(ax, 'Children');
        ind = contains(get(ch(:), 'Type'), 'surface');
        ch = [ch(~ind); ch(ind)];
        set(ax, 'Children', ch);

        % prevent intensity bar from randomly popping up

        delete(findobj(ancestor(ax,'figure'), 'type', 'colorbar'))
        
    end

% plot crystal

    function plotCrystal
        
        % delete existing plot
        handleName = 'crystalPlot';
        if isappdata(mainFigure, handleName)
            delete(getappdata(mainFigure, handleName));
        end
        
        % plot lattice
        
        x = repmat(obj.crystal.location(1), 3, 1);
        y = repmat(obj.crystal.location(2), 3, 1);
        z = repmat(obj.crystal.location(3), 3, 1);
        u = obj.crystal.vectors(:,1);
        v = obj.crystal.vectors(:,2);
        w = obj.crystal.vectors(:,3);
        
        normFac = 0.1*max([norm(u), norm(v), norm(w)]);
        u = u/normFac;
        v = v/normFac;
        w = w/normFac;
        
        hq = quiver3(ax, x, y, z, u, v, w, 'AutoScale', 'off', ...
            'Color', 'k');
        
        % label lattice
        
        offset = 1.1;
        u = u*offset;
        v = v*offset;
        w = w*offset;
        
        ha = text(ax, x(1) + u(1), y(1) + v(1) , ...
            z(1) + w(1), 'a', 'HorizontalAlignment', 'center');
        hb = text(ax, x(2) + u(2), y(2) + v(2), ...
            z(2) + w(2), 'b', 'HorizontalAlignment', 'center');
        hc = text(ax, x(3) + u(3), y(3) + v(3), ...
            z(3) + w(3), 'c', 'HorizontalAlignment', 'center');
        hcrystal = text(ax, x(1) + u(1)/offset/2, y(2) + v(2)/offset/2, ...
            z(3) + w(3)/offset/2, ...
            '', 'HorizontalAlignment', 'center');
        
        % save plot handles for future deletion
        
        setappdata(mainFigure, handleName, [hq, ha, hb, hc, hcrystal]);
        
        % check that crystalDlg exists and is valid
        
        badFlag = true;
        if isappdata(mainFigure, 'crystalDlg')
            db = getappdata(mainFigure, 'crystalDlg');
            if isvalid(db)
                if ishandle(db.Figure)
                    badFlag = false;
                end
            end
        end
        if badFlag
            return
        end
        
        % print lattice data to dlg
        
        db = db.Figure;
        set(findobj(db, 'Tag', 'a'), 'Value', ...
            num2str(obj.crystal.lengths(1)));
        set(findobj(db, 'Tag', 'b'), 'Value', ...
            num2str(obj.crystal.lengths(2)));
        set(findobj(db, 'Tag', 'c'), 'Value', ...
            num2str(obj.crystal.lengths(3)));
        set(findobj(db, 'Tag', 'alpha'), 'Value', ...
            num2str(obj.crystal.angles(1)));
        set(findobj(db, 'Tag', 'beta'), 'Value', ...
            num2str(obj.crystal.angles(2)));
        set(findobj(db, 'Tag', 'gamma'), 'Value', ...
            num2str(obj.crystal.angles(3)));
        
    end

% plot x-ray source

    function plotXray
        
        % delete existing plot
        
        handleName = 'sourcePlot';
        if isappdata(mainFigure, handleName)
            delete(getappdata(mainFigure, handleName));
        end
        
        [x, y, z] = sphere;
        r = 1;
        x = x*r + obj.source.location(1);
        y = y*r + obj.source.location(2);
        z = z*r + obj.source.location(3);
        
        green = [0 150 0]/255;
        C(:,:,1) = ones(size(z))*green(1);
        C(:,:,2) = ones(size(z))*green(2);
        C(:,:,3) = ones(size(z))*green(3);
        hs = surf(ax, x, y, z, C, 'EdgeColor', 'none');
        
        offset = 0.2 ;
        z = (1+offset)*max(z, [], 'all') - offset*min(z, [], 'all');
        x = obj.source.location(1);
        y = obj.source.location(2);
        hst = text(ax, x, y, z, '', 'HorizontalAlignment', ...
            'center');
        
        hs0 = quiver3(ax, obj.source.location(1), ...
            obj.source.location(2), obj.source.location(3), ...
            obj.source.s0(1), obj.source.s0(2), obj.source.s0(3), ...
            'AutoScale', 'off', 'Color', 'r', 'LineWidth', 1);
        
        % save plot handles for future deletion
        
        setappdata(mainFigure, handleName, [hs, hst, hs0]);
        
        % check that sourceDlg exists and is valid

        badFlag = true;
        db = getappdata(mainFigure, 'sourceDlg');
        if ~isempty(db) && isvalid(db)
            if ishandle(db.Figure)
                badFlag = false;
            end
        end
        if badFlag
            return
        end

        % print source data to dlg
        
        db = db.Figure;
        set(findobj(db, 'Tag', 'xPos'), 'Value', ...
            num2str(obj.source.location(1)));
        set(findobj(db, 'Tag', 'yPos'), 'Value', ...
            num2str(obj.source.location(2)));
        set(findobj(db, 'Tag', 'zPos'), 'Value', ...
            num2str(obj.source.location(3)));
        set(findobj(db, 'Tag', 'xRot'), 'Value', ...
            num2str(obj.source.rotate(1)));
        set(findobj(db, 'Tag', 'yRot'), 'Value', ...
            num2str(obj.source.rotate(2)));
        set(findobj(db, 'Tag', 'zRot'), 'Value', ...
            num2str(obj.source.rotate(3)));
        set(findobj(db, 'Tag', 'xs0'), 'Value', ...
            num2str(obj.source.s0(1)));
        set(findobj(db, 'Tag', 'ys0'), 'Value', ...
            num2str(obj.source.s0(2)));
        set(findobj(db, 'Tag', 'zs0'), 'Value', ...
            num2str(obj.source.s0(3)));
        set(findobj(db, 'Tag', 'lambda'), 'Value', ...
            num2str(num2str(obj.source.lambda)));
        set(findobj(db, 'Tag', 'E'), 'Value', ...
            num2str(num2str(obj.source.E)));

        h_2 = findobj(db, 'Tag', 'lambdaDistribution');
        h_4 = findobj(db, 'Tag', 'EDistribution');
        if numel(obj.source.lambdaDistribution) == 1 || ...
                numel(obj.source.EDistribution) == 1
            set(h_2, 'Value', num2str(obj.source.lambdaDistribution));
            set(h_4, 'Value', num2str(obj.source.EDistribution));
        elseif numel(obj.source.lambdaDistribution) == 2
            lambdaStr = [num2str(obj.source.lambdaDistribution(1)), ...
                ' - ', num2str(obj.source.lambdaDistribution(2))];
            EStr = [num2str(obj.source.EDistribution(1)), ...
                ' - ', num2str(obj.source.EDistribution(2))];
            set(h_2, 'Value', lambdaStr);
            set(h_4, 'Value', EStr);
        else
            set(h_2, 'Value', 'File/Var');
            set(h_4, 'Value', 'File/Var');
            if strcmp(obj.source.distributionDriver(1), 'E')
                set(h_2, 'Value', 'N/A');
            else
                set(h_4, 'Value', 'N/A');
            end
        end
        
    end

% plot detector

    function plotDetector
        
        % delete existing plot
        
        handleName = 'detectorPlot';
        if isappdata(mainFigure, handleName)
            delete(getappdata(mainFigure, handleName));
        end
        
        % pull out plane vectors
        
        pt = obj.detector.planePoints;
        loc = obj.detector.location;
        a = pt(1,:) - loc;
        b = pt(2,:) - loc;
            
        % create detector points
        
        switch obj.detector.shape
            case 'rectangle'
                corners = [loc + a + b; ...
                    loc + a - b;
                    loc - a - b; ...
                    loc - a + b];
            case 'circle'
                radius = norm(a);
                a = a/radius;
                b = b/norm(b);
                pointNum = 100;
                phi = linspace(0, 2*pi*(1-1/pointNum), pointNum)';
                corners = radius*(a.*cos(phi) + b.*sin(phi)) + loc;
        end
        
        x = corners(:,1);
        y = corners(:,2);
        z = corners(:,3);
        
        % plot detector/simulation
    
        hl = gobjects(0,1);
        if isnumeric(obj.detector.image) && ...
                (isnumeric(obj.simulation.image) || ...
                ~obj.simulation.displayInDENNIS) % no image
            c = 204*ones(1,3)/255;
            hd = patch(ax, x, y, z, c, ...
                'facealpha', obj.detector.faceAlpha, ...
                'edgecolor', 'none');
        elseif ~isnumeric(obj.simulation.image) && ...
                obj.simulation.displayInDENNIS
            so = [3 4 2 1]; % matches smash image but flips z in plot
            xs = [x(so(1)), x(so(2)); x(so(3)), x(so(4))];
            ys = [y(so(1)), y(so(2)); y(so(3)), y(so(4))];
            zs = [z(so(1)), z(so(2)); z(so(3)), z(so(4))];
            cdata = obj.simulation.image.Data;
            hd = surf(ax, xs, ys, zs, 'CData', cdata, ...
                'facecolor', 'texturemap', 'edgecolor', 'none', ...
                'facealpha', obj.simulation.faceAlpha);
            if isfield(obj.externalUserData, 'simLim') && ...
                    isnumeric(obj.externalUserData.simLim)
                cdataLims = obj.externalUserData.simLim;
            else
                if ischar(obj.simulation.image.DataLim)
                    cdataLims = [min(min(cdata)) max(max(cdata))];
                    if cdataLims(2) == cdataLims(1)
                        cdataLims(2) = cdataLims(1) + 1;
                    end
                else
                    cdataLims = obj.simulation.image.DataLim;
                end
            end
            obj.externalUserData.simLim = cdataLims;
            caxis(ax, cdataLims);
            if obj.simulation.displayLabelsInDENNIS && ...
                    ~isempty(obj.simulation.xy)
                xvec = b/norm(b);
                yvec = a/norm(a);
                coord = loc + obj.simulation.xy(:,1).*xvec + ...
                    obj.simulation.xy(:,2).*yvec;
                hl = text(ax, coord(:,1),coord(:,2),coord(:,3), ...
                    cellstr(num2str(obj.simulation.hkl)), ...
                    'fontsize', 14, 'Color', 'w');
            end
        else
            % so = [2 1 3 4]; % flips z rel to smash image but plots the same
            so = [3 4 2 1]; % matches smash image but flips z in plot
            xs = [x(so(1)), x(so(2)); x(so(3)), x(so(4))];
            ys = [y(so(1)), y(so(2)); y(so(3)), y(so(4))];
            zs = [z(so(1)), z(so(2)); z(so(3)), z(so(4))];
            cdata = obj.detector.image.Data;
            hd = surf(ax, xs, ys, zs, 'CData', cdata, ...
                'facecolor', 'texturemap', 'edgecolor', 'none', ...
                'facealpha', obj.detector.faceAlpha);
            if ischar(obj.detector.image.DataLim)
                cdataLims = [min(min(cdata)) max(max(cdata))];
                if cdataLims(2) == cdataLims(1)
                    cdataLims(2) = cdataLims(1) + 1;
                end
            else
                cdataLims = obj.detector.image.DataLim;
            end
            caxis(ax, cdataLims);
        end

        delete(findobj('type','colorbar')); % sometimes pops up for some reason
        
        % label detector
        
        offset = 0.05;
        [z, indZ] = sort(z, 'descend');
        z = (1+offset)*z(1) - offset*z(end);
        x = x(indZ);
        y = y(indZ);
        x = mean(x(1:2));
        y = mean(y(1:2));
        
        hdt = text(ax, x, y, z, '', 'HorizontalAlignment', ...
            'center');
        
        % save plot handles for future deletion
        
        setappdata(mainFigure, handleName, [hd; hdt; hl]);

        % check that simulationDlg exists and is valid
        
        badFlag = true;
        db = getappdata(mainFigure, 'simulationDlg');
        if ~isempty(db) && isvalid(db)
            if ishandle(db.Figure)
                badFlag = false;
            end
        end
        if ~badFlag
            db = db.Figure;
            set(findobj(db, 'Tag', 'image'), ...
                'Value', obj.simulation.displayInDENNIS);
            set(findobj(db, 'Tag', 'current'), ...
                'Value', obj.simulation.current);
            if ~isnumeric(obj.simulation.image) && ...
                    obj.simulation.displayInDENNIS
                if ischar(obj.simulation.image.DataLim)
                    cdataLims = caxis(ax);
                else
                    cdataLims = obj.simulation.image.DataLim;
                end
                set(findobj(db, 'Tag', 'lim1'), ...
                    'Value', num2str(cdataLims(1)));
                set(findobj(db, 'Tag', 'lim2'), ...
                    'Value', num2str(cdataLims(2)));
            else
                set(findobj(db, 'Tag', 'lim1'), ...
                    'Value', '');
                set(findobj(db, 'Tag', 'lim2'), ...
                    'Value', '');
            end
        end
        
    end

% plot prediction

    function plotPrediction
        
        % delete existing plot
        
        handleName = 'predictionPlot';
        if isappdata(mainFigure, handleName)
            delete(getappdata(mainFigure, handleName));
        end

        % plot straight-thru

        col = [255 0 255]/255;
        spotLoc = obj.prediction.straightThruLocation;
        hst = plot3(ax, spotLoc(:,1), spotLoc(:,2), ...
            spotLoc(:,3), 'MarkerEdgeColor', col, ...
            'Marker', 'x', 'MarkerFaceColor', col, ...
            'MarkerSize', 10, 'LineWidth', 2);
        
        % check that there's something to plot
        
        if isempty(obj.prediction.spotLocations)
            setappdata(mainFigure, handleName, hst);
            return
        end
        
        % plot spots or rings
        
        spotLoc = obj.prediction.spotLocations;
        
        checkedInd = obj.externalUserData.checkedInd;
        displayInd = obj.externalUserData.displayInd;
        clickedInd = obj.externalUserData.clickedInd;
        plotInd = checkedInd(2:end) & displayInd & ~clickedInd;
        hiInd = displayInd & clickedInd;
        
        spotLocReg = spotLoc(plotInd,:,:);
        spotLocHi = spotLoc(hiInd,:,:);
        
        highCol = [255 255 0]/255;
        switch obj.prediction.type
            case 'single-crystal'
                
                % regular

                hs = plot3(ax, spotLocReg(:,1), spotLocReg(:,2), ...
                    spotLocReg(:,3), 'r*');
                
                % highlighted

                hs_hi = plot3(ax, spotLocHi(:,1), spotLocHi(:,2), ...
                    spotLocHi(:,3), 'color', highCol, 'marker', '*');

                
            case 'powder'
                
                % regular

                if any(plotInd)
                    hs = plot3(ax, permute(spotLocReg(:,1,:), [3 1 2]), ...
                        permute(spotLocReg(:,2,:), [3 1 2]), ...
                        permute(spotLocReg(:,3,:), [3 1 2]), 'r-');
                    if ~isnumeric(obj.detector.image)
                        set(hs, 'LineWidth', 2);
                    end
                else
                    hs = gobjects(0,1);
                end

                % highlighted

                if any(hiInd)
                    hs_hi = plot3(ax, permute(spotLocHi(:,1,:), [3 1 2]), ...
                        permute(spotLocHi(:,2,:), [3 1 2]), ...
                        permute(spotLocHi(:,3,:), [3 1 2]), ...
                        'color', highCol, 'linestyle', '-');
                    set(hs_hi, 'linewidth', 2)
                else
                    hs_hi = gobjects(0,1);
                end
                
        end
        
        % save plot handles for future deletion
        
        setappdata(mainFigure, handleName, [hst; hs; hs_hi])
        
    end

% print prediction

    function printPrediction
        
        % check that predictionDlg exists and is valid
        
        badFlag = true;
        db = getappdata(mainFigure, 'predictionDlg');
        if ~isempty(db) && isvalid(db)
            if ishandle(db.Figure)
                badFlag = false;
            end
        end
        if badFlag
            return
        end
        
        % populate the table
        
        db = db.Figure;
        tb = findobj(db, 'type', 'uitable');
        
        if ~isempty(obj.prediction.twoTheta)
            
            % extract data from object
            
            hkl = obj.prediction.hkl;
            lambdaSol = obj.prediction.lambdaSol;
            m = obj.prediction.m;
            twoTheta = obj.prediction.twoTheta;
            I = obj.prediction.I;
            
            displayInd = obj.externalUserData.displayInd;
            checkedInd = obj.externalUserData.checkedInd;
            checkedInd_table = checkedInd([true; displayInd]);
            
            % populate table
            
            hkl = cellstr(num2str(hkl(displayInd,:)));
            twoTheta = cellstr(num2str(twoTheta(displayInd), '%.4f'));
            I = cellstr(num2str(I(displayInd), '%.2f'));
            checkedInd_table = num2cell(checkedInd_table);
            
            inputSize = size(twoTheta);
            switch obj.prediction.type
                case 'single-crystal'
                    lambdaSol = cellstr(num2str(lambdaSol(displayInd), ...
                        '%.4f'));
                    m = repmat({''}, inputSize(1), inputSize(2));
                case 'powder'
                    lambdaSol = cellstr(num2str(lambdaSol));
                    lambdaSol = repmat(lambdaSol, inputSize(1), ...
                        inputSize(2));
                    m = cellstr(num2str(m(displayInd)));
            end
            
            writeCell = [hkl, lambdaSol, m, twoTheta, I, ...
                checkedInd_table(2:end)];
            writeCell = [{'All', '-', '-', '-', '-', checkedInd_table{1}}; ...
                writeCell];
            set(tb, 'Data', writeCell, 'ColumnEditable', ...
                [false false false false false true], 'ColumnFormat', ...
                {'char','char', 'char', 'char', 'char', 'logical'});
        else
            
            writeCell = {'', '', '', '', '', ''};
            set(tb, 'Data', writeCell, 'ColumnEditable', ...
                [false false false false false false], 'ColumnFormat', ...
                {'char', 'char', 'char', 'char', 'char', 'char'});
            
            if strcmp(obj.prediction.type, 'single-crystal')
                warndlg(['No single-crystal prediction found. ', ...
                    'Try broadening the range of x-ray energies ', ...
                    'under "X-ray Source".']);
            end
            
        end
        
    end

    function updateAnalysis(varargin)

        if nargin > 0
            updateResultFlag = varargin{1};
        else
            updateResultFlag = true;
        end
        
        % check that analysisDlg exists and is valid
        
        badFlag = true;
        db = getappdata(mainFigure, 'analysisDlg');
        if ~isempty(db) && isvalid(db)
            if ishandle(db)
                badFlag = false;
            end
        end
        if badFlag
            return
        end

        % update results
        
        if updateResultFlag
            obj = generateResults(obj);
        end
        
        % delete old plot
        
        handleName = 'analysisPlot';
        if isappdata(mainFigure, handleName)
            delete(getappdata(mainFigure, handleName));
        end
        
        % plot results
        
        anAx = findobj(db, 'type', 'axes');
        startingXBounds = xlim(anAx);
        hr = plot(anAx, obj.results.twoTheta, ...
            obj.results.normalizedIntensity, 'k', 'linewidth', 2);
        xBounds = obj.results.normalizedIntensity > 1e-6;
        xBounds = [find(xBounds,1,'first'), find(xBounds,1,'last')];
        xBounds = obj.results.twoTheta(xBounds);
        if ~isempty(xBounds) && max(abs(startingXBounds - [0 1])) < 1e-6
            xBounds = [floor(xBounds(1)) ceil(xBounds(2))];
            xlim(anAx, xBounds);
        end
        
        % plot predictions
        
        checkedInd = obj.externalUserData.checkedInd;
        displayInd = obj.externalUserData.displayInd;
        plotInd = checkedInd(2:end) & displayInd;
        twoThetaPred = repmat(obj.prediction.twoTheta(plotInd)',2,1);
%         yVal = ylim(db.Axes)';
        yVal = [zeros([1 size(twoThetaPred,2)]); ...
            obj.prediction.I(plotInd)'];
        hp = plot(anAx, twoThetaPred, yVal, 'r--', ...
            'linewidth', 0.5);
        
        % save for future deletion
        
        setappdata(mainFigure, handleName, [hr, hp']);
        
    end

    function updateImageProcessing
        
        % update image processing
        
        if isnumeric(obj.detector.image)
            return
        end
        
        % check that processDlg exists and is valid
        
        badFlag = true;
        db = getappdata(mainFigure, 'processDlg');
        if ~isempty(db) && isvalid(db)
            if ishandle(db)
                badFlag = false;
            end
        end
        if badFlag
            return
        end

        % determine existing lims

        dbAx = findobj(db, 'Type', 'Axes');
        xLims = get(dbAx, 'XLim');
        yLims = get(dbAx, 'YLim');
        
        % delete old plot
        
        handleName = 'processPlot';
        if isappdata(mainFigure, handleName)
            delete(getappdata(mainFigure, handleName));
        end
        
        % plot detector image
        
        view(obj.detector.image, 'show', dbAx, true);
        pbaspect(dbAx, [1 1 1]);
        if xLims(2) ~= 1 || yLims(2) ~= 1
            set(dbAx, 'XLim', xLims);
            set(dbAx, 'YLim', yLims);
        end
        hp = get(dbAx, 'Children');
        setappdata(mainFigure, handleName, hp);
        
        % update the contour limit display
        
        if ~ischar(obj.detector.image.DataLim)
            clim = obj.detector.image.DataLim;
        else
            clim = round([min(min(obj.detector.image.Data)), ...
                max(max(obj.detector.image.Data))]);
        end
        delete(findobj(db, 'Type', 'ColorBar'));
        
        set(findobj(db, 'Tag', 'clim1'), 'Value', ...
            num2str(clim(1)));
        set(findobj(db, 'Tag', 'clim2'), 'Value', ...
            num2str(clim(2)));
        
        % make sure height and width display are correct on detector dlg
        
        detectorDlg = getappdata(mainFigure, 'detectorDlg');
        if ~isempty(detectorDlg) && isvalid(detectorDlg)
            detectorDlg = detectorDlg.Figure;
            set(findobj(detectorDlg, 'Tag', 'size1'), 'Value', ...
                num2str(obj.detector.size(1)));
            set(findobj(detectorDlg, 'Tag', 'size2'), 'Value', ...
                num2str(obj.detector.size(2)));
        end
        
    end

end