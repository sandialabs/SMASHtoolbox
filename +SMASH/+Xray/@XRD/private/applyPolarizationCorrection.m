function obj = applyPolarizationCorrection(obj, varargin)

% inputs (only extract small variables for sim speed)

fieldName = 'prediction';
if nargin > 1
    fieldName = varargin{1};
end

f = obj.source.polarizationFraction;
v = obj.source.polarizationVector;
s0 = obj.source.s0;

s0 = s0/vecnorm(s0,2,2);
v = v./vecnorm(v,2,2);

if f(1) > 0 && dot(s0,v) ~= 0
    warning('Nonphysical polarization! Polarization not orthogonal to s0');
end

% corrections

sz = size(obj.(fieldName).s,1,2,3);

p0 = 0.5*(1 + cosd(obj.(fieldName).twoTheta).^2); % unpolarized
p1 = 1 - dot(obj.(fieldName).s,repmat(v,sz(1),1,sz(3)),2).^2; % comp 1

% total correction and application

if sz(3) > 1 % powder
    ind = isnan(obj.prediction.spotLocations(:,1,:));
    p1(ind) = nan;
    p1 = mean(p1,3,'omitmissing');
end

p = (1-f)*p0 + f*p1;
obj.(fieldName).I = obj.(fieldName).I .* p;

end