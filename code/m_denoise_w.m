function ret = m_denoise_w( x, winsize )
%MODULE_DENOISE signal denoise
%   Detailed explanation goes here

    %% Savitzky-Golay smoothing
    
    len = length(x);
    if len < 30
        ret = x;
        return;
    end
 
    N = 2;                 % Order of polynomial fit
    F = floor(winsize);  % Windows Length (about 1 period)  3 or 10 for plate&bottle 30 or 50 for person
    if F > len
        F = len - 2;
    end
    if mod(F, 2) == 0
        F = F + 1;          % Make it odd
    end

    ret = sgolayfilt( x, N, F );

end

