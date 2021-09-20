function [dopplerspeed, score, agree, slope, duslope, mrange] = windowd_speed(csiq, samp_rate, window_size)

    timeslot = 6/window_size;     % 0.05 before modification
    wsize = floor(timeslot * samp_rate);

    window_size = window_size * samp_rate / 400;
    ncsi = mean(csiq, 2, 'omitnan');
    len = length(ncsi);
   
    for i=1:3
        ncsi = m_denoise_w(ncsi, samp_rate/window_size);
    end

    skip = 2;  % for smoother doppler speed extraction
    ns = [ncsi(1:skip,:); ncsi];
    ne = [ncsi; ncsi(end - skip + 1:end, :)];
    csislope = ne - ns;     % get tangent on the circle
    csislope = csislope(skip+1:skip+len, :);    % restore the same amount of samples
    slope = angle(csislope);        % calculate phase of tangent
    slope(1,:) = slope(2,:);
    slope(end,:) = slope(end-1,:);
    
    uslope = unwrap(slope);         % unwarp phase by 2pi
    uslope = uslope - uslope(1,:);  % phase change start from 0
    
    
    % mark unsure segments
    duslope = diff(uslope);  % doppler speed
    duslope = [duslope(1,:); duslope];
    mslope_min = movmin(duslope, wsize, 'omitnan');
    mslope_max = movmax(duslope, wsize, 'omitnan');
    mslope_range = mslope_max - mslope_min;


    du = movmean(duslope, wsize);
    agree = sum(sign(du), 2, 'omitnan');
    speed_dir = sign(agree);
    agree = abs(agree);

    
    % min duslope variation
    [mrange, min_score] = min(mslope_range, [], 2, 'omitnan');
    dopplerspeed = zeros(len, 1);
    for i = 1:len
        dopplerspeed(i) = -abs(duslope(i,min_score(i))) * speed_dir(i);
        %slope(i) = uslope(i,min_score(i));
    end
    % mark uncertain segments
    %uncertain_seg = mrange > 1;
    %dopplerspeed(uncertain_seg) = 0;
    xnan = isnan(dopplerspeed);
    x = 1:len;
    dopplerspeed = interp1(x(~xnan), dopplerspeed(~xnan), x);
    dopplerspeed = dopplerspeed';
    duslope = dopplerspeed;
    slope = -cumsum(dopplerspeed, 'omitnan');
    
    dopplerspeed = dopplerspeed * samp_rate / (2*pi);
    dopplerspeed = movmean(dopplerspeed, wsize/2);

    score = -mrange/window_size;
    agree = agree./score;
    

end

