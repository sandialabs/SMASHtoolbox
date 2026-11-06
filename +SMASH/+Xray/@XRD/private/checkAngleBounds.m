function [moHigh, moLow] = checkAngleBounds(mo, moBound)

% initial processing happens in changeObject. This just makes sure we don't
% search above or below 180 or 0, respectively. Assumes all inputs are 
% positive. Originally written for mosaicity but applicable to anything
% that runs 0 to 180

moHigh = moBound;
moCheck = mo + moHigh;
badInd = moCheck > 180;
moHigh(badInd) = moHigh(badInd) + 180 - moCheck(badInd);

moLow = moBound;
moCheck = mo - moLow;
badInd = moCheck < 0;
moLow(badInd) = moLow(badInd) + moCheck(badInd);

end