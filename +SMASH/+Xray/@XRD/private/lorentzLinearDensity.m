% compute linear density portion of the Lorentz correction (divide results
% by this value and multiply predictions by this value)
%
% spotLocation rows are different twoTheta, columns are xyz, and pages are
% different points along the ring. Points that don't touch the detector are
% signified by NaN.
%
function L = lorentzLinearDensity(spotLocations)

% Lorentz correction from the average linear density
% of points on the detector

rho = sum(~isnan(spotLocations(:,1,1:end-1)),3) / ...
    (size(spotLocations,3) - 1); % ring fraction on detector (accounting for 0-360 redundancy)
c = sum(sqrt(sum(diff(spotLocations,1,3).^2, ...
    2)),3,'omitnan'); % distance along detector (making use of 0-360 redundancy)
L = rho./c;

end