function lambdaRange = extractLambdaRange(obj)

% pull out lambda range

lambdaDriver = true;
dist = obj.source.lambdaDistribution;
mu = obj.source.lambda;
if contains(obj.source.distributionDriver(1), 'E')
    lambdaDriver = false;
    dist = obj.source.EDistribution;
    mu = obj.source.E;
end

if isnumeric(dist)
    if numel(dist) == 1 % Gaussian sigma
        lambdaRange = mu + 3*[-dist dist]; % 99.7%
    elseif numel(dist) == 2
        lambdaRange = dist;
    else % interpolation with raw data
        lambdaRange = [min(dist(:,1)), max(dist(:,1))];
    end
elseif contains(class(dist), 'prob') % pd object
    lambdaRange = icdf(dist, [0.001 0.999]);
else % function handle or curve fit (not recommended)
    warning('Unrecommended distribution type may cause solver to fail')
    lambdaRange = [dist{3} dist{4}];
end

if ~lambdaDriver
    lambdaRange = obj.source.conversion ./ lambdaRange;
end
lambdaRange = sort(lambdaRange);
badInd = lambdaRange < 0;
if any(badInd)
    warning('Bad distribution may cause solver to fail')
    lambdaRange(badInd) = 1e-3;
end

end