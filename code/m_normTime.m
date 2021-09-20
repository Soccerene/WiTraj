function t = m_normTime( ts )

    dt = diff(ts) / 1000000;
    mm = dt>1 | dt<0;
    if sum(mm) > 0
        dt(mm) = mean(dt(~mm));
    end
    t = [0 cumsum(dt)];
    mm = [0, (dt==0)];
    if sum(mm) > 0
        idx = 1:length(ts);
        t = interp1(idx(~mm), t(~mm), idx, 'linear', 'extrap');
    end    
end