% generate s cone for prediction and for results Lorentz corrections
%
% twoTheta is a column vector
%
function s = sCone(twoTheta, s0)

% generate s cone by rotating s0 by twoTheta about some orthogonal
% vector and then rotating the result uniformly about s0.
% each row represents twoTheta and each page represents a
% different part of the cone
% note: faster to repmat and then use built-in dot and cross

s0 = s0/norm(s0);
if s0(3) == 0
    a = [0 0 1];
else
    a = [1 1 -(s0(1)+s0(2))/s0(3)]; a = a/norm(a);
end

phi = permute(linspace(0,360,1000), [1 3 2]);
s = s0.*cosd(twoTheta) + cross(a,s0,2).*sind(twoTheta) + ...
    a.*dot(a,s0,2).*(1-cosd(twoTheta));
s0 = repmat(s0, size(s,1), 1, 1);
s = s.*cosd(phi) + cross(s0,s,2).*sind(phi) + ...
    s0.*dot(s0,s,2).*(1-cosd(phi));

end