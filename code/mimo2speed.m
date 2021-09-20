function [dopplerspeed, score, slope, duslope, mrange] = mimo2speed(rx, samp_rate)

%   get CSI ratio from raw CSI input
    csiq = getAntMIMO(rx, 1, 3);
    
    [speed_high, score_high, agree_high, slope, duslope, mrange] = windowd_speed(csiq, samp_rate, 40);
    [speed_low , score_low, agree_low ] = windowd_speed(csiq, samp_rate, 25);
    speed = [speed_high, speed_low];
%    score_in = [score_high, score_low];
    score_in = -[agree_high, agree_low];
%    score_in = -[score_high .* agree_high, score_low .* agree_low];
    
    [score, idx] = max(score_in, [], 2);
    dopplerspeed = zeros(size(speed_high));
    for i = 1:length(score)
        dopplerspeed(i) = speed(i, idx(i));
    end

end
