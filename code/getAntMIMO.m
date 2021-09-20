function [ret,denominator] = getAntMIMO(rx, ant1, ant2)
%GETDIVMIMO get best channel ratio
%   Detailed explanation goes here


%% avoid inf and nan
r1 = m_removecomplexzero( rx{1, 1} );
r2 = m_removecomplexzero( rx{1, 2} );
r3 = m_removecomplexzero( rx{1, 3} );


x = 1:length(r1);

denominator = 0;

r1avg=nanmean(nanmean(abs(r1)));
r2avg=nanmean(nanmean(abs(r2)));
r3avg=nanmean(nanmean(abs(r3)));
level = [r1avg r2avg r3avg];

if level(ant1) > level(ant2)
    maxIndex = ant1;
    minIndex = ant2;
else
    maxIndex = ant2;
    minIndex = ant1;
end

disp(['level = ', num2str(level)]);
%disp(['r', num2str(idx), '/r', num2str(maxIndex)]);
%ret = rx{1,idx}./rx{1,maxIndex};

% ret = [r1./r2, r2./r1, r1./r3, r3./r1, r2./r3, r3./r2];
disp(['r', num2str(minIndex), '/r', num2str(maxIndex), ', r', num2str(minIndex), '/r', num2str(maxIndex)]);
ret = rx{1,minIndex}./rx{1,maxIndex};
return;

denominator=maxIndex;
% fill nan position in the stream
ret = interp1(x(~nanidx), ret(~nanidx, :), x);

% append nan endings with the last non-nan data
idx = length(x);
nanflag = sum(~isnan(ret), 2);
while ~nanflag(idx, 1)
    idx = idx - 1;
end
ret(idx, :) = ret(idx-1, :);
while idx ~= length(x)
    ret(idx+1, :) = ret(idx, :);
    idx = idx + 1;
end

% if r1avg > r3avg
%     ret = r3 ./ r1;
% else
%     ret = r1 ./ r3;
% end

end

